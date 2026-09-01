import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../screens/role_selection/role_selection_screen.dart';
import '../../theme/app_theme.dart';
import 'previously_hired_screen.dart';
import 'notification_screen.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'PM',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priya Mehta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '+91 98765 43210',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '📍 Grant Road, Mumbai',
                          style: TextStyle(
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
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(icon: Icons.verified_user, value: '12', label: 'Services Used'),
              const SizedBox(width: 8),
              _StatCard(icon: Icons.groups, value: '3', label: 'Workers Hired'),
              const SizedBox(width: 8),
              _StatCard(icon: Icons.favorite, value: '₹9.5k', label: 'Total Paid'),
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
                  onTap: () => Nav.toClient(context),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'My Bookings & History',
                  onTap: () => Nav.toClient(context),
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
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  value: '2',
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.payments_outlined,
                  title: 'Payment Methods',
                  value: 'UPI + Wallet',
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.wallet_outlined,
                  title: 'Wallet',
                  value: '₹1,250',
                ),
                const Divider(height: 1),
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
                _MenuTile(icon: Icons.headset_mic_outlined, title: 'Help & Support'),
                const Divider(height: 1),
                _MenuTile(icon: Icons.info_outline, title: 'About Coorporate Gig'),
                const Divider(height: 1),
                _MenuTile(icon: Icons.logout, title: 'Logout / Switch Role',
                    onTap: () => Nav.clearAll(context, const RoleSelectionScreen())),
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
