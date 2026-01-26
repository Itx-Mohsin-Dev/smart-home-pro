import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  List<AutomationRule> rules = [
    AutomationRule(
      name: 'Good Morning',
      icon: Icons.wb_sunny_outlined,
      color: AppColors.accentAmber,
      description: 'Lights ON, Curtains open at 7:00 AM',
      isActive: true,
      devices: ['All Lights', 'Curtains', 'Coffee Maker'],
    ),
    AutomationRule(
      name: 'Away Mode',
      icon: Icons.door_front_door_outlined,
      color: AppColors.primaryBlue,
      description: 'Turn off all devices when leaving',
      isActive: true,
      devices: ['All Devices'],
    ),
    AutomationRule(
      name: 'Good Night',
      icon: Icons.nightlight_outlined,
      color: AppColors.accentPurple,
      description: 'Lights OFF, AC to 24°C at 11:00 PM',
      isActive: true,
      devices: ['All Lights', 'AC', 'Curtains'],
    ),
    AutomationRule(
      name: 'Energy Saving',
      icon: Icons.energy_savings_leaf_outlined,
      color: AppColors.primaryGreen,
      description: 'Reduce power during peak hours',
      isActive: false,
      devices: ['AC', 'Water Motor', 'Lights'],
    ),
    AutomationRule(
      name: 'Movie Time',
      icon: Icons.movie_outlined,
      color: Colors.deepPurple,
      description: 'Dim lights, close curtains',
      isActive: true,
      devices: ['Living Room Lights', 'Curtains'],
    ),
    AutomationRule(
      name: 'Party Mode',
      icon: Icons.celebration_outlined,
      color: Colors.pink,
      description: 'Color lights, music system ON',
      isActive: false,
      devices: ['Smart Lights', 'Music System'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: AppColors.darkGray,
                        ),
                        Text(
                          'Automation',
                          style: AppTextStyles.h2(context).copyWith(
                            fontSize: 22,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outlined, size: 22),
                          onPressed: () {},
                          color: AppColors.primaryBlue,
                        ),
                      ],
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
                    // Scene Modes
                    _buildSceneModes(),
                    
                    const SizedBox(height: 14),
                    
                    // Automation Rules
                    _buildRulesList(),
                    
                    const SizedBox(height: 14),
                    
                    // Create New Button
                    _buildCreateButton(),
                    
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

  Widget _buildSceneModes() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scene Modes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSceneCard(
                  'Good Morning',
                  Icons.wb_sunny,
                  AppColors.accentAmber,
                  '7:00 AM',
                ),
                const SizedBox(width: 10),
                _buildSceneCard(
                  'Away Mode',
                  Icons.door_front_door,
                  AppColors.primaryBlue,
                  'Geo-fenced',
                ),
                const SizedBox(width: 10),
                _buildSceneCard(
                  'Good Night',
                  Icons.nightlight,
                  AppColors.accentPurple,
                  '11:00 PM',
                ),
                const SizedBox(width: 10),
                _buildSceneCard(
                  'Movie Time',
                  Icons.movie,
                  Colors.deepPurple,
                  'Manual',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList() {
    return Container(
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
              Text(
                'Automation Rules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${rules.where((r) => r.isActive).length} Active',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildRuleCard(rules[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create New Automation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tap to create custom rules',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneCard(String title, IconData icon, Color color, String time) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(AutomationRule rule) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: rule.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(rule.icon, color: rule.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rule.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rule.isActive 
                              ? AppColors.primaryGreen.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rule.isActive ? 'ACTIVE' : 'INACTIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: rule.isActive 
                                ? AppColors.primaryGreen 
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rule.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: rule.devices.map((device) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bgLightBlue,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderGray, width: 0.5),
                        ),
                        child: Text(
                          device,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: rule.isActive,
                    onChanged: (value) {
                      setState(() {
                        rule.isActive = value;
                      });
                    },
                    activeColor: rule.color,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 18),
                  color: AppColors.mediumGray,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AutomationRule {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  bool isActive;
  final List<String> devices;

  AutomationRule({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.isActive,
    required this.devices,
  });
}