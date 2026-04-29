import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  List<AutomationRule> _rules = [];
  bool _isLoading = true;
  
  final List<String> _availableDevices = ['light1', 'fan1', 'curtain1', 'motor1'];
  final Map<String, String> _deviceLabels = {
    'light1': 'Lights',
    'fan1': 'Fan',
    'curtain1': 'Curtains',
    'motor1': 'Water Motor',
  };
  final Map<String, List<String>> _deviceActions = {
    'light1': ['ON', 'OFF'],
    'fan1': ['ON', 'OFF', 'AUTO'],
    'curtain1': ['ON', 'OFF'],
    'motor1': ['ON', 'OFF'],
  };
  final Map<String, Color> _deviceColors = {
    'light1': AppColors.accentAmber,
    'fan1': AppColors.primaryBlue,
    'curtain1': AppColors.accentPurple,
    'motor1': AppColors.primaryGreen,
  };

  @override
  void initState() {
    super.initState();
    _loadRules();
    _listenToRules();
  }

  void _listenToRules() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService.database.child('automation/${user.uid}/rules').onValue.listen((event) {
        if (event.snapshot.value != null) {
          _parseRules(event.snapshot.value);
        }
      });
    }
  }

  Future<void> _loadRules() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseService.database.child('automation/${user.uid}/rules').once();
      if (snapshot.snapshot.value != null) {
        _parseRules(snapshot.snapshot.value);
      }
    }
    setState(() => _isLoading = false);
  }

  void _parseRules(dynamic rulesData) {
    _rules = [];
    final rulesMap = rulesData as Map<dynamic, dynamic>;
    rulesMap.forEach((key, value) {
      final ruleData = value as Map<dynamic, dynamic>;
      final devicesList = <DeviceAction>[];
      final devicesData = ruleData['devices'] as Map<dynamic, dynamic>? ?? {};
      
      devicesData.forEach((deviceId, deviceRule) {
        devicesList.add(DeviceAction(
          deviceId: deviceId.toString(),
          action: deviceRule['action'] ?? 'OFF',
          startTime: deviceRule['startTime'] ?? '',
          endTime: deviceRule['endTime'] ?? '',
        ));
      });
      
      _rules.add(AutomationRule(
        id: key.toString(),
        name: ruleData['name'] ?? 'Automation Rule',
        devices: devicesList,
        isActive: ruleData['active'] ?? false,
        createdAt: ruleData['createdAt'] ?? DateTime.now().toIso8601String(),
      ));
    });
    setState(() {});
  }

  Future<void> _saveRule(AutomationRule rule) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final devicesMap = <String, dynamic>{};
    for (var device in rule.devices) {
      devicesMap[device.deviceId] = {
        'action': device.action,
        'startTime': device.startTime,
        'endTime': device.endTime,
      };
    }
    
    await FirebaseService.database
        .child('automation/${user.uid}/rules/${rule.id}')
        .set({
      'name': rule.name,
      'devices': devicesMap,
      'active': rule.isActive,
      'createdAt': rule.createdAt,
    });
    
    if (rule.isActive) {
      await _applyRule(rule);
    }
  }

  Future<void> _applyRule(AutomationRule rule) async {
    for (var device in rule.devices) {
      // If both start and end time are set, apply schedule
      if (device.startTime.isNotEmpty && device.endTime.isNotEmpty) {
        await FirebaseService.database
            .child('schedule/${device.deviceId}')
            .set({
          'start': device.startTime,
          'end': device.endTime,
        });
      }
      // If only start time is set (ON at specific time)
      else if (device.startTime.isNotEmpty && device.action != 'OFF') {
        await FirebaseService.database
            .child('schedule/${device.deviceId}/start')
            .set(device.startTime);
      }
      // If only end time is set (OFF at specific time)
      else if (device.endTime.isNotEmpty && device.action == 'OFF') {
        await FirebaseService.database
            .child('schedule/${device.deviceId}/end')
            .set(device.endTime);
      }
      // If no time set, apply immediate ON/OFF action
      else if (device.startTime.isEmpty && device.endTime.isEmpty) {
        if (device.action == 'ON') {
          await FirebaseService.database.child('devices/${device.deviceId}/state').set('ON');
          await _logDeviceAction(device.deviceId, 'ON', 'AUTOMATION');
        } else if (device.action == 'OFF') {
          await FirebaseService.database.child('devices/${device.deviceId}/state').set('OFF');
          await _logDeviceAction(device.deviceId, 'OFF', 'AUTOMATION');
        } else if (device.action == 'AUTO') {
          await FirebaseService.database.child('devices/${device.deviceId}/mode').set('AUTO');
        }
      }
    }
  }

  Future<void> _logDeviceAction(String deviceId, String state, String mode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database.child('logs/devices/$deviceId').push().set({
        'state': state,
        'mode': mode,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': user.uid,
      });
    }
  }

  Future<void> _removeRule(AutomationRule rule) async {
    for (var device in rule.devices) {
      // Remove schedule if it was set by this rule
      if (device.startTime.isNotEmpty || device.endTime.isNotEmpty) {
        final scheduleRef = FirebaseService.database.child('schedule/${device.deviceId}');
        final snapshot = await scheduleRef.once();
        if (snapshot.snapshot.value != null) {
          await scheduleRef.remove();
        }
      }
      
      // Turn OFF devices that were turned ON by this rule with no time
      if (device.startTime.isEmpty && device.endTime.isEmpty && device.action == 'ON') {
        await FirebaseService.database.child('devices/${device.deviceId}/state').set('OFF');
        await _logDeviceAction(device.deviceId, 'OFF', 'AUTOMATION_OFF');
      }
    }
  }

  Future<void> _toggleRule(AutomationRule rule, bool newState) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await FirebaseService.database
        .child('automation/${user.uid}/rules/${rule.id}/active')
        .set(newState);
    
    if (newState) {
      await _applyRule(rule);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rule "${rule.name}" activated!'), backgroundColor: AppColors.primaryGreen),
      );
    } else {
      await _removeRule(rule);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rule "${rule.name}" deactivated'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _createNewRule() async {
    final newRule = await showDialog<AutomationRule>(
      context: context,
      builder: (context) => CreateRuleDialog(
        availableDevices: _availableDevices,
        deviceLabels: _deviceLabels,
        deviceActions: _deviceActions,
        deviceColors: _deviceColors,
      ),
    );
    
    if (newRule != null) {
      await _saveRule(newRule);
      setState(() {
        _rules.add(newRule);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Automation rule created!'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  Future<void> _editRule(AutomationRule rule) async {
    final updatedRule = await showDialog<AutomationRule>(
      context: context,
      builder: (context) => EditRuleDialog(
        rule: rule,
        availableDevices: _availableDevices,
        deviceLabels: _deviceLabels,
        deviceActions: _deviceActions,
        deviceColors: _deviceColors,
      ),
    );
    
    if (updatedRule != null) {
      if (rule.isActive) {
        await _removeRule(rule);
      }
      await _saveRule(updatedRule);
      setState(() {
        final index = _rules.indexWhere((r) => r.id == rule.id);
        if (index != -1) {
          _rules[index] = updatedRule;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rule updated!'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  Future<void> _deleteRule(AutomationRule rule) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text('Delete "${rule.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (rule.isActive) {
                  await _removeRule(rule);
                }
                await FirebaseService.database
                    .child('automation/${user.uid}/rules/${rule.id}')
                    .remove();
                setState(() {
                  _rules.removeWhere((r) => r.id == rule.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rule deleted'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgLightBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      appBar: AppBar(
        title: const Text('Automation'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _createNewRule,
            color: AppColors.primaryBlue,
          ),
        ],
      ),
      body: _rules.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('My Automation Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${_rules.where((r) => r.isActive).length} Active',
                                style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rules.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildRuleCard(_rules[index]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCreateButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 50, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 20),
          const Text('No Automation Rules', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text('Create rules to automate your devices', style: TextStyle(fontSize: 14, color: AppColors.mediumGray)),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: _createNewRule,
            icon: const Icon(Icons.add),
            label: const Text('Create First Rule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _createNewRule,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 10),
                Text('Create New Automation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(AutomationRule rule) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.isActive ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.borderGray,
          width: 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.schedule, color: AppColors.primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('${rule.devices.length} device(s)', style: const TextStyle(fontSize: 11, color: AppColors.mediumGray)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _editRule(rule),
                  color: AppColors.primaryBlue,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deleteRule(rule),
                  color: AppColors.error,
                ),
                Switch(
                  value: rule.isActive,
                  onChanged: (value) => _toggleRule(rule, value),
                  activeColor: AppColors.primaryGreen,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: rule.devices.map((device) {
                final color = _deviceColors[device.deviceId] ?? AppColors.mediumGray;
                final hasSchedule = device.startTime.isNotEmpty || device.endTime.isNotEmpty;
                final hasImmediate = device.startTime.isEmpty && device.endTime.isEmpty;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(_getDeviceIcon(device.deviceId), size: 18, color: color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _deviceLabels[device.deviceId] ?? device.deviceId,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              device.action,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                            ),
                          ),
                        ],
                      ),
                      if (hasSchedule)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (device.startTime.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentAmber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '⏰ ${device.startTime}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.accentAmber, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              if (device.endTime.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentAmber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '⏰ ${device.endTime}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.accentAmber, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              if (hasImmediate)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '⚡ Immediate',
                                    style: TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String deviceId) {
    switch (deviceId) {
      case 'light1':
        return Icons.lightbulb_outline;
      case 'fan1':
        return Icons.ac_unit;
      case 'curtain1':
        return Icons.curtains_closed;
      case 'motor1':
        return Icons.water_damage_outlined;
      default:
        return Icons.devices;
    }
  }
}

// ==================== CREATE RULE DIALOG ====================

class CreateRuleDialog extends StatefulWidget {
  final List<String> availableDevices;
  final Map<String, String> deviceLabels;
  final Map<String, List<String>> deviceActions;
  final Map<String, Color> deviceColors;

  const CreateRuleDialog({
    super.key,
    required this.availableDevices,
    required this.deviceLabels,
    required this.deviceActions,
    required this.deviceColors,
  });

  @override
  State<CreateRuleDialog> createState() => _CreateRuleDialogState();
}

class _CreateRuleDialogState extends State<CreateRuleDialog> {
  String _ruleName = '';
  List<DeviceAction> _selectedDevices = [];
  bool _activateNow = false;

  @override
  void initState() {
    super.initState();
    _selectedDevices.add(DeviceAction(
      deviceId: widget.availableDevices.first,
      action: 'ON',
      startTime: '',
      endTime: '',
    ));
  }

  void _addDevice() {
    setState(() {
      _selectedDevices.add(DeviceAction(
        deviceId: widget.availableDevices.first,
        action: 'ON',
        startTime: '',
        endTime: '',
      ));
    });
  }

  void _removeDevice(int index) {
    setState(() {
      _selectedDevices.removeAt(index);
    });
  }

  void _updateDevice(int index, DeviceAction updated) {
    setState(() {
      _selectedDevices[index] = updated;
    });
  }

  Future<void> _selectStartTime(int index, DeviceAction device) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateDevice(index, DeviceAction(
        deviceId: device.deviceId,
        action: device.action,
        startTime: timeStr,
        endTime: device.endTime,
      ));
    }
  }

  Future<void> _selectEndTime(int index, DeviceAction device) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateDevice(index, DeviceAction(
        deviceId: device.deviceId,
        action: device.action,
        startTime: device.startTime,
        endTime: timeStr,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Automation Rule'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Rule Name',
                  hintText: 'e.g., Morning Routine',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _ruleName = v,
              ),
              const SizedBox(height: 16),
              const Text('Devices & Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedDevices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final device = _selectedDevices[index];
                  final color = widget.deviceColors[device.deviceId] ?? AppColors.primaryBlue;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                value: device.deviceId,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: widget.availableDevices.map((deviceId) {
                                  return DropdownMenuItem(
                                    value: deviceId,
                                    child: Text(widget.deviceLabels[deviceId] ?? deviceId),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _updateDevice(index, DeviceAction(
                                      deviceId: value,
                                      action: widget.deviceActions[value]?.first ?? 'ON',
                                      startTime: device.startTime,
                                      endTime: device.endTime,
                                    ));
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: device.action,
                              items: widget.deviceActions[device.deviceId]?.map((action) {
                                return DropdownMenuItem(value: action, child: Text(action));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _updateDevice(index, DeviceAction(
                                    deviceId: device.deviceId,
                                    action: value,
                                    startTime: device.startTime,
                                    endTime: device.endTime,
                                  ));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                              onPressed: () => _removeDevice(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              width: 100,
                              child: GestureDetector(
                                onTap: () => _selectStartTime(index, device),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderGray),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.mediumGray),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          device.startTime.isEmpty ? 'Start' : device.startTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: device.startTime.isEmpty ? AppColors.mediumGray : AppColors.accentAmber,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: GestureDetector(
                                onTap: () => _selectEndTime(index, device),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderGray),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.mediumGray),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          device.endTime.isEmpty ? 'End' : device.endTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: device.endTime.isEmpty ? AppColors.mediumGray : AppColors.accentAmber,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _addDevice,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Device'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _activateNow,
                    onChanged: (v) => setState(() => _activateNow = v ?? false),
                    activeColor: AppColors.primaryBlue,
                  ),
                  const Text('Activate this rule now'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_ruleName.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter rule name'), backgroundColor: AppColors.error),
              );
              return;
            }
            if (_selectedDevices.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add at least one device'), backgroundColor: AppColors.error),
              );
              return;
            }
            Navigator.pop(context, AutomationRule(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _ruleName,
              devices: _selectedDevices,
              isActive: _activateNow,
              createdAt: DateTime.now().toIso8601String(),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          child: const Text('Create Rule'),
        ),
      ],
    );
  }
}

// ==================== EDIT RULE DIALOG ====================

class EditRuleDialog extends StatefulWidget {
  final AutomationRule rule;
  final List<String> availableDevices;
  final Map<String, String> deviceLabels;
  final Map<String, List<String>> deviceActions;
  final Map<String, Color> deviceColors;

  const EditRuleDialog({
    super.key,
    required this.rule,
    required this.availableDevices,
    required this.deviceLabels,
    required this.deviceActions,
    required this.deviceColors,
  });

  @override
  State<EditRuleDialog> createState() => _EditRuleDialogState();
}

class _EditRuleDialogState extends State<EditRuleDialog> {
  late String _ruleName;
  late List<DeviceAction> _selectedDevices;
  late bool _activateNow;

  @override
  void initState() {
    super.initState();
    _ruleName = widget.rule.name;
    _selectedDevices = List.from(widget.rule.devices);
    _activateNow = widget.rule.isActive;
  }

  void _addDevice() {
    setState(() {
      _selectedDevices.add(DeviceAction(
        deviceId: widget.availableDevices.first,
        action: 'ON',
        startTime: '',
        endTime: '',
      ));
    });
  }

  void _removeDevice(int index) {
    setState(() {
      _selectedDevices.removeAt(index);
    });
  }

  void _updateDevice(int index, DeviceAction updated) {
    setState(() {
      _selectedDevices[index] = updated;
    });
  }

  Future<void> _selectStartTime(int index, DeviceAction device) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateDevice(index, DeviceAction(
        deviceId: device.deviceId,
        action: device.action,
        startTime: timeStr,
        endTime: device.endTime,
      ));
    }
  }

  Future<void> _selectEndTime(int index, DeviceAction device) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateDevice(index, DeviceAction(
        deviceId: device.deviceId,
        action: device.action,
        startTime: device.startTime,
        endTime: timeStr,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Automation Rule'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: _ruleName),
                decoration: const InputDecoration(
                  labelText: 'Rule Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _ruleName = v,
              ),
              const SizedBox(height: 16),
              const Text('Devices & Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedDevices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final device = _selectedDevices[index];
                  final color = widget.deviceColors[device.deviceId] ?? AppColors.primaryBlue;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                value: device.deviceId,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: widget.availableDevices.map((deviceId) {
                                  return DropdownMenuItem(
                                    value: deviceId,
                                    child: Text(widget.deviceLabels[deviceId] ?? deviceId),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _updateDevice(index, DeviceAction(
                                      deviceId: value,
                                      action: device.action,
                                      startTime: device.startTime,
                                      endTime: device.endTime,
                                    ));
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: device.action,
                              items: widget.deviceActions[device.deviceId]?.map((action) {
                                return DropdownMenuItem(value: action, child: Text(action));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _updateDevice(index, DeviceAction(
                                    deviceId: device.deviceId,
                                    action: value,
                                    startTime: device.startTime,
                                    endTime: device.endTime,
                                  ));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                              onPressed: () => _removeDevice(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              width: 100,
                              child: GestureDetector(
                                onTap: () => _selectStartTime(index, device),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderGray),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.mediumGray),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          device.startTime.isEmpty ? 'Start' : device.startTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: device.startTime.isEmpty ? AppColors.mediumGray : AppColors.accentAmber,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: GestureDetector(
                                onTap: () => _selectEndTime(index, device),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderGray),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.mediumGray),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          device.endTime.isEmpty ? 'End' : device.endTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: device.endTime.isEmpty ? AppColors.mediumGray : AppColors.accentAmber,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _addDevice,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Device'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _activateNow,
                    onChanged: (v) => setState(() => _activateNow = v ?? false),
                    activeColor: AppColors.primaryBlue,
                  ),
                  const Text('Activate this rule'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_ruleName.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter rule name'), backgroundColor: AppColors.error),
              );
              return;
            }
            Navigator.pop(context, AutomationRule(
              id: widget.rule.id,
              name: _ruleName,
              devices: _selectedDevices,
              isActive: _activateNow,
              createdAt: widget.rule.createdAt,
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

// ==================== DATA MODELS ====================

class DeviceAction {
  final String deviceId;
  final String action;
  final String startTime;
  final String endTime;

  DeviceAction({
    required this.deviceId,
    required this.action,
    required this.startTime,
    required this.endTime,
  });
}

class AutomationRule {
  final String id;
  final String name;
  final List<DeviceAction> devices;
  bool isActive;
  final String createdAt;

  AutomationRule({
    required this.id,
    required this.name,
    required this.devices,
    required this.isActive,
    required this.createdAt,
  });
}