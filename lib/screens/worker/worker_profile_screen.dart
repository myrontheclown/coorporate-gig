import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../screens/role_selection/role_selection_screen.dart';
import '../../services/auth_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/verification_badge.dart';
import 'worker_settings_screen.dart';
import 'worker_profile_edit_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final worker = AppState.currentWorkerProfile.value;

    if (worker == null) return;

    final skills = await WorkerProfileService.getWorkerSkills(worker.id);

    if (!mounted) return;

    setState(() {
      _skills = skills;
    });
  }

  void _openEditProfile() {
    Nav.push(
      context,
      const WorkerEditProfileScreen(),
    );

    // Refresh the profile when returning from Edit Profile.
    _loadSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Nav.push(
                context,
                const WorkerSettingsScreen(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: AppState.currentUserProfile,
              builder: (context, user, _) {
                final worker = AppState.currentWorkerProfile.value;

                final name = user?.fullName.isNotEmpty == true
                    ? user!.fullName
                    : 'Ramesh Kumar';

                final location = user?.city.isNotEmpty == true
                    ? 'Plumber • ${user!.city}'
                    : 'Plumber • Grant Road, Mumbai';

                final exp =
                    worker?.experienceYears != null &&
                            worker!.experienceYears > 0
                        ? '${worker.experienceYears} years experience'
                        : '8 years experience';

                final initials = name
                    .trim()
                    .split(' ')
                    .map((p) => p.isNotEmpty ? p[0] : '')
                    .take(2)
                    .join()
                    .toUpperCase();

                return InkWell(
                  onTap: _openEditProfile,
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              initials.isNotEmpty ? initials : 'RK',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  exp,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: const [
                _Stat2(
                  value: '4.8★',
                  label: 'Rating',
                  color: AppColors.rating,
                ),
                SizedBox(width: 8),
                _Stat2(
                  value: '48',
                  label: 'Jobs Done',
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                _Stat2(
                  value: '100%',
                  label: 'On-time',
                  color: AppColors.success,
                ),
                SizedBox(width: 8),
                _Stat2(
                  value: '₹0',
                  label: 'Cancels',
                  color: AppColors.error,
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                VerificationBadge(
                  label: 'Aadhaar Verified',
                  emphasized: true,
                ),
                VerificationBadge(
                  label: 'Skill Verified',
                ),
                VerificationBadge(
                  label: 'Background Checked',
                ),
              ],
            ),

            const SizedBox(height: 16),

            Card(
              color: AppColors.cooperative.withValues(alpha: 0.06),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: AppColors.cooperative,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mumbai Workers Cooperative',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.cooperative,
                            ),
                          ),
                          Text(
                            'Member since 2019',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.cooperative,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.verified_user,
                      color: AppColors.cooperative,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const _Heading('My Skills'),
            const SizedBox(height: 8),

            _skills.isEmpty
                ? const Text(
                    'No skills added yet.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            const _Heading('My Services'),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.plumbing,
                      color: AppColors.primary,
                    ),
                    title: const Text('Plumbing Services'),
                    subtitle: const Text('Active • ₹350/hr'),
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(
                      Icons.ac_unit,
                      color: AppColors.primary,
                    ),
                    title: Text('Geyser Repair'),
                    subtitle: Text('Inactive • ₹300/hr'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const _Heading('Earnings & Transactions'),
            const SizedBox(height: 8),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹12,500',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Available in Gig Wallet',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹0 pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Card(
              child: Column(
                children: [
                  _TxRow(
                    title: 'Plumbing - Priya M.',
                    amount: '+₹1,050',
                  ),
                  Divider(height: 1),
                  _TxRow(
                    title: 'Pipe replacement - Sharma',
                    amount: '+₹900',
                  ),
                  Divider(height: 1),
                  _TxRow(
                    title: 'Withdrawal to bank',
                    amount: '-₹5,000',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const _Heading('Job History'),
            const SizedBox(height: 8),

            const Card(
              child: Column(
                children: [
                  _JobRow(
                    title: 'Kitchen plumbing - Priya M.',
                    date: '28 Aug',
                    status: 'Completed',
                  ),
                  Divider(height: 1),
                  _JobRow(
                    title: 'Pipe replacement - Sharma',
                    date: '25 Aug',
                    status: 'Completed',
                  ),
                  Divider(height: 1),
                  _JobRow(
                    title: 'Geyser checkup - Anita',
                    date: '22 Aug',
                    status: 'Completed',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const _Heading('My Reviews'),
            const SizedBox(height: 8),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    _ReviewRow(
                      name: 'Priya M.',
                      stars: 5,
                      text: 'Excellent work, fixed the sink quickly!',
                      date: '2 weeks ago',
                    ),
                    SizedBox(height: 16),
                    _ReviewRow(
                      name: 'Amit K.',
                      stars: 5,
                      text: 'Very professional and on time.',
                      date: '1 month ago',
                    ),
                    SizedBox(height: 16),
                    _ReviewRow(
                      name: 'Neha S.',
                      stars: 4,
                      text: 'Good job overall.',
                      date: '2 months ago',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                ),
                title: const Text('Logout / Switch Role'),
                onTap: () async {
                  await AuthService.signOut();

                  if (context.mounted) {
                    AppState.reset();
                    Nav.clearAll(
                      context,
                      const RoleSelectionScreen(),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Stat2 extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Stat2({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
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

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String name;
  final int stars;
  final String text;
  final String date;

  const _ReviewRow({
    required this.name,
    required this.stars,
    required this.text,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.account_circle,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star,
                  size: 14,
                  color: i < stars
                      ? AppColors.rating
                      : AppColors.divider,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final String title;
  final String amount;

  const _TxRow({
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = amount.startsWith('+');

    return ListTile(
      dense: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: isCredit
              ? AppColors.success
              : AppColors.error,
        ),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  final String title;
  final String date;
  final String status;

  const _JobRow({
    required this.title,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        status,
        style: const TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}