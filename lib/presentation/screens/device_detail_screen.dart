import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _isOn = true;
  double _sliderValue = 50.0;
  String _mode = 'auto';
  double _fanSpeedValue = 24.0; // Separate variable for fan speed

  @override
  void initState() {
    super.initState();
    _isOn = widget.device['isOn'];
    _sliderValue = widget.device['type'] == 'fan' ? 24.0 : 50.0;
    _fanSpeedValue = 24.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: Column(
        children: [
          // App Bar
          Container(
            color: widget.device['color'],
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.device['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    color: widget.device['color'],
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          widget.device['icon'],
                          size: 60,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                child: Column(
                  children: [
                    // Power Control Card
                    _buildPowerControlCard(),
                    
                    const SizedBox(height: 14),
                    
                    // Device Specific Controls
                    _buildDeviceControls(),
                    
                    const SizedBox(height: 14),
                    
                    // Mode Selection
                    _buildModeCard(),
                    
                    const SizedBox(height: 14),
                    
                    // Statistics Card - FIXED overflow
                    _buildStatisticsCard(),
                    
                    const SizedBox(height: 14),
                    
                    // Scheduling Card
                    _buildSchedulingCard(),
                    
                    const SizedBox(height: 14),
                    
                    // Additional Features
                    _buildFeaturesCard(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerControlCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _isOn ? AppColors.primaryGreen : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isOn ? 'ONLINE' : 'OFFLINE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isOn ? AppColors.primaryGreen : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.device['status'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
                
                // Power Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOn = !_isOn;
                    });
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: _isOn 
                          ? LinearGradient(
                              colors: [
                                widget.device['color'],
                                widget.device['color'].withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[400]!,
                              ],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isOn 
                              ? widget.device['color'].withOpacity(0.4)
                              : Colors.grey.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isOn ? Icons.power_settings_new : Icons.power_off,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(Icons.timer, 'Schedule'),
                _buildQuickAction(Icons.auto_awesome, 'Auto'),
                _buildQuickAction(Icons.settings, 'Settings'),
                _buildQuickAction(Icons.history, 'History'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControls() {
    Widget controls;
    
    switch (widget.device['type']) {
      case 'fan':
        controls = _buildFanControls();
        break;
      case 'bulb':
        controls = _buildBulbControls();
        break;
      case 'curtains':
        controls = _buildCurtainControls();
        break;
      case 'water_motor':
        controls = _buildWaterMotorControls();
        break;
      default:
        controls = const SizedBox();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            controls,
          ],
        ),
      ),
    );
  }

  Widget _buildFanControls() {
    return Column(
      children: [
        // Temperature
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Temperature',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              '${_sliderValue.round()}°C',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.device['color'],
              ),
            ),
          ],
        ),
        Slider(
          value: _sliderValue,
          min: 16,
          max: 30,
          divisions: 14,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
          activeColor: widget.device['color'],
          inactiveColor: AppColors.borderGray,
        ),
        
        const SizedBox(height: 16),
        
        // Fan Speed - FIXED crash issue
        Text(
          'Fan Speed',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1, 2, 3, 4, 5].map((speed) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _fanSpeedValue = speed * 10.0; // Use separate variable
                });
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _fanSpeedValue == speed * 10.0 
                      ? widget.device['color'] 
                      : AppColors.bgLightBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.device['color'],
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$speed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _fanSpeedValue == speed * 10.0 
                          ? Colors.white 
                          : widget.device['color'],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBulbControls() {
    return Column(
      children: [
        // Brightness
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Brightness',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              '${_sliderValue.round()}%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.device['color'],
              ),
            ),
          ],
        ),
        Slider(
          value: _sliderValue,
          min: 0,
          max: 100,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
          activeColor: widget.device['color'],
          inactiveColor: AppColors.borderGray,
        ),
        
        const SizedBox(height: 16),
        
        // Color Temperature
        Text(
          'Color Temperature',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildColorOption('Warm', Icons.lightbulb, Colors.orange[300]!),
              const SizedBox(width: 8),
              _buildColorOption('Cool', Icons.lightbulb_outline, Colors.blue[300]!),
              const SizedBox(width: 8),
              _buildColorOption('Day', Icons.wb_sunny, Colors.yellow[300]!),
              const SizedBox(width: 8),
              _buildColorOption('Night', Icons.nightlight, Colors.purple[300]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurtainControls() {
    return Column(
      children: [
        // Position
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Position',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              '${_sliderValue.round()}% Open',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.device['color'],
              ),
            ),
          ],
        ),
        Slider(
          value: _sliderValue,
          min: 0,
          max: 100,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
          activeColor: widget.device['color'],
          inactiveColor: AppColors.borderGray,
        ),
        
        const SizedBox(height: 16),
        
        // Quick Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCurtainButton(Icons.arrow_upward, 'Open'),
            _buildCurtainButton(Icons.pause, 'Stop'),
            _buildCurtainButton(Icons.arrow_downward, 'Close'),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterMotorControls() {
    return Column(
      children: [
        // Tank Level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tank Level',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              '75%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.device['color'],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Tank Visual
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.borderGray,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.device['color'],
                      widget.device['color'].withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              Center(
                child: Text(
                  '75% Filled',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Auto Settings
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Off',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  'When tank reaches 95%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: widget.device['color'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operation Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildModeChip('Auto', Icons.auto_awesome),
                const SizedBox(width: 8),
                _buildModeChip('Manual', Icons.touch_app),
                const SizedBox(width: 8),
                _buildModeChip('Schedule', Icons.schedule),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats Grid - FIXED overflow
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4, // Made taller to prevent overflow
              padding: EdgeInsets.zero,
              children: [
                _buildStatItem('Today', '12.5 kWh', '75 W'),
                _buildStatItem('This Week', '87.3 kWh', '520 W'),
                _buildStatItem('This Month', '1,240 kWh', '480 W'),
                _buildStatItem('Savings', '₹2,450', '20%'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Energy Efficiency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energy Efficiency',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  '85%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.85,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              borderRadius: BorderRadius.circular(8),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.add_circle,
                    color: widget.device['color'],
                    size: 26,
                  ),
                ),
              ],
            ),
            
            _buildScheduleItem('Weekdays', '9:00 AM - 11:00 PM', true),
            const SizedBox(height: 8),
            _buildScheduleItem('Weekends', '10:00 AM - 12:00 AM', true),
            const SizedBox(height: 8),
            _buildScheduleItem('Away Mode', 'All devices OFF', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip('Motion Sensor'),
                _buildFeatureChip('Temperature Control'),
                _buildFeatureChip('Energy Saving'),
                _buildFeatureChip('Remote Access'),
                _buildFeatureChip('Voice Control'),
                _buildFeatureChip('Auto Scheduling'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildQuickAction(IconData icon, String label) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: widget.device['color'].withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.device['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: widget.device['color'],
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String label, IconData icon, Color color) {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurtainButton(IconData icon, String label) {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.device['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: widget.device['color'],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, IconData icon) {
    bool isSelected = _mode.toLowerCase() == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mode = label.toLowerCase();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? widget.device['color'] : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? widget.device['color'] : AppColors.borderGray,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.mediumGray,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String period, String energy, String power) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgLightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderGray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            energy,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.device['color'],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Avg: $power',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String title, String time, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? widget.device['color'].withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? widget.device['color'].withOpacity(0.3) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isActive,
              onChanged: (value) {},
              activeColor: widget.device['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.device['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.device['color'].withOpacity(0.2),
        ),
      ),
      child: Text(
        feature,
        style: TextStyle(
          fontSize: 12,
          color: widget.device['color'],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}