import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../services/dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/status_badge.dart';
import '../client/notification_screen.dart';
import 'admin_ai_forecast_screen.dart';
import 'admin_allocation_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_workers_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminDashboardData _stats = const AdminDashboardData();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await DashboardService.getAdminDashboardStats();
    if (mounted) setState(() => _stats = s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cooperative Admin', style: TextStyle(fontSize: 18)),
            Text(
              'Goa Federation • Shram Shakti Coop',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Nav.push(context, const NotificationListScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI row 1
          Row(
            children: [
              KpiCard(
                icon: Icons.groups,
                value: '${_stats.activeWorkers}',
                label: 'Active Workers',
                color: AppColors.primary,
                onTap: () => Nav.push(context, const AdminWorkersScreen()),
              ),
              const SizedBox(width: 8),
              KpiCard(
                icon: Icons.work,
                value: '${_stats.activeJobs}',
                label: 'Active Jobs',
                color: AppColors.chartAccent,
                onTap: () => Nav.push(context, const AdminJobsScreen()),
              ),
              const SizedBox(width: 8),
              KpiCard(
                icon: Icons.pending_actions,
                value: '${_stats.pendingRequests}',
                label: 'Pending Requests',
                color: AppColors.warning,
                onTap: () => Nav.push(context, const AdminJobsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              KpiCard(
                icon: Icons.check_circle,
                value: '${_stats.completedJobs}',
                label: 'Completed Jobs',
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              KpiCard(
                icon: Icons.star,
                value: '${_stats.avgRating}',
                label: 'Avg Rating',
                color: AppColors.rating,
              ),
              const SizedBox(width: 8),
              KpiCard(
                icon: Icons.trending_up,
                value: '${_stats.todaysDemand}',
                label: "Today's Demand",
                color: AppColors.cooperative,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // AI Demand Forecast preview
          const Text(
            'AI Demand Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _AiForecastPreview(
            onOpen: () => Nav.push(context, const AdminAiForecastScreen()),
          ),
          const SizedBox(height: 20),
          const Text(
            'Demand Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _DemandChart(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Demand Hotspots',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Nav.push(context, const AdminAllocationScreen()),
                child: const Text('Allocate'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const _Hotspot(name: 'Grant Road', jobs: 18, demand: 0.92),
          const _Hotspot(name: 'Dadar', jobs: 14, demand: 0.78),
          const _Hotspot(name: 'Andheri West', jobs: 11, demand: 0.65),
          const SizedBox(height: 20),
          const Text(
            'Active Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                _ServiceRow(name: 'Plumbing', active: 9, total: 14),
                Divider(height: 1),
                _ServiceRow(name: 'Housekeeping', active: 8, total: 22),
                Divider(height: 1),
                _ServiceRow(name: 'Electrician', active: 5, total: 9),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AiForecastPreview extends StatelessWidget {
  final VoidCallback onOpen;
  const _AiForecastPreview({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Electrician demand rising',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                const StatusBadge(
                  label: 'AI',
                  color: AppColors.primary,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _MiniStat(label: 'Today', value: '32 jobs'),
                _MiniStat(label: 'Forecast', value: '41 jobs'),
                _MiniStat(label: 'Change', value: '+28%'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Panaji requires 3 additional electricians tomorrow.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'View Full Forecast', onPressed: onOpen),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemandChart extends StatelessWidget {
  final List<double> demand = const [0.4, 0.7, 0.5, 0.9, 0.6, 1.0, 0.8, 0.3];
  final List<String> months = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
  final List<double> supply = const [0.3, 0.5, 0.4, 0.6, 0.5, 0.7, 0.6, 0.55];

  @override
  Widget build(BuildContext context) {
    final high = demand.asMap().entries.fold(0, (acc, e) => e.value > demand[acc] ? e.key : acc);
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(demand.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 140 * demand[i],
                            decoration: BoxDecoration(
                              color: i == high
                                    ? AppColors.chartAccent
                                    : AppColors.primary.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 8,
                            height: 140 * supply[i],
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        months[i].substring(0, 1),
                        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Legend(color: AppColors.primary.withValues(alpha: 0.7), label: 'Demand'),
            const SizedBox(width: 16),
            const _Legend(color: AppColors.divider, label: 'Supply'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Hotspot extends StatelessWidget {
  final String name;
  final int jobs;
  final double demand;
  const _Hotspot({required this.name, required this.jobs, required this.demand});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.chartAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: demand,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: AppColors.divider,
                    color: demand > 0.8 ? AppColors.chartAccent : AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$jobs jobs',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final String name;
  final int active;
  final int total;
  const _ServiceRow({required this.name, required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.build, color: AppColors.primary, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$active active • $total total'),
      trailing: StatusBadge(
        label: active > 5 ? 'Busy' : 'Normal',
        color: active > 5 ? AppColors.warning : AppColors.success,
      ),
    );
  }
}