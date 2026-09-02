import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_settings.dart';

class WorkerSettingsScreen extends StatelessWidget {
  const WorkerSettingsScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (context.mounted) {
      AppState.reset();
      Nav.toRoleSelection(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SettingsSectionHeader('Account'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Name, phone, email',
                onTap: () => _showComingSoon(context, 'Personal Information'),
              ),
              AppSettingsTile(
                icon: Icons.contact_phone_outlined,
                title: 'Contact Information',
                subtitle: 'Phone & emergency contact',
                onTap: () => _showComingSoon(context, 'Contact information'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Work Preferences'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.handyman_outlined,
                title: 'Skills',
                subtitle: 'Manage your services',
                onTap: () => _showComingSoon(context, 'Skills'),
              ),
              AppSettingsTile(
                icon: Icons.map_outlined,
                title: 'Service Areas',
                subtitle: 'Where you work',
                onTap: () => _showComingSoon(context, 'Service areas'),
              ),
              AppSettingsTile(
                icon: Icons.toggle_on_outlined,
                title: 'Availability',
                subtitle: 'On-duty & off-duty hours',
                value: 'On',
                onTap: () => _showComingSoon(context, 'Availability'),
              ),
              AppSettingsTile(
                icon: Icons.schedule_outlined,
                title: 'Working Hours',
                onTap: () => _showComingSoon(context, 'Working hours'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Notifications'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Job Alerts',
                subtitle: 'New requests & updates',
                value: 'On',
                onTap: () => _showComingSoon(context, 'Job alerts'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Payments'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payment Details',
                subtitle: 'Bank & withdrawal',
                onTap: () => _showComingSoon(context, 'Payment details'),
              ),
              AppSettingsTile(
                icon: Icons.payments_outlined,
                title: 'Earnings',
                subtitle: 'Statements & reports',
                onTap: () => _showComingSoon(context, 'Earnings'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Verification'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.badge_outlined,
                title: 'Identity Verification',
                subtitle: 'Aadhaar / documents',
                value: 'Verified',
                iconColor: AppColors.success,
                onTap: () => _showComingSoon(context, 'Identity verification'),
              ),
              AppSettingsTile(
                icon: Icons.fact_check_outlined,
                title: 'Skills Verification',
                subtitle: 'Practical assessment',
                value: 'Verified',
                iconColor: AppColors.success,
                onTap: () => _showComingSoon(context, 'Skills verification'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Privacy & Support'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                onTap: () => _showComingSoon(context, 'Privacy'),
              ),
              AppSettingsTile(
                icon: Icons.headset_mic_outlined,
                title: 'Help & Support',
                onTap: () => _showComingSoon(context, 'Help & Support'),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: AppColors.error, size: 22),
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.error,
                ),
              ),
              onTap: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}
