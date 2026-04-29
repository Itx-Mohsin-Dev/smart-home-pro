import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';
import 'package:smart_home_pro/presentation/screens/device_detail_screen.dart';
import 'package:smart_home_pro/presentation/screens/statistics_screen.dart';
import 'package:smart_home_pro/presentation/screens/automation_screen.dart';
import 'package:smart_home_pro/presentation/screens/profile_screen.dart';
import 'package:smart_home_pro/presentation/screens/notification_screen.dart';
import 'package:smart_home_pro/presentation/screens/logs_screen.dart';
import 'package:smart_home_pro/presentation/screens/unauthorized_screen.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:smart_home_pro/services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _hasDevices = false;
  double _totalUnits = 0;
  double _allowedUnits = 200;
  bool _isEditingUnits = false;
  final TextEditingController _unitsController = TextEditingController();
  
  // Correct device IDs as per database
  final List<String> _deviceIds = ['light1', 'fan1', 'curtain1', 'motor1'];
  final Map<String, String> _deviceLabels = {
    'light1': 'Lights',
    'fan1': 'Fan',
    'curtain1': 'Curtains',
    'motor1': 'Water Motor',
  };
  final Map<String, Color> _deviceColors = {
    'light1': AppColors.accentAmber,
    'fan1': AppColors.primaryBlue,
    'curtain1': AppColors.accentPurple,
    'motor1': AppColors.primaryGreen,
  };
  final Map<String, IconData> _deviceIcons = {
    'light1': Icons.lightbulb_outline,
    'fan1': Icons.ac_unit,
    'curtain1': Icons.curtains_closed,
    'motor1': Icons.water_damage_outlined,
  };

  @override
  void initState() {
    super.initState();
    _checkMonthReset();
    _loadData();
    _checkDeviceStatus();
    _checkUnitsAlert();
    _unitsController.text = _allowedUnits.toString();
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  // Check and reset on 1st of month
  Future<void> _checkMonthReset() async {
    final now = DateTime.now();
    final lastResetSnapshot = await FirebaseService.database.child('settings/last_reset').once();
    String? lastReset = lastResetSnapshot.snapshot.value?.toString();
    
    if (lastReset == null || _shouldReset(now, lastReset)) {
      // Reset total consumed units
      await FirebaseService.database.child('usage/total_consumed_units').set(0);
      
      // Reset device usage
      for (var deviceId in _deviceIds) {
        await FirebaseService.database.child('usage/devices/$deviceId').set(0);
      }
      
      // Reset allowed units to default 200
      await FirebaseService.database.child('settings/allowed_units').set(200);
      await FirebaseService.database.child('settings/last_reset').set(now.toIso8601String());
      
      setState(() {
        _totalUnits = 0;
        _allowedUnits = 200;
        _unitsController.text = '200';
      });
      
      // Send notification
      await _sendNotification('Monthly Reset', 'Your energy usage has been reset for the new month.', 'info');
    }
  }

  bool _shouldReset(DateTime now, String lastReset) {
    try {
      final lastResetDate = DateTime.parse(lastReset);
      return now.month != lastResetDate.month || now.year != lastResetDate.year;
    } catch (e) {
      return true;
    }
  }

  Future<void> _sendNotification(String title, String message, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database.child('notifications/${user.uid}').push().set({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });
    }
  }

  Future<void> _updateAllowedUnits() async {
    final newUnits = double.tryParse(_unitsController.text);
    if (newUnits != null && newUnits > 0) {
      await FirebaseService.database.child('settings/allowed_units').set(newUnits);
      setState(() {
        _allowedUnits = newUnits;
        _isEditingUnits = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit limit updated!'), backgroundColor: AppColors.primaryGreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _loadData() async {
    await _loadTotalUnits();
    await _loadSettings();
    await _checkExistingDevices();
  }

  Future<void> _loadTotalUnits() async {
    final snapshot = await FirebaseService.database.child('usage/total_consumed_units').once();
    if (snapshot.snapshot.value != null) {
      setState(() {
        _totalUnits = (snapshot.snapshot.value as num).toDouble();
      });
    }
  }

  Future<void> _loadSettings() async {
    final snapshot = await FirebaseService.database.child('settings/allowed_units').once();
    if (snapshot.snapshot.value != null) {
      setState(() {
        _allowedUnits = (snapshot.snapshot.value as num).toDouble();
        _unitsController.text = _allowedUnits.toString();
      });
    }
  }

  Future<void> _checkExistingDevices() async {
    final snapshot = await FirebaseService.database.child('devices/light1').once();
    if (snapshot.snapshot.value != null) {
      setState(() => _hasDevices = true);
    }
  }

  void _checkDeviceStatus() {
    FirebaseService.database.child('devices').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() => _hasDevices = true);
      }
    });
  }

  void _checkUnitsAlert() {
    FirebaseService.database.child('usage/total_consumed_units').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final units = (event.snapshot.value as num).toDouble();
        setState(() => _totalUnits = units);
        
        if (units >= _allowedUnits * 0.8 && units < _allowedUnits) {
          _sendNotification('Unit Limit Warning', 'You have used ${units.toStringAsFixed(2)} out of $_allowedUnits units!', 'alert');
        } else if (units >= _allowedUnits) {
          _sendNotification('Unit Limit Exceeded', 'You have exceeded your limit of $_allowedUnits units!', 'alert');
        }
      }
    });
  }

  Future<void> _toggleDevice(String deviceId, bool currentState) async {
    final newState = currentState ? 'OFF' : 'ON';
    await FirebaseService.database.child('devices/$deviceId/state').set(newState);
    
    // Log the action
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database.child('logs/devices/$deviceId').push().set({
        'state': newState,
        'mode': 'MANUAL',
        'timestamp': DateTime.now().toIso8601String(),
        'userId': user.uid,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Authorization Check
    final currentUser = AuthService.getCurrentUser();
    if (!AuthService.isAuthorizedUser(currentUser)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/unauthorized');
      });
      return const Scaffold(
        backgroundColor: AppColors.bgLightBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double unitPercentage = _allowedUnits > 0 ? (_totalUnits / _allowedUnits * 100).clamp(0, 100) : 0;

    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: SafeArea(
        bottom: false,
        child: _hasDevices ? _buildDashboardWithDevices(unitPercentage) : _buildEmptyDashboard(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() => _selectedIndex = index);
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AutomationScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LogsScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGray,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'Auto'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildEmptyDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices, size: 80, color: AppColors.primaryBlue),
          const SizedBox(height: 20),
          const Text('No Devices Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Connect your ESP32 device to get started'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => setState(() => _hasDevices = true),
            child: const Text('Connect Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardWithDevices(double unitPercentage) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.split(' ')[0] ?? user?.email?.split('@')[0] ?? 'User';
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with clickable profile avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good ${_getTimeGreeting()},',
                            style: const TextStyle(fontSize: 12, color: AppColors.mediumGray)),
                        const SizedBox(height: 2),
                        Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                          icon: const Icon(Icons.notifications_outlined, size: 22),
                        ),
                        InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                          borderRadius: BorderRadius.circular(20),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryBlue,
                            child: Icon(Icons.person, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Unit Usage Card with Edit Option
                GestureDetector(
                  onTap: () {
                    _unitsController.text = _allowedUnits.toString();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Monthly Unit Limit'),
                        content: TextField(
                          controller: _unitsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Maximum Units per Month',
                            border: OutlineInputBorder(),
                            hintText: 'Enter limit in kWh',
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () {
                            Navigator.pop(context);
                            _updateAllowedUnits();
                          }, child: const Text('Save')),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: _totalUnits >= _allowedUnits ? 
                          LinearGradient(colors: [AppColors.error, AppColors.error.withOpacity(0.8)]) :
                          LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Monthly Energy Limit', style: TextStyle(color: Colors.white, fontSize: 12)),
                            const Icon(Icons.edit, color: Colors.white, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_totalUnits.toStringAsFixed(2)} / ${_allowedUnits.toStringAsFixed(0)} units',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${unitPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: unitPercentage / 100,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          color: unitPercentage > 80 ? Colors.orange : Colors.white,
                        ),
                        if (_totalUnits >= _allowedUnits)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('⚠️ Limit exceeded! Reduce usage.', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        const SizedBox(height: 4),
                        Text('Tap to edit limit', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Devices Grid
                const Text('My Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                
                StreamBuilder(
                  stream: FirebaseService.database.child('devices').onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final devicesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ?? {};
                    
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                      children: _deviceIds.map((deviceId) {
                        final deviceData = devicesMap[deviceId] as Map<dynamic, dynamic>? ?? {};
                        final isOn = deviceData['state'] == 'ON';
                        final mode = deviceData['mode'] ?? 'MANUAL';
                        
                        return _buildDeviceCard(deviceId, isOn, mode);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildDeviceCard(String deviceId, bool isOn, String mode) {
    final label = _deviceLabels[deviceId]!;
    final color = _deviceColors[deviceId]!;
    final icon = _deviceIcons[deviceId]!;
    
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => DeviceDetailScreen(device: {'deviceId': deviceId, 'label': label, 'color': color, 'icon': icon})
      )),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 18)),
                Transform.scale(scale: 0.75,
                    child: Switch(value: isOn, onChanged: (_) => _toggleDevice(deviceId, isOn), activeColor: color)),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(mode, style: const TextStyle(fontSize: 11, color: AppColors.mediumGray)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: isOn ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(isOn ? 'ON' : 'OFF', style: TextStyle(fontSize: 9, color: isOn ? AppColors.primaryGreen : AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}