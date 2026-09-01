import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../client/notification_screen.dart';
import 'admin_allocation_screen.dart';
import 'admin_federation_screen.dart';
import 'admin_jobs_screen.dart';

/// Cooperative Admin "Operations" hub.
///
/// Groups workforce allocation, jobs & dispatch, and federation
/// administration in one mobile-first destination.
class AdminOperationsScreen extends StatelessWidget {
  const AdminOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
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
          Card(
            color: AppColors.cooperative.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.track_changes, color: AppColors.cooperative, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Operations Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.cooperative,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '42 active jobs • 18 pending • '
                          '3 skill shortages',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.cooperative.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Dispatch & Allocation'),
          const SizedBox(height: 8),
          _OpsTile(
            icon: Icons.handyman,
            title: 'Workforce Allocation',
            subtitle: 'Demand hotspots & recommended allocation',
            onTap: () => Nav.push(context, const AdminAllocationScreen()),
          ),
          _OpsTile(
            icon: Icons.work_outline,
            title: 'Jobs & Dispatch',
            subtitle: 'Pending jobs, track assignments',
            onTap: () => Nav.push(context, const AdminJobsScreen()),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Federation'),
          const SizedBox(height: 8),
          _OpsTile(
            icon: Icons.account_balance,
            title: 'Federation Admin',
            subtitle: 'Cooperatives, workers, regional demand',
            onTap: () => Nav.push(context, const AdminFederationScreen()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OpsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _OpsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}