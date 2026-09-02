import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_models.dart';
import '../../data/user_data.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/supabase_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_theme.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    AppState.currentUserProfile.addListener(_onProfileChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    AppState.currentUserProfile.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    final isAuthenticated =
        SupabaseService.isReady && AuthService.currentUser != null;

    if (!isAuthenticated) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
          _notifications = List.from(UserData.notifications);
        });
      }
      return;
    }

    final customerId = AuthService.currentUser!.id;

    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.getJobsForCustomer(customerId);
      final transactions =
          await TransactionService.getTransactionsForCustomer(customerId);

      final List<_DatedNotification> items = [];

      // Synthesize notifications from jobs
      for (final job in jobs) {
        final workerName =
            job.workerProfile?.userProfile?.fullName ?? 'A worker';
        final jobTitle =
            job.jobTitle.isNotEmpty ? job.jobTitle : 'Service request';
        final date = job.completedAt ??
            job.scheduledAt ??
            job.createdAt ??
            DateTime.now();

        switch (job.status.toLowerCase()) {
          case 'pending':
            items.add(_DatedNotification(
              date: date,
              notification: AppNotification(
                id: 'job_pending_${job.id}',
                title: 'Request Placed',
                body:
                    'Your request for "$jobTitle" has been placed and is waiting for worker assignment.',
                time: _formatRelativeTime(date),
                type: 'booking',
                read: true,
              ),
            ));
            break;
          case 'accepted':
            items.add(_DatedNotification(
              date: date,
              notification: AppNotification(
                id: 'job_matched_${job.id}',
                title: 'Worker Matched!',
                body:
                    '$workerName has been matched for your "$jobTitle" request.',
                time: _formatRelativeTime(date),
                type: 'match',
                read: false,
              ),
            ));
            break;
          case 'in_progress':
            items.add(_DatedNotification(
              date: date,
              notification: AppNotification(
                id: 'job_progress_${job.id}',
                title: 'Service In Progress',
                body:
                    '$workerName is currently working on your "$jobTitle" request.',
                time: _formatRelativeTime(date),
                type: 'otp',
                read: false,
              ),
            ));
            break;
          case 'completed':
            items.add(_DatedNotification(
              date: date,
              notification: AppNotification(
                id: 'job_completed_${job.id}',
                title: 'Service Completed',
                body:
                    'Your request for "$jobTitle" with $workerName has been completed.',
                time: _formatRelativeTime(date),
                type: 'booking',
                read: true,
              ),
            ));
            break;
        }
      }

      // Synthesize notifications from transactions
      for (final tx in transactions) {
        final date = tx.createdAt ?? DateTime.now();
        final method = tx.paymentMethod.isNotEmpty
            ? tx.paymentMethod
            : 'UPI';
        final isSuccess = tx.status.toLowerCase() == 'completed';

        items.add(_DatedNotification(
          date: date,
          notification: AppNotification(
            id: 'tx_${tx.id}',
            title: isSuccess ? 'Payment Successful' : 'Payment Update',
            body: isSuccess
                ? 'Your payment of ₹${tx.amount.toInt()} via $method was successful.'
                : 'Payment of ₹${tx.amount.toInt()} is ${tx.status}.',
            time: _formatRelativeTime(date),
            type: 'payment',
            read: true,
          ),
        ));
      }

      // Sort by timestamp descending
      items.sort((a, b) => b.date.compareTo(a.date));

      final unreadCount =
          items.where((item) => !item.notification.read).length;
      AppState.notificationUnread.value = unreadCount;

      if (mounted) {
        setState(() {
          _hasFetched = true;
          _notifications = items.map((i) => i.notification).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications.map((n) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.time,
          type: n.type,
          read: true,
        );
      }).toList();
    });
    AppState.notificationUnread.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
          TextButton(
            onPressed: _notifications.isEmpty ? null : _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading && !_hasFetched
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 56,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Updates regarding your requests and payments will appear here.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _notifications.length,
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        return _NotificationTile(notification: n);
                      },
                    ),
            ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
    return '${dt.day} $m ${dt.year}';
  }
}

class _DatedNotification {
  final DateTime date;
  final AppNotification notification;
  const _DatedNotification({
    required this.date,
    required this.notification,
  });
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
                            color: AppColors.error,
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
        return AppColors.success;
      case 'booking':
        return AppColors.primary;
      case 'worker':
        return AppColors.primaryDark;
      case 'otp':
        return AppColors.cooperative;
      case 'rating':
        return AppColors.rating;
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
