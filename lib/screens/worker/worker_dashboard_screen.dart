import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../services/dashboard_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import 'worker_active_job_screen.dart';
import 'worker_earnings_screen.dart';
import 'worker_job_details_screen.dart';
import 'worker_job_requests_screen.dart';
import 'worker_jobs_screen.dart';
import '../client/notification_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  WorkerDashboardData _stats = const WorkerDashboardData();
  bool _togglingDuty = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _syncOnDutyFromProfile();
  }

  /// Syncs the in-memory on-duty flag from the stored WorkerProfile so the
  /// toggle always reflects the last persisted value after sign-in.
  void _syncOnDutyFromProfile() {
    final profile = AppState.currentWorkerProfile.value;
    if (profile != null) {
      AppState.workerOnDuty.value = profile.isOnDuty;
    }
  }

  Future<void> _loadStats() async {
    final workerId = AppState.currentWorkerProfile.value?.id ?? '';
    if (workerId.isNotEmpty) {
      final s = await DashboardService.getWorkerDashboardStats(workerId);
      if (mounted) setState(() => _stats = s);
    }
  }

  /// Returns true when the worker has at least one job currently in_progress.
  bool get _hasActiveJob {
    // The active job card is currently driven by mock/static data.
    // When live jobs are wired, check AppState or a job list here.
    // For now we check the booking status notifier as a proxy.
    return AppState.currentBookingStatus.value == 'active';
  }

  /// Handles the duty toggle tap with optional active-job warning.
  Future<void> _handleDutyToggle(bool newValue) async {
    // Going off-duty while a job is in progress → show warning dialog.
    if (!newValue && _hasActiveJob) {
      final proceed = await _showActiveJobWarning();
      if (!proceed) return;
    }

    // Optimistic update
    AppState.workerOnDuty.value = newValue;
    setState(() => _togglingDuty = true);

    final workerId = AppState.currentWorkerProfile.value?.id ?? '';
    final success = await WorkerProfileService.setOnDutyStatus(workerId, newValue);

    if (!success && mounted) {
      // Revert on failure
      AppState.workerOnDuty.value = !newValue;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update duty status. Please try again.')),
      );
    }

    if (mounted) setState(() => _togglingDuty = false);
  }

  Future<bool> _showActiveJobWarning() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Active Job in Progress'),
        content: const Text(
          'You have a job currently in progress. Going off-duty will not cancel the job, but you will stop receiving new job requests.\n\nDo you want to go off-duty anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay On Duty'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Go Off Duty'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: AppState.currentUserProfile,
          builder: (context, profile, _) {
            final name = profile?.fullName.isNotEmpty == true
                ? profile!.fullName.split(' ').first
                : 'Ramesh';
            final profession = profile?.address.isNotEmpty == true
                ? 'Plumber • ${profile!.address}'
                : 'Plumber • Grant Road';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, $name', style: const TextStyle(fontSize: 17)),
                Text(
                  profession,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Nav.push(context, const NotificationListScreen()),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AppState.workerOnDuty,
        builder: (context, onDuty, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OnDutyCard(
                onDuty: onDuty,
                toggling: _togglingDuty,
                onChanged: _handleDutyToggle,
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Today at a glance'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.work_outline,
                    label: "Today's Jobs",
                    value: '${_stats.todayJobs}',
                    color: AppColors.primary,
                    onTap: () => Nav.push(context, const WorkerJobsScreen()),
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.notifications_active_outlined,
                    label: 'Pending Requests',
                    value: '${_stats.pendingRequests}',
                    color: AppColors.warning,
                    onTap: () => Nav.push(
                      context,
                      const WorkerJobRequestsScreen(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.star,
                    label: 'Rating',
                    value: '${_stats.rating}',
                    color: AppColors.rating,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.payments_outlined,
                    label: "Today's Earnings",
                    value: '₹${_stats.totalEarnings.toInt()}',
                    color: AppColors.success,
                    onTap: () => Nav.push(
                      context,
                      const WorkerEarningsScreen(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.verified_user_outlined,
                    label: 'Verified',
                    value: _stats.isVerified ? 'Yes' : 'Pending',
                    color: AppColors.cooperative,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ActiveJobCard(onDuty: onDuty),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'New Job Requests',
                actionLabel: 'View all',
                onAction: () => Nav.push(
                  context,
                  const WorkerJobRequestsScreen(),
                ),
              ),
              const SizedBox(height: 4),
              const _RequestPreview(
                profession: 'Plumbing',
                detail: 'Fix leaking kitchen sink & replace pipes',
                amount: 1050,
                distance: '1.2 km',
                time: 'Today, 3:00 PM',
              ),
              const _RequestPreview(
                profession: 'Plumbing',
                detail: 'Bathroom water tank installation',
                amount: 900,
                distance: '2.8 km',
                time: 'Today, 5:00 PM',
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Upcoming Jobs'),
              const SizedBox(height: 8),
              const _UpcomingCard(
                title: 'Kitchen plumbing - Ms. Priya',
                time: 'Tomorrow, 10:00 AM • Grant Road',
                status: 'Confirmed',
              ),
              const _UpcomingCard(
                title: 'Geyser checkup - Ms. Anita',
                time: 'Wed, 9:00 AM • Malad',
                status: 'Upcoming',
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Recent Activity'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: const [
                    _Activity(
                      icon: Icons.check_circle,
                      color: AppColors.success,
                      text: 'Completed plumbing job for Sharma family',
                      time: '2 days ago',
                    ),
                    Divider(height: 1, indent: 16),
                    _Activity(
                      icon: Icons.payments,
                      color: AppColors.success,
                      text: 'Received ₹900 payment',
                      time: '2 days ago',
                    ),
                    Divider(height: 1, indent: 16),
                    _Activity(
                      icon: Icons.star,
                      color: AppColors.rating,
                      text: 'New 5★ review from Verma S.',
                      time: '3 days ago',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _OnDutyCard extends StatelessWidget {
  final bool onDuty;
  final bool toggling;
  final ValueChanged<bool>? onChanged;
  const _OnDutyCard({
    required this.onDuty,
    this.toggling = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // On-duty → green card; Off-duty → red-tinted card
    final cardBg = onDuty ? AppColors.dutyOn : AppColors.dutyOff;
    return Card(
      color: cardBg,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              onDuty ? Icons.verified_user : Icons.do_not_disturb_on_outlined,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onDuty ? 'You are ON DUTY' : 'You are OFF DUTY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    onDuty
                        ? 'Receiving job requests in your area'
                        : 'Turn on to receive job requests',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (toggling)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              )
            else
              Switch(
                value: onDuty,
                // Track: semi-transparent white over whatever card color is showing
                activeTrackColor: Colors.white.withValues(alpha: 0.35),
                activeThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.35),
                inactiveThumbColor: Colors.white,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final bool onDuty;
  const _ActiveJobCard({required this.onDuty});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Job - Priya M.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Plumbing • Grant Road',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusBadge(
                  label: 'In Progress',
                  color: AppColors.success,
                  icon: Icons.build,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Service is in progress • ~60% complete',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            if (onDuty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => Nav.push(
                    context,
                    const WorkerActiveJobScreen(),
                  ),
                  label: const Text('Go to Active Job'),
                ),
              )
            else
              const SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  child: Text('On duty to continue'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestPreview extends StatelessWidget {
  final String profession;
  final String detail;
  final int amount;
  final String distance;
  final String time;
  const _RequestPreview({
    required this.profession,
    required this.detail,
    required this.amount,
    required this.distance,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Nav.push(context, const WorkerJobDetailsScreen()),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.plumbing, color: AppColors.primary),
        ),
        title: Text(
          profession,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$detail • $distance',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹$amount',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  const _UpcomingCard({
    required this.title,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.event, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: status,
              color: status == 'Confirmed'
                  ? AppColors.success
                  : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;
  const _Activity({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        time,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
