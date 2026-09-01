import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import 'worker_active_job_screen.dart';
import 'worker_earnings_screen.dart';
import 'worker_job_details_screen.dart';
import 'worker_job_requests_screen.dart';
import 'worker_jobs_screen.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, Ramesh', style: TextStyle(fontSize: 17)),
            Text(
              'Plumber • Grant Road',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AppState.workerOnDuty,
        builder: (context, onDuty, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OnDutyCard(onDuty: onDuty),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Today at a glance'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.work_outline,
                    label: "Today's Jobs",
                    value: '3',
                    color: AppColors.primary,
                    onTap: () => Nav.push(context, const WorkerJobsScreen()),
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.notifications_active_outlined,
                    label: 'Pending Requests',
                    value: '2',
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
                    value: '4.8',
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
                    value: '₹${AppState.workerEarnings.value}',
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
                    value: 'Yes',
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
  const _OnDutyCard({required this.onDuty});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: onDuty ? AppColors.success : Colors.white,
      elevation: onDuty ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              onDuty ? Icons.verified_user : Icons.hourglass_empty,
              color: onDuty ? Colors.white : AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onDuty ? 'You are ON DUTY' : 'You are Off Duty',
                    style: TextStyle(
                      color: onDuty ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    onDuty
                        ? 'Receiving job requests in your area'
                        : 'Turn on to receive job requests',
                    style: TextStyle(
                      fontSize: 12,
                      color: onDuty ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: onDuty,
              activeTrackColor: const Color(0x33FFFFFF),
              activeThumbColor: AppColors.success,
              onChanged: (v) => AppState.workerOnDuty.value = v,
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