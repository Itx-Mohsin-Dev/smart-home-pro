import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> device;
  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late String deviceId;
  late String deviceLabel;
  late Color deviceColor;
  late IconData deviceIcon;
  
  bool _isOn = false;
  String _mode = 'MANUAL';
  String _startTime = '';
  String _endTime = '';
  double _deviceUsage = 0;
  double _totalUnits = 0;
  double _allowedUnits = 200;
  String _peakStart = '18:00';
  String _peakEnd = '00:00';
  int _temperature = 20;
  int _fanTempThreshold = 20;
  bool _isPeakHourNow = false;

  @override
  void initState() {
    super.initState();
    deviceId = widget.device['deviceId'] ?? 'light1';
    deviceLabel = widget.device['label'] ?? widget.device['name'] ?? 'Device';
    deviceColor = widget.device['color'] ?? AppColors.primaryBlue;
    deviceIcon = widget.device['icon'] ?? Icons.devices;
    
    _loadAllData();
    _listenToRealTimeUpdates();
    _checkPeakHour();
  }

  void _listenToRealTimeUpdates() {
    FirebaseService.database.child('devices/$deviceId/state').onValue.listen((event) {
      if (event.snapshot.value != null) setState(() => _isOn = event.snapshot.value.toString() == 'ON');
    });
    FirebaseService.database.child('devices/$deviceId/mode').onValue.listen((event) {
      if (event.snapshot.value != null) setState(() => _mode = event.snapshot.value.toString());
    });
  }

  Future<void> _checkPeakHour() async {
    final isPeak = await _isPeakHour();
    setState(() {
      _isPeakHourNow = isPeak;
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadDeviceState(),
      _loadMode(),
      _loadSchedule(),
      _loadUsage(),
      _loadSettings(),
      _loadSensors(),
    ]);
  }

  Future<void> _loadDeviceState() async {
    final snapshot = await FirebaseService.database.child('devices/$deviceId/state').once();
    if (snapshot.snapshot.value != null) setState(() => _isOn = snapshot.snapshot.value.toString() == 'ON');
  }

  Future<void> _loadMode() async {
    final snapshot = await FirebaseService.database.child('devices/$deviceId/mode').once();
    if (snapshot.snapshot.value != null) setState(() => _mode = snapshot.snapshot.value.toString());
  }

  Future<void> _loadSchedule() async {
    final snapshot = await FirebaseService.database.child('schedule/$deviceId').once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map;
      setState(() {
        _startTime = data['start'] ?? '';
        _endTime = data['end'] ?? '';
      });
    }
  }

  Future<void> _loadUsage() async {
    final usageSnapshot = await FirebaseService.database.child('usage/devices/$deviceId').once();
    if (usageSnapshot.snapshot.value != null) {
      setState(() => _deviceUsage = (usageSnapshot.snapshot.value as num).toDouble());
    }
    
    final totalSnapshot = await FirebaseService.database.child('usage/total_consumed_units').once();
    if (totalSnapshot.snapshot.value != null) {
      setState(() => _totalUnits = (totalSnapshot.snapshot.value as num).toDouble());
    }
  }

  Future<void> _loadSettings() async {
    final allowedSnapshot = await FirebaseService.database.child('settings/allowed_units').once();
    if (allowedSnapshot.snapshot.value != null) {
      setState(() => _allowedUnits = (allowedSnapshot.snapshot.value as num).toDouble());
    }
    
    final peakStartSnap = await FirebaseService.database.child('settings/peak_start').once();
    if (peakStartSnap.snapshot.value != null) {
      setState(() => _peakStart = peakStartSnap.snapshot.value.toString());
    }
    
    final peakEndSnap = await FirebaseService.database.child('settings/peak_end').once();
    if (peakEndSnap.snapshot.value != null) {
      setState(() => _peakEnd = peakEndSnap.snapshot.value.toString());
    }
    
    final fanTempSnap = await FirebaseService.database.child('settings/fan_temp_threshold').once();
    if (fanTempSnap.snapshot.value != null) {
      setState(() => _fanTempThreshold = (fanTempSnap.snapshot.value as num).toInt());
    }
  }

  Future<void> _loadSensors() async {
    final tempSnapshot = await FirebaseService.database.child('sensors/temperature').once();
    if (tempSnapshot.snapshot.value != null) {
      setState(() => _temperature = (tempSnapshot.snapshot.value as num).toInt());
    }
  }

  Future<bool> _isPeakHour() async {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    int startHour = int.parse(_peakStart.split(':')[0]);
    int startMinute = int.parse(_peakStart.split(':')[1]);
    int endHour = int.parse(_peakEnd.split(':')[0]);
    int endMinute = int.parse(_peakEnd.split(':')[1]);
    
    final currentTotalMinutes = currentHour * 60 + currentMinute;
    final startTotalMinutes = startHour * 60 + startMinute;
    
    if (endHour == 0 && endMinute == 0) {
      return currentTotalMinutes >= startTotalMinutes;
    }
    
    final endTotalMinutes = endHour * 60 + endMinute;
    return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes <= endTotalMinutes;
  }

  Future<void> _triggerBuzzer() async {
    await FirebaseService.database.child('buzzer/state').set('ON');
    await Future.delayed(const Duration(milliseconds: 500));
    await FirebaseService.database.child('buzzer/state').set('OFF');
  }

  Future<void> _sendNotification(String title, String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database.child('notifications/${user.uid}').push().set({
        'title': title,
        'message': message,
        'type': 'alert',
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });
    }
  }

  Future<void> _togglePower() async {
    final isHeavyDevice = deviceId == 'motor1' || deviceId == 'fan1';
    
    if (!_isOn && _isPeakHourNow && isHeavyDevice) {
      await _triggerBuzzer();
      await _sendNotification(
        'Peak Hour Alert',
        '$deviceLabel turned ON during peak hours ($_peakStart - $_peakEnd). Buzzer activated.',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $deviceLabel turned ON during peak hours! Buzzer activated.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    
    if (_totalUnits >= _allowedUnits && !_isOn) {
      await _sendNotification('Unit Limit Exceeded', 'Cannot turn on $deviceLabel. You have reached your limit of $_allowedUnits units.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Unit limit exceeded! You have used $_totalUnits out of $_allowedUnits units.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    final newState = _isOn ? 'OFF' : 'ON';
    await FirebaseService.database.child('devices/$deviceId/state').set(newState);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database.child('logs/devices/$deviceId').push().set({
        'state': newState,
        'mode': _mode,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': user.uid,
      });
    }
  }

  Future<void> _setMode(String mode) async {
    await FirebaseService.database.child('devices/$deviceId/mode').set(mode);
    setState(() => _mode = mode);
  }

  Future<void> _setSchedule() async {
    TimeOfDay? startTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (startTime != null) {
      TimeOfDay? endTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (endTime != null) {
        final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
        
        await FirebaseService.database.child('schedule/$deviceId').set({'start': start, 'end': end});
        setState(() {
          _startTime = start;
          _endTime = end;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated!'), backgroundColor: AppColors.primaryGreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHeavyDevice = deviceId == 'motor1' || deviceId == 'fan1';
    
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [deviceColor, deviceColor.withOpacity(0.7)]),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        const Text('Device Detail', style: TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: Icon(deviceIcon, color: Colors.white, size: 32)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(deviceLabel, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(_mode, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Power Card
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _isOn ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(_isOn ? 'ONLINE' : 'OFFLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _isOn ? AppColors.primaryGreen : AppColors.error)),
                            ),
                            const SizedBox(height: 8),
                            const Text('Power Status', style: TextStyle(fontSize: 14, color: AppColors.mediumGray)),
                            Text(_isOn ? 'Device is ON' : 'Device is OFF', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        GestureDetector(
                          onTap: _togglePower,
                          child: Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              gradient: _isOn ? LinearGradient(colors: [deviceColor, deviceColor.withOpacity(0.7)]) : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: (_isOn ? deviceColor : Colors.grey).withOpacity(0.4), blurRadius: 15)],
                            ),
                            child: Icon(_isOn ? Icons.power_settings_new : Icons.power_off, color: Colors.white, size: 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Peak Hour Warning
                  if (_isPeakHourNow && isHeavyDevice)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Peak hours ($_peakStart - $_peakEnd): Device can be turned ON but buzzer will activate', style: const TextStyle(fontSize: 12, color: AppColors.error))),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 14),
                  
                  // Mode Card
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Operation Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildModeChip('MANUAL', Icons.touch_app, _mode == 'MANUAL'),
                            const SizedBox(width: 10),
                            _buildModeChip('AUTO', Icons.auto_awesome, _mode == 'AUTO'),
                            const SizedBox(width: 10),
                            _buildModeChip('SCHEDULE', Icons.schedule, _mode == 'SCHEDULE'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Schedule Card
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            IconButton(onPressed: _setSchedule, icon: Icon(Icons.edit, color: deviceColor, size: 20)),
                          ],
                        ),
                        if (_startTime.isNotEmpty || _endTime.isNotEmpty)
                          Column(
                            children: [
                              if (_startTime.isNotEmpty) _buildScheduleRow('Start Time', _startTime),
                              if (_endTime.isNotEmpty) const SizedBox(height: 8),
                              if (_endTime.isNotEmpty) _buildScheduleRow('End Time', _endTime),
                            ],
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('No schedule set. Tap edit to add.')),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Usage Card
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Energy Usage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('This Device', '${(_deviceUsage * 1000).toStringAsFixed(2)} Wh', deviceColor)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard('Total Home', '${_totalUnits.toStringAsFixed(2)} kWh', AppColors.primaryGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setMode(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderGray, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSelected ? Colors.white : AppColors.mediumGray),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.darkGray)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.mediumGray)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: AppColors.bgLightBlue, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentAmber)),
          ),
        ],
      ),
    );
  }
}