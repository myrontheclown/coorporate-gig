import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_settings.dart';

class WorkerSettingsScreen extends StatelessWidget {
  const WorkerSettingsScreen({super.key});

  void _showInfoPage(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsInfoScreen(
          title: title,
          children: children,
        ),
      ),
    );
  }

  Future<void> _showSkills(BuildContext context) async {
    final worker = AppState.currentWorkerProfile.value;

    if (worker == null) {
      _showInfoPage(
        context,
        'Skills',
        const [
          _InfoRow(
            label: 'Skills',
            value: 'No worker profile found.',
          ),
        ],
      );
      return;
    }

    final skills =
        await WorkerProfileService.getWorkerSkills(worker.id);

    if (!context.mounted) return;

    _showInfoPage(
      context,
      'Skills',
      [
        if (skills.isEmpty)
          const _InfoRow(
            label: 'Skills',
            value: 'No skills added yet.',
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

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
    final user = AppState.currentUserProfile.value;
    final worker = AppState.currentWorkerProfile.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
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
                onTap: () {
                  _showInfoPage(
                    context,
                    'Personal Information',
                    [
                      _InfoRow(
                        label: 'Full Name',
                        value: user?.fullName.isNotEmpty == true
                            ? user!.fullName
                            : 'Not provided',
                      ),
                      _InfoRow(
                        label: 'Email',
                        value: user?.email.isNotEmpty == true
                            ? user!.email
                            : 'Not provided',
                      ),
                      _InfoRow(
                        label: 'Phone',
                        value: user?.phone.isNotEmpty == true
                            ? user!.phone
                            : 'Not provided',
                      ),
                    ],
                  );
                },
              ),

              AppSettingsTile(
                icon: Icons.contact_phone_outlined,
                title: 'Contact Information',
                subtitle: 'Phone & emergency contact',
                onTap: () {
                  _showInfoPage(
                    context,
                    'Contact Information',
                    [
                      _InfoRow(
                        label: 'Phone',
                        value: user?.phone.isNotEmpty == true
                            ? user!.phone
                            : 'Not provided',
                      ),
                      _InfoRow(
                        label: 'Emergency Contact',
                        value: worker
                                    ?.emergencyContactName
                                    .isNotEmpty ==
                                true
                            ? worker!.emergencyContactName
                            : 'Not provided',
                      ),
                      _InfoRow(
                        label: 'Emergency Phone',
                        value: worker
                                    ?.emergencyContactPhone
                                    .isNotEmpty ==
                                true
                            ? worker!.emergencyContactPhone
                            : 'Not provided',
                      ),
                    ],
                  );
                },
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
                onTap: () => _showSkills(context),
              ),

              AppSettingsTile(
                icon: Icons.map_outlined,
                title: 'Service Areas',
                subtitle: 'Where you work',
                onTap: () {
                  _showInfoPage(
                    context,
                    'Service Areas',
                    [
                      _InfoRow(
                        label: 'Service Area',
                        value: worker?.serviceArea.isNotEmpty == true
                            ? worker!.serviceArea
                            : 'Not provided',
                      ),
                      _InfoRow(
                        label: 'Working Area',
                        value: worker?.workingArea.isNotEmpty == true
                            ? worker!.workingArea
                            : 'Not provided',
                      ),
                    ],
                  );
                },
              ),

              AppSettingsTile(
                icon: Icons.toggle_on_outlined,
                title: 'Availability',
                subtitle: 'On-duty & off-duty hours',
                value: 'On',
                onTap: () =>
                    _showComingSoon(context, 'Availability'),
              ),

              AppSettingsTile(
                icon: Icons.schedule_outlined,
                title: 'Working Hours',
                onTap: () =>
                    _showComingSoon(context, 'Working hours'),
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
                onTap: () =>
                    _showComingSoon(context, 'Job alerts'),
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
                onTap: () =>
                    _showComingSoon(context, 'Payment details'),
              ),

              AppSettingsTile(
                icon: Icons.payments_outlined,
                title: 'Earnings',
                subtitle: 'Statements & reports',
                onTap: () =>
                    _showComingSoon(context, 'Earnings'),
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
                onTap: () => _showComingSoon(
                  context,
                  'Identity verification',
                ),
              ),

              AppSettingsTile(
                icon: Icons.fact_check_outlined,
                title: 'Skills Verification',
                subtitle: 'Practical assessment',
                value: 'Verified',
                iconColor: AppColors.success,
                onTap: () => _showComingSoon(
                  context,
                  'Skills verification',
                ),
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
                onTap: () =>
                    _showComingSoon(context, 'Privacy'),
              ),

              AppSettingsTile(
                icon: Icons.headset_mic_outlined,
                title: 'Help & Support',
                onTap: () =>
                    _showComingSoon(context, 'Help & Support'),
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 22,
                ),
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

class _SettingsInfoScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsInfoScreen({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}