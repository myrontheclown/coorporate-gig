import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'customer';

  static const _roles = [
    _RoleData(
      key: 'customer',
      icon: Icons.person_outline,
      color: AppColors.primary,
      title: 'Client',
      description: 'Find trusted local workers',
    ),
    _RoleData(
      key: 'worker',
      icon: Icons.engineering_outlined,
      color: AppColors.cooperative,
      title: 'Worker',
      description: 'Find jobs and grow your work',
    ),
    _RoleData(
      key: 'cooperative_admin',
      icon: Icons.account_balance_outlined,
      color: AppColors.warning,
      title: 'Cooperative Admin',
      description: 'Manage workers and services',
    ),
  ];

  void _handleContinue() {
    Nav.toSignIn(context, _selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Coorporate Gig',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Trusted community professionals & cooperatives',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Welcome to Coorporate Gig',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select how you'd like to continue.",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < _roles.length; i++) ...[
              _RoleSelectionCard(
                data: _roles[i],
                selected: _selectedRole == _roles[i].key,
                onTap: () {
                  setState(() => _selectedRole = _roles[i].key);
                },
              ),
              if (i < _roles.length - 1) const SizedBox(height: 14),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _handleContinue,
                child: const Text('Continue'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RoleData {
  final String key;
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _RoleData({
    required this.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

class _RoleSelectionCard extends StatelessWidget {
  final _RoleData data;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSelectionCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? data.color : AppColors.divider,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected
                      ? data.color
                      : data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  data.icon,
                  color: selected ? Colors.white : data.color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: selected ? data.color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? data.color : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
