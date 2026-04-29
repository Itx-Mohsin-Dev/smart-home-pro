import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<DeviceLog> _logs = [];
  bool _isLoading = true;
  String _selectedDevice = 'all';
  
  final List<String> _devices = ['all', 'light1', 'fan1', 'curtain1', 'motor1'];
  final Map<String, String> _deviceLabels = {
    'all': 'All Devices',
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

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    _logs = [];
    
    for (var device in ['light1', 'fan1', 'curtain1', 'motor1']) {
      final snapshot = await FirebaseService.database.child('logs/devices/$device').once();
      if (snapshot.snapshot.value != null) {
        final logsMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        logsMap.forEach((key, value) {
          final logData = value as Map<dynamic, dynamic>;
          _logs.add(DeviceLog(
            id: key.toString(),
            deviceId: device,
            state: logData['state'] ?? 'UNKNOWN',
            mode: logData['mode'] ?? 'MANUAL',
            timestamp: logData['timestamp'] ?? DateTime.now().toIso8601String(),
            userId: logData['userId'] ?? '',
          ));
        });
      }
    }
    
    _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _selectedDevice == 'all' 
        ? _logs 
        : _logs.where((l) => l.deviceId == _selectedDevice).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      appBar: AppBar(
        title: const Text('Device Logs'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _selectedDevice,
              underline: const SizedBox(),
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(_deviceLabels[device] ?? device, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedDevice = value!),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredLogs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) => _buildLogCard(filteredLogs[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.history, size: 50, color: AppColors.primaryBlue)),
          const SizedBox(height: 20),
          const Text('No Logs Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text('Device activity will appear here', style: TextStyle(fontSize: 14, color: AppColors.mediumGray)),
        ],
      ),
    );
  }

  Widget _buildLogCard(DeviceLog log) {
    final color = _deviceColors[log.deviceId] ?? AppColors.primaryBlue;
    final isOn = log.state == 'ON';
    final formattedTime = _formatTime(log.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: isOn ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isOn ? Icons.power_settings_new : Icons.power_off, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_deviceLabels[log.deviceId] ?? log.deviceId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: isOn ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(log.state, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isOn ? AppColors.primaryGreen : AppColors.error)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.accentAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(log.mode, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.accentAmber)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(formattedTime, style: const TextStyle(fontSize: 12, color: AppColors.mediumGray)),
              ],
            ),
          ),
          Icon(isOn ? Icons.trending_up : Icons.trending_down, color: isOn ? AppColors.primaryGreen : AppColors.error, size: 20),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(time);
      
      if (diff.inDays > 7) return DateFormat('dd MMM, hh:mm a').format(time);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return timestamp;
    }
  }
}

class DeviceLog {
  final String id;
  final String deviceId;
  final String state;
  final String mode;
  final String timestamp;
  final String userId;
  DeviceLog({required this.id, required this.deviceId, required this.state, required this.mode, required this.timestamp, required this.userId});
}