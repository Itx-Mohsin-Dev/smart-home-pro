import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _energySaving = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: const CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
                                ),
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'john.doe@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Subscription Card
              _buildSubscriptionCard(),
              
              // Settings Sections
              _buildSectionTitle('Preferences'),
              _buildPreferenceSettings(),
              
              _buildSectionTitle('Account'),
              _buildAccountSettings(),
              
              _buildSectionTitle('Home Settings'),
              _buildHomeSettings(),
              
              _buildSectionTitle('Support'),
              _buildSupportSettings(),
              
              const SizedBox(height: 30),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentPurple, AppColors.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SmartHome Pro Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Advanced analytics • Unlimited devices • Priority support',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGray,
        ),
      ),
    );
  }

  Widget _buildPreferenceSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Receive alerts and updates',
              trailing: Switch(
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Switch to dark theme',
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'App language',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                icon: const Icon(Icons.arrow_drop_down),
                underline: const SizedBox(),
                items: ['English', 'Hindi', 'Urdu', 'Spanish', 'French']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Name, email, phone',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.family_restroom_outlined,
              title: 'Family Members',
              subtitle: 'Manage family access',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.shield_outlined,
              title: 'Privacy & Security',
              subtitle: 'Data and privacy settings',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.home_outlined,
              title: 'My Homes',
              subtitle: 'Manage multiple homes',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('2 homes', style: TextStyle(color: AppColors.mediumGray)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: AppColors.mediumGray),
                ],
              ),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.energy_savings_leaf_outlined,
              title: 'Energy Saving Mode',
              subtitle: 'Optimize for savings',
              trailing: Switch(
                value: _energySaving,
                onChanged: (value) {
                  setState(() {
                    _energySaving = value;
                  });
                },
                activeColor: AppColors.primaryGreen,
              ),
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.schedule_outlined,
              title: 'Peak Hours',
              subtitle: 'Set peak hour schedule',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.devices_outlined,
              title: 'Connected Devices',
              subtitle: '4 devices connected',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and guides',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Share your experience',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
              subtitle: 'Legal documents',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'About App',
              subtitle: 'Version 1.0.0',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.logout_outlined,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
              onTap: () {},
              textColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryBlue),
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
                        color: textColor ?? AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.borderGray,
      ),
    );
  }
}