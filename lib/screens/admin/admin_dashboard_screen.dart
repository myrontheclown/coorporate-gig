import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'admin_workers_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_ai_dashboard_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cooperative Admin', style: TextStyle(fontSize: 18)),
            Text(
              'Shram Shakti Cooperative, Mumbai',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatTile(
                  icon: Icons.groups,
                  value: '128',
                  label: 'Workers',
                  color: AppColors.primary,
                  onTap: () => Nav.push(context, const AdminWorkersScreen()),
                ),
                const SizedBox(width: 8),
                _StatTile(
                  icon: Icons.work,
                  value: '42',
                  label: 'Active Jobs',
                  color: Colors.blue,
                  onTap: () => Nav.push(context, const AdminJobsScreen()),
                ),
                const SizedBox(width: 8),
                _StatTile(
                  icon: Icons.payments_outlined,
                  value: '₹1.2L',
                  label: 'Monthly GMV',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatTile(
                  icon: Icons.trending_up,
                  value: '18%',
                  label: 'Demand Growth',
                  color: Colors.amber.shade800,
                  onTap: () => Nav.push(context, const AdminAiDashboardScreen()),
                ),
                const SizedBox(width: 8),
                _StatTile(
                  icon: Icons.star,
                  value: '4.7',
                  label: 'Avg Rating',
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                _StatTile(
                  icon: Icons.person_off,
                  value: '12',
                  label: 'Skill Gaps',
                  color: Colors.red,
                  onTap: () => Nav.push(context, const AdminAiDashboardScreen()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _Heading('Demand Overview'),
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
                const _Heading('Demand Hotspots'),
                TextButton(
                  onPressed: () => Nav.push(
                    context,
                    const AdminAiDashboardScreen(),
                  ),
                  child: const Text('View AI'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _Hotspot(name: 'Grant Road', jobs: 18, demand: 0.92),
            _Hotspot(name: 'Dadar', jobs: 14, demand: 0.78),
            _Hotspot(name: 'Andheri West', jobs: 11, demand: 0.65),
            const SizedBox(height: 20),
            const _Heading('Active Services'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _ServiceRow(name: 'Plumbing', active: 9, total: 14, color: AppColors.info),
                  const Divider(height: 1),
                  _ServiceRow(name: 'Housekeeping', active: 8, total: 22, color: AppColors.success),
                  const Divider(height: 1),
                  _ServiceRow(name: 'Electrician', active: 5, total: 9, color: const Color(0xFFF59E0B)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
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
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _DemandChart extends StatelessWidget {
  final List<double> demand = [0.4, 0.7, 0.5, 0.9, 0.6, 1.0, 0.8, 0.3];
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
  final List<double> supply = [0.3, 0.5, 0.4, 0.6, 0.5, 0.7, 0.6, 0.55];

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
                                  ? AppColors.accent
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
            _Legend(color: AppColors.divider, label: 'Supply'),
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
            const Icon(Icons.location_on, color: Colors.red),
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
                    color: demand > 0.8 ? AppColors.accent : AppColors.primary,
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
  final Color color;
  const _ServiceRow({
    required this.name,
    required this.active,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.build, color: color, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$active active • $total total'),
      trailing: StatusBadge(
        label: active > 5 ? 'Busy' : 'Normal',
        color: active > 5 ? Colors.orange : Colors.green,
      ),
    );
  }
}
