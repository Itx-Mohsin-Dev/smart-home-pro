import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:smart_home_pro/services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  String _profileImageUrl = '';
  String _peakStart = '18:00';
  String _peakEnd = '23:00';
  int _connectedDevices = 0;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
    _loadDeviceCount();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    _currentUser = AuthService.getCurrentUser();
    
    if (_currentUser != null) {
      final imageSnapshot = await FirebaseService.database
          .child('users/${_currentUser!.uid}/profileImage')
          .once();
      if (imageSnapshot.snapshot.value != null) {
        setState(() {
          _profileImageUrl = imageSnapshot.snapshot.value.toString();
        });
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadSettings() async {
    final peakStartSnap = await FirebaseService.database.child('settings/peak_start').once();
    if (peakStartSnap.snapshot.value != null) {
      setState(() => _peakStart = peakStartSnap.snapshot.value.toString());
    }
    
    final peakEndSnap = await FirebaseService.database.child('settings/peak_end').once();
    if (peakEndSnap.snapshot.value != null) {
      setState(() => _peakEnd = peakEndSnap.snapshot.value.toString());
    }
  }

  Future<void> _loadDeviceCount() async {
    final devicesSnapshot = await FirebaseService.database.child('devices').once();
    if (devicesSnapshot.snapshot.value != null) {
      final devices = devicesSnapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _connectedDevices = devices.length;
      });
    }
  }

  Future<void> _updatePeakHours() async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_peakStart.split(':')[0]),
        minute: int.parse(_peakStart.split(':')[1]),
      ),
    );
    
    if (startTime != null) {
      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(_peakEnd.split(':')[0]),
          minute: int.parse(_peakEnd.split(':')[1]),
        ),
      );
      
      if (endTime != null) {
        final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
        
        await FirebaseService.database.child('settings/peak_start').set(start);
        await FirebaseService.database.child('settings/peak_end').set(end);
        
        setState(() {
          _peakStart = start;
          _peakEnd = end;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peak hours updated!')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null && _currentUser != null) {
      setState(() => _isUploading = true);
      
      try {
        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${_currentUser!.uid}.jpg');
        
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();
        
        await FirebaseService.database
            .child('users/${_currentUser!.uid}/profileImage')
            .set(downloadUrl);
        
        setState(() {
          _profileImageUrl = downloadUrl;
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      } catch (e) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                // Redirect to onboarding/login screen
                context.go('/onboarding');
              }
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help, color: AppColors.primaryBlue),
            SizedBox(width: 10),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('How to connect devices?', '1. Open the app\n2. Click "Connect Device"\n3. Scan QR code on ESP32\n4. Follow on-screen instructions'),
            const SizedBox(height: 12),
            _buildHelpItem('Device not responding?', '• Check if device is powered ON\n• Ensure WiFi connection is stable\n• Restart the ESP32 device\n• Try reconnecting from settings'),
            const SizedBox(height: 12),
            _buildHelpItem('Energy saving tips', '• Use devices during off-peak hours\n• Enable AUTO mode for fans\n• Schedule water motor properly\n• Keep curtains closed during peak sun'),
            const SizedBox(height: 12),
            _buildHelpItem('Contact Us', 'Email: support@smarthomepro.com\nPhone: +92 300 1234567\nHours: Mon-Fri 9AM-6PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(answer, style: const TextStyle(fontSize: 13, color: AppColors.mediumGray)),
        ),
      ],
    );
  }

  void _showTermsPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.description, color: AppColors.primaryBlue),
            SizedBox(width: 10),
            Text('Terms & Privacy'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Terms of Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('By using SmartHome Pro, you agree to these terms. You are responsible for all activities under your account. Do not misuse our services.', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                const Text('Privacy Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('We collect device usage data to provide energy analytics. Your personal information is never shared with third parties. You can delete your data anytime.', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                const Text('Data Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('All data is encrypted and stored securely on Firebase. We implement industry-standard security measures to protect your information.', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _profileImageUrl.isNotEmpty
                          ? Image.network(_profileImageUrl, fit: BoxFit.cover)
                          : _currentUser?.photoURL != null
                              ? Image.network(_currentUser!.photoURL!, fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  child: Icon(Icons.person, size: 50, color: AppColors.primaryBlue),
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Name
            Text(
              _currentUser?.displayName ?? 'User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _currentUser?.email ?? '',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            
            const SizedBox(height: 24),
            
            // Account Information Section
            _buildSectionTitle('Account Information'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _buildInfoItem(Icons.email, 'Email', _currentUser?.email ?? ''),
                  _buildDivider(),
                  _buildInfoItem(Icons.calendar_today, 'Member Since', 
                      _currentUser?.metadata.creationTime != null
                          ? '${_currentUser!.metadata.creationTime!.day}/${_currentUser!.metadata.creationTime!.month}/${_currentUser!.metadata.creationTime!.year}'
                          : 'New User'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Home Settings Section
            _buildSectionTitle('Home Settings'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.timer,
                    title: 'Peak Hours',
                    subtitle: '$_peakStart - $_peakEnd (Tap to edit)',
                    onTap: _updatePeakHours,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.devices,
                    title: 'Connected Devices',
                    subtitle: '$_connectedDevices devices connected',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Support Section
            _buildSectionTitle('Support'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQs, guides and contact',
                    onTap: _showHelpSupport,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Privacy',
                    subtitle: 'Read our terms and privacy policy',
                    onTap: _showTermsPrivacy,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('SmartHome Pro'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.home, size: 40, color: Colors.white),
                              ),
                              const SizedBox(height: 15),
                              const Text('SmartHome Pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              const Text('Version 1.0.0', style: TextStyle(fontSize: 14, color: AppColors.mediumGray)),
                              const SizedBox(height: 5),
                              const Text('IoT Home Automation System', style: TextStyle(fontSize: 13)),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              const Text('© 2025 SmartHome Pro. All rights reserved.', style: TextStyle(fontSize: 11, color: AppColors.mediumGray)),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: AppColors.error),
                ),
                title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Sign out of your account'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
                onTap: _logout,
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGray,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
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
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60, color: AppColors.borderGray);
  }
}