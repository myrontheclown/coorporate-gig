import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../screens/role_selection/role_selection_screen.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../theme/app_theme.dart';
import 'bookings_history_screen.dart';
import 'my_requests_screen.dart';
import 'notification_screen.dart';
import 'previously_hired_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  ClientDashboardData _stats = const ClientDashboardData();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final uid = AuthService.currentUserId;
    if (uid != null && uid.isNotEmpty) {
      final s = await DashboardService.getClientDashboardStats(uid);
      if (mounted) setState(() => _stats = s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder(
            valueListenable: AppState.currentUserProfile,
            builder: (context, profile, _) {
              final name = profile?.fullName.isNotEmpty == true
                  ? profile!.fullName
                  : 'Priya Mehta';
              final phone = profile?.phone.isNotEmpty == true
                  ? profile!.phone
                  : '+91 98765 43210';
              final location = profile?.city.isNotEmpty == true
                  ? '📍 ${profile!.address.isNotEmpty ? "${profile.address}, " : ""}${profile.city}'
                  : '📍 Grant Road, Mumbai';
              final initials = name
                  .trim()
                  .split(' ')
                  .map((p) => p.isNotEmpty ? p[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            initials.isNotEmpty ? initials : 'PM',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                              phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(
                icon: Icons.verified_user,
                value: '${_stats.servicesUsed}',
                label: 'Services Used',
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: Icons.groups,
                value: '${_stats.workersHired}',
                label: 'Workers Hired',
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: Icons.favorite,
                value: '₹${(_stats.totalPaid / 1000).toStringAsFixed(1)}k',
                label: 'Total Paid',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionHeader('My Services'),
          Card(
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.assignment_outlined,
                  title: 'My Requests',
                  onTap: () => Nav.push(context, const MyRequestsScreen()),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'My Bookings & History',
                  onTap: () => Nav.push(context, const BookingsHistoryScreen()),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.history,
                  title: 'Previously Hired Workers',
                  onTap: () => Nav.push(context, const PreviouslyHiredScreen()),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => Nav.push(context, const NotificationListScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Manage'),
          Card(
            child: const Column(
              children: [
                _MenuTile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  value: '2',
                ),
                Divider(height: 1),
                _MenuTile(
                  icon: Icons.payments_outlined,
                  title: 'Payment Methods',
                  value: 'UPI + Wallet',
                ),
                Divider(height: 1),
                _MenuTile(
                  icon: Icons.wallet_outlined,
                  title: 'Wallet',
                  value: '₹1,250',
                ),
                Divider(height: 1),
                _MenuTile(
                  icon: Icons.card_giftcard,
                  title: 'Refer & Earn',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Support'),
          Card(
            child: Column(
              children: [
                const _MenuTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Help & Support',
                ),
                const Divider(height: 1),
                const _MenuTile(
                  icon: Icons.info_outline,
                  title: 'About Coorporate Gig',
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.logout,
                  title: 'Logout / Switch Role',
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
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
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
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
