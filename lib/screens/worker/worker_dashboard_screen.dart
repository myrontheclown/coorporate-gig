import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'worker_job_requests_screen.dart';
import 'worker_job_details_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, Ramesh 👋', style: TextStyle(fontSize: 16)),
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
              Row(
                children: [
                  _DashStat(
                    icon: Icons.work_history,
                    label: 'Jobs Done',
                    value: '${AppState.workerCompletedJobs.value}+',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _DashStat(
                    icon: Icons.star,
                    label: 'Rating',
                    value: '${AppState.workerRating.value}',
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  _DashStat(
                    icon: Icons.payments_outlined,
                    label: 'Earnings',
                    value: '₹${AppState.workerEarnings.value}',
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionHeader('New Job Requests'),
              const SizedBox(height: 8),
              _JobRequestPreview(
                profession: 'Plumbing',
                detail: 'Fix leaking kitchen sink & replace pipes',
                amount: 1050,
                distance: '1.2 km',
                onTap: () => Nav.push(context, const WorkerJobDetailsScreen()),
              ),
              _JobRequestPreview(
                profession: 'Plumbing',
                detail: 'Bathroom water tank installation',
                amount: 900,
                distance: '2.8 km',
                onTap: () => Nav.push(context, const WorkerJobDetailsScreen()),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Nav.push(
                    context,
                    const WorkerJobRequestsScreen(),
                  ),
                  child: const Text('View all requests'),
                ),
              ),
              const SizedBox(height: 8),
              _SectionHeader('Upcoming Jobs'),
              const SizedBox(height: 8),
              Card(
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
                              'Kitchen plumbing - Ms. Priya',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Tomorrow, 10:00 AM • Grant Road',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge(
                        label: 'Confirmed',
                        color: Colors.indigo,
                      ),
                    ],
                  ),
                ),
              ),
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
      color: onDuty ? AppColors.primary : Colors.white,
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
              activeTrackColor: Colors.white,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => AppState.workerOnDuty.value = v,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DashStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _JobRequestPreview extends StatelessWidget {
  final String profession;
  final String detail;
  final int amount;
  final String distance;
  final VoidCallback onTap;

  const _JobRequestPreview({
    required this.profession,
    required this.detail,
    required this.amount,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
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
              'New',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
