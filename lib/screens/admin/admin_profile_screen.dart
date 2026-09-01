import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../screens/role_selection/role_selection_screen.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder(
            valueListenable: AppState.currentUserProfile,
            builder: (context, user, _) {
              final name = user?.fullName.isNotEmpty == true
                  ? user!.fullName
                  : 'Sandeep Naik';
              final roleTitle = user?.role == 'cooperative_admin'
                  ? 'Federation Admin'
                  : 'Administrator';
              final coop = user?.city.isNotEmpty == true
                  ? 'Goa Federation • ${user!.city} Coop'
                  : 'Goa Federation • Shram Shakti Coop';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              roleTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              coop,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.cooperative,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge(
                        label: 'Active',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Job alerts, allocation updates',
                ),
                const Divider(height: 1, indent: 56),
                const _SettingsTile(
                  icon: Icons.business_outlined,
                  title: 'Organization Details',
                  subtitle: 'Federation & cooperative profile',
                ),
                const Divider(height: 1, indent: 56),
                const _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Permissions',
                  subtitle: 'Manage admin access levels',
                ),
                const Divider(height: 1, indent: 56),
                const _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Docs, contact and FAQs',
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Logout / Switch Role',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () async {
                    await AuthService.signOut();
                    if (context.mounted) {
                      AppState.reset();
                      Nav.clearAll(context, const RoleSelectionScreen());
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Federation Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                children: [
                  _StatRow(label: 'Cooperatives', value: '12'),
                  _StatRow(label: 'Total Workers', value: '428'),
                  _StatRow(label: 'Active Services', value: '86'),
                  _StatRow(label: "Today's Demand", value: '134'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}