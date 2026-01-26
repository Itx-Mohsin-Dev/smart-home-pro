import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'all';
  final List<String> filters = ['all', 'unread', 'alerts', 'updates'];

  final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'High Energy Consumption Detected',
      description: 'Living Room AC is using 40% more power than usual',
      time: 'Just now',
      icon: Icons.bolt,
      color: AppColors.error,
      type: 'alert',
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Automation Activated',
      description: 'Good Morning scene activated at 7:00 AM',
      time: '2 hours ago',
      icon: Icons.auto_awesome,
      color: AppColors.accentAmber,
      type: 'automation',
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Water Tank Full',
      description: 'Water motor automatically turned off at 95%',
      time: '4 hours ago',
      icon: Icons.water_damage,
      color: AppColors.primaryBlue,
      type: 'device',
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Monthly Savings Update',
      description: 'You saved ₹2,450 this month! 20% more than last month',
      time: '1 day ago',
      icon: Icons.savings,
      color: AppColors.primaryGreen,
      type: 'savings',
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Motion Detected',
      description: 'Motion detected in Living Room at 11:30 PM',
      time: '2 days ago',
      icon: Icons.motion_photos_on,
      color: AppColors.accentPurple,
      type: 'security',
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Device Offline',
      description: 'Curtains lost connection. Please check device',
      time: '3 days ago',
      icon: Icons.warning,
      color: AppColors.error,
      type: 'alert',
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      title: 'New Feature Available',
      description: 'Try the new energy monitoring dashboard',
      time: '1 week ago',
      icon: Icons.upgrade,
      color: AppColors.primaryBlue,
      type: 'update',
      isRead: true,
    ),
    NotificationItem(
      id: '8',
      title: 'Air Filter Reminder',
      description: 'Time to replace AC air filter (due in 3 days)',
      time: '1 week ago',
      icon: Icons.cleaning_services,
      color: AppColors.primaryGreen,
      type: 'maintenance',
      isRead: true,
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filter == 'all' 
        ? notifications 
        : notifications.where((n) => n.type == _filter || (_filter == 'unread' && !n.isRead)).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: AppColors.darkGray,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: AppTextStyles.h2(context).copyWith(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, size: 22),
                          onPressed: _markAllAsRead,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Filter Chips
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: filters.map((filter) {
                    final bool isSelected = _filter == filter;
                    final String label = filter == 'all' ? 'All' 
                                      : filter == 'unread' ? 'Unread ($unreadCount)'
                                      : filter == 'alerts' ? 'Alerts'
                                      : filter == 'updates' ? 'Updates' : filter;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _filter = filter;
                          });
                        },
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : AppColors.mediumGray,
                          ),
                        ),
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.bgLightBlue,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // Empty State or List
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                      child: Column(
                        children: [
                          ...filteredNotifications.map((notification) {
                            return _buildNotificationCard(notification);
                          }).toList(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
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
              'You\'re all caught up! Check back later for updates.',
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
                _filter = 'all';
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
            child: const Text('View All Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: notification.isRead ? AppColors.borderGray : notification.color.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _markAsRead(notification.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: notification.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (!notification.isRead) const SizedBox(width: 8),
                
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(notification.type),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTypeLabel(notification.type),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getBadgeTextColor(notification.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Action Menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteNotification(notification.id);
                    } else if (value == 'mark_read') {
                      _markAsRead(notification.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: AppColors.primaryBlue),
                          SizedBox(width: 8),
                          Text('Mark as Read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.mediumGray,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  Color _getBadgeColor(String type) {
    switch (type) {
      case 'alert':
        return AppColors.error.withOpacity(0.1);
      case 'automation':
        return AppColors.accentAmber.withOpacity(0.1);
      case 'device':
        return AppColors.primaryBlue.withOpacity(0.1);
      case 'savings':
        return AppColors.primaryGreen.withOpacity(0.1);
      case 'security':
        return AppColors.accentPurple.withOpacity(0.1);
      case 'update':
        return AppColors.primaryBlue.withOpacity(0.1);
      case 'maintenance':
        return AppColors.primaryGreen.withOpacity(0.1);
      default:
        return AppColors.bgLightBlue;
    }
  }

  Color _getBadgeTextColor(String type) {
    switch (type) {
      case 'alert':
        return AppColors.error;
      case 'automation':
        return AppColors.accentAmber;
      case 'device':
        return AppColors.primaryBlue;
      case 'savings':
        return AppColors.primaryGreen;
      case 'security':
        return AppColors.accentPurple;
      case 'update':
        return AppColors.primaryBlue;
      case 'maintenance':
        return AppColors.primaryGreen;
      default:
        return AppColors.mediumGray;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'alert':
        return 'ALERT';
      case 'automation':
        return 'AUTOMATION';
      case 'device':
        return 'DEVICE';
      case 'savings':
        return 'SAVINGS';
      case 'security':
        return 'SECURITY';
      case 'update':
        return 'UPDATE';
      case 'maintenance':
        return 'MAINTENANCE';
      default:
        return type.toUpperCase();
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
    required this.isRead,
  });
}