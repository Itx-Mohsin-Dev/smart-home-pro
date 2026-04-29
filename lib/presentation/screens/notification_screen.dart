import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService.database
          .child('notifications/${user.uid}')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          _parseNotifications(event.snapshot.value);
        }
      });
    }
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseService.database
          .child('notifications/${user.uid}')
          .once();
      if (snapshot.snapshot.value != null) {
        _parseNotifications(snapshot.snapshot.value);
      }
    }
    setState(() => _isLoading = false);
  }

  void _parseNotifications(dynamic notificationsData) {
    _notifications = [];
    final notificationsMap = notificationsData as Map<dynamic, dynamic>;
    notificationsMap.forEach((key, value) {
      final notifData = value as Map<dynamic, dynamic>;
      _notifications.add(NotificationItem(
        id: key.toString(),
        title: notifData['title'] ?? 'Alert',
        message: notifData['message'] ?? '',
        type: notifData['type'] ?? 'info',
        timestamp: notifData['timestamp'] ?? DateTime.now().toIso8601String(),
        isRead: notifData['read'] ?? false,
      ));
    });
    // Sort by timestamp (newest first)
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {});
  }

  Future<void> _markAsRead(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database
          .child('notifications/${user.uid}/$id/read')
          .set(true);
    }
  }

  Future<void> _markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (var notif in _notifications.where((n) => !n.isRead)) {
        await FirebaseService.database
            .child('notifications/${user.uid}/${notif.id}/read')
            .set(true);
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database
          .child('notifications/${user.uid}/$id')
          .remove();
    }
  }

  Future<void> _clearAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (var notif in _notifications) {
        await FirebaseService.database
            .child('notifications/${user.uid}/${notif.id}')
            .remove();
      }
    }
  }

  // Static method to send notification from anywhere in app
  static Future<void> sendNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseService.database
          .child('notifications/${user.uid}')
          .push()
          .set({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });
    }
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgLightBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredNotifs = _filter == 'all'
        ? _notifications
        : _filter == 'unread'
            ? _notifications.where((n) => !n.isRead).toList()
            : _notifications.where((n) => n.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('Mark all read', style: TextStyle(color: AppColors.primaryBlue)),
            ),
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') _clearAll();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All', _notifications.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('unread', 'Unread', unreadCount),
                        const SizedBox(width: 8),
                        _buildFilterChip('alert', 'Alerts', _notifications.where((n) => n.type == 'alert').length),
                        const SizedBox(width: 8),
                        _buildFilterChip('info', 'Info', _notifications.where((n) => n.type == 'info').length),
                        const SizedBox(width: 8),
                        _buildFilterChip('success', 'Success', _notifications.where((n) => n.type == 'success').length),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(filteredNotifs[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filter == value;
    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryBlue.withOpacity(0.1),
      checkmarkColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryBlue : AppColors.mediumGray,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off, size: 50, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notif) {
    Color bgColor;
    Color iconColor;
    IconData iconData;
    
    switch (notif.type) {
      case 'alert':
        bgColor = AppColors.error.withOpacity(0.1);
        iconColor = AppColors.error;
        iconData = Icons.warning;
        break;
      case 'success':
        bgColor = AppColors.primaryGreen.withOpacity(0.1);
        iconColor = AppColors.primaryGreen;
        iconData = Icons.check_circle;
        break;
      default:
        bgColor = AppColors.primaryBlue.withOpacity(0.1);
        iconColor = AppColors.primaryBlue;
        iconData = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: notif.isRead ? Colors.white : bgColor,
      child: InkWell(
        onTap: () {
          if (!notif.isRead) _markAsRead(notif.id);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notif.timestamp),
                      style: const TextStyle(fontSize: 11, color: AppColors.mediumGray),
                    ),
                  ],
                ),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') _deleteNotification(notif.id);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.mediumGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(time);
      
      if (diff.inDays > 7) {
        return DateFormat('dd MMM').format(time);
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final String timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}