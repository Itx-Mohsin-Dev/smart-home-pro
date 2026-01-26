import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';
import 'package:smart_home_pro/presentation/screens/device_detail_screen.dart';
import 'package:smart_home_pro/presentation/screens/statistics_screen.dart';
import 'package:smart_home_pro/presentation/screens/automation_screen.dart';
import 'package:smart_home_pro/presentation/screens/profile_screen.dart';
import 'package:smart_home_pro/presentation/screens/notification_screen.dart';

// Device class (simple version)
class Device {
  final String id;
  final String name;
  final String type;
  final bool isOn;
  final String status;
  final double powerConsumption;
  final String location;
  final DateTime lastUpdated;
  final Map<String, dynamic> settings;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.status,
    required this.powerConsumption,
    required this.location,
    required this.lastUpdated,
    required this.settings,
  });

  // Factory constructors
  factory Device.fan() {
    return Device(
      id: 'fan_001',
      name: 'Living Room Fan',
      type: 'fan',
      isOn: true,
      status: 'Temperature: 24°C',
      powerConsumption: 75.5,
      location: 'Living Room',
      lastUpdated: DateTime.now(),
      settings: {},
    );
  }

  factory Device.bulb() {
    return Device(
      id: 'bulb_001',
      name: 'Living Room Lights',
      type: 'bulb',
      isOn: true,
      status: 'Motion detected',
      powerConsumption: 45.2,
      location: 'Living Room',
      lastUpdated: DateTime.now(),
      settings: {},
    );
  }

  factory Device.curtains() {
    return Device(
      id: 'curtains_001',
      name: 'Curtains',
      type: 'curtains',
      isOn: false,
      status: 'Auto - Light based',
      powerConsumption: 12.3,
      location: 'Living Room',
      lastUpdated: DateTime.now(),
      settings: {},
    );
  }

  factory Device.waterMotor() {
    return Device(
      id: 'water_motor_001',
      name: 'Water Motor',
      type: 'water_motor',
      isOn: true,
      status: 'Tank: 75%',
      powerConsumption: 850.0,
      location: 'Terrace',
      lastUpdated: DateTime.now(),
      settings: {},
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _hasDevices = false;
  List<Device> _devices = [];

  void _addDevice() {
    setState(() {
      _hasDevices = true;
      _devices = [
        Device.fan(),
        Device.bulb(),
        Device.curtains(),
        Device.waterMotor(),
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ESP32 connected successfully! 4 devices added.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _navigateToScreen(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1 && _hasDevices) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StatisticsScreen()),
      );
    } else if (index == 2 && _hasDevices) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AutomationScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      // Show message for disabled tabs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connect devices first to access this feature'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: SafeArea(
        bottom: false,
        child: _selectedIndex == 0 
            ? _hasDevices 
                ? _buildDashboardWithDevices()
                : _buildEmptyDashboard()
            : _buildPlaceholderScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateToScreen,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGray,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22, color: _selectedIndex == 0 ? AppColors.primaryBlue : AppColors.mediumGray),
            activeIcon: const Icon(Icons.home, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.insights_outlined, 
              size: 22, 
              color: !_hasDevices ? Colors.grey[400] : (_selectedIndex == 1 ? AppColors.primaryBlue : AppColors.mediumGray),
            ),
            activeIcon: const Icon(Icons.insights, size: 22),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.auto_awesome_outlined, 
              size: 22, 
              color: !_hasDevices ? Colors.grey[400] : (_selectedIndex == 2 ? AppColors.primaryBlue : AppColors.mediumGray),
            ),
            activeIcon: const Icon(Icons.auto_awesome, size: 22),
            label: 'Automation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined, size: 22, color: _selectedIndex == 3 ? AppColors.primaryBlue : AppColors.mediumGray),
            activeIcon: const Icon(Icons.person, size: 22),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDashboard() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SmartHome Pro',
                              style: AppTextStyles.h3(context).copyWith(
                                fontSize: 20,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotificationScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.notifications_outlined, size: 22),
                              color: AppColors.darkGray,
                            ),
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryBlue,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Hero Illustration
                  Container(
                    height: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue.withOpacity(0.1), AppColors.primaryGreen.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.smart_toy,
                              size: 40,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bolt,
                              size: 32,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home,
                              size: 50,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Start Your Smart Home Journey',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGray,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Connect your ESP32 device to control appliances, save energy, and automate your home',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.mediumGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Add Device Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _addDevice,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.primaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.4),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Connect Your First Device',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Tap to setup ESP32',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Try Demo Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton(
                      onPressed: _addDevice,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Try Demo Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Steps Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to get started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(1, 'Power on ESP32', Icons.power_settings_new, AppColors.primaryBlue),
                        const SizedBox(height: 12),
                        _buildStepCard(2, 'Connect to WiFi', Icons.wifi, AppColors.primaryGreen),
                        const SizedBox(height: 12),
                        _buildStepCard(3, 'Scan QR Code', Icons.qr_code_scanner, AppColors.accentPurple),
                        const SizedBox(height: 12),
                        _buildStepCard(4, 'Control Devices', Icons.phone_android, AppColors.accentAmber),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardWithDevices() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'John Doe',
                            style: AppTextStyles.h3(context).copyWith(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications_outlined, size: 22),
                            color: AppColors.darkGray,
                            padding: const EdgeInsets.all(6),
                          ),
                          const SizedBox(width: 4),
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryBlue,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 18),
                  
                  // Savings Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.savings_outlined,
                            size: 22,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Savings',
                                style: AppTextStyles.bodySmall(context).copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹2,450',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '20% less than last month',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  // Device Grid Title with Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Devices',
                        style: AppTextStyles.h2(context).copyWith(
                          fontSize: 20,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _addDevice,
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Device Grid 2x2 - BIGGER CARDS
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0, // Bigger square cards
                    padding: EdgeInsets.zero,
                    children: _devices.map((device) {
                      return _buildDeviceCard(
                        context: context,
                        device: device,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  // Quick Actions Title
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.h2(context).copyWith(
                      fontSize: 20,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Quick Actions - Bigger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(Icons.nightlight_outlined, 'Good Night'),
                      _buildQuickAction(Icons.wb_sunny_outlined, 'All Off'),
                      _buildQuickAction(Icons.door_front_door_outlined, 'Away Mode'),
                      _buildQuickAction(Icons.coffee_outlined, 'Morning Scene'),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgLightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.devices,
              size: 60,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connect Devices First',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please add devices from the Home screen to access this feature',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGray,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int number, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required Device device,
  }) {
    Color color;
    IconData icon;
    
    switch (device.type) {
      case 'fan':
        color = AppColors.primaryBlue;
        icon = Icons.ac_unit;
        break;
      case 'bulb':
        color = AppColors.accentAmber;
        icon = Icons.lightbulb_outline;
        break;
      case 'curtains':
        color = AppColors.accentPurple;
        icon = Icons.curtains_closed;
        break;
      case 'water_motor':
        color = AppColors.primaryGreen;
        icon = Icons.water_damage_outlined;
        break;
      default:
        color = AppColors.primaryBlue;
        icon = Icons.devices;
    }
    
    return GestureDetector(
      onTap: () {
        Map<String, dynamic> deviceData = {
          'name': device.name,
          'type': device.type,
          'isOn': device.isOn,
          'status': device.status,
          'color': color,
          'icon': icon,
        };
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceDetailScreen(device: deviceData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: device.isOn,
                    onChanged: (value) {},
                    activeColor: color,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              device.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              device.status,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: device.powerConsumption / 1000,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${device.powerConsumption.toStringAsFixed(1)} W',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.mediumGray,
                  ),
                ),
                Text(
                  _hasDevices ? 'Connected' : 'Demo',
                  style: TextStyle(
                    fontSize: 10,
                    color: _hasDevices ? AppColors.primaryGreen : AppColors.mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue.withOpacity(0.8), AppColors.primaryGreen.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}