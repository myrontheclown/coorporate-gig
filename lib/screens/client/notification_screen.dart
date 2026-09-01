import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../data/mock_models.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = UserData.notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => AppState.notificationUnread.value = 0,
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, i) {
          final n = notifications[i];
          return _NotificationTile(notification: n);
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(notification.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(notification.type),
                color: color,
                size: 22,
              ),
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
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.read
                                ? FontWeight.w600
                                : FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'match':
        return AppColors.primary;
      case 'payment':
        return Colors.green;
      case 'booking':
        return Colors.indigo;
      case 'worker':
        return Colors.purple;
      case 'otp':
        return Colors.teal;
      case 'rating':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'match':
        return Icons.handshake;
      case 'payment':
        return Icons.payments;
      case 'booking':
        return Icons.event_available;
      case 'worker':
        return Icons.person_add;
      case 'otp':
        return Icons.shield;
      case 'rating':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
