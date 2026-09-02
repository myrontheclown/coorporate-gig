import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_settings.dart';

class ClientSettingsScreen extends StatelessWidget {
  const ClientSettingsScreen({super.key});

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
                icon: Icons.phone_android,
                title: 'Phone / Email',
                subtitle: 'Manage contact details',
                onTap: () => _showComingSoon(context, 'Contact details'),
              ),
              AppSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => _showComingSoon(context, 'Change password'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Preferences'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Booking & status alerts',
                value: 'On',
                onTap: () => _showComingSoon(context, 'Notifications'),
              ),
              AppSettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                value: 'English',
                onTap: () => _showComingSoon(context, 'Language'),
              ),
              AppSettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Location',
                subtitle: 'Default service area',
                onTap: () => _showComingSoon(context, 'Location'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Payments'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                value: 'UPI + Wallet',
                onTap: () => _showComingSoon(context, 'Payment methods'),
              ),
              AppSettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet',
                value: '₹1,250',
                onTap: () => _showComingSoon(context, 'Wallet'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Privacy & Security'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                onTap: () => _showComingSoon(context, 'Privacy'),
              ),
              AppSettingsTile(
                icon: Icons.shield_outlined,
                title: 'Security',
                onTap: () => _showComingSoon(context, 'Security'),
                showDivider: false,
              ),
            ],
          ),
          const SettingsSectionHeader('Support'),
          SettingsCard(
            children: [
              AppSettingsTile(
                icon: Icons.headset_mic_outlined,
                title: 'Help & Support',
                onTap: () => _showComingSoon(context, 'Help & Support'),
              ),
              AppSettingsTile(
                icon: Icons.info_outline,
                title: 'About Coorporate Gig',
                value: 'v1.0.0',
                onTap: () => _showComingSoon(context, 'About'),
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
