import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/verification_badge.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF0284C7),
                      child: Text(
                        'RK',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ramesh Kumar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.verified,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ],
                          ),
                          Text(
                            'Plumber • Grant Road, Mumbai',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '8 years experience',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat2(value: '4.8★', label: 'Rating', color: AppColors.rating),
                const SizedBox(width: 8),
                _Stat2(value: '48', label: 'Jobs Done', color: AppColors.primary),
                const SizedBox(width: 8),
                _Stat2(value: '100%', label: 'On-time', color: AppColors.success),
                const SizedBox(width: 8),
                _Stat2(value: '₹0', label: 'Cancels', color: AppColors.error),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                VerificationBadge(label: 'Aadhaar Verified', emphasized: true),
                VerificationBadge(label: 'Skill Verified'),
                VerificationBadge(label: 'Background Checked'),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.cooperative.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: AppColors.cooperative,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
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
                    const Icon(
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Pipe fitting', 'Drainage systems', 'Leak repair',
                'Bathroom fitting', 'Water tank', 'Geyser repair',
              ].map((s) {
                return Chip(
                  label: Text(s),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                    leading: const Icon(Icons.plumbing, color: AppColors.primary),
                    title: const Text('Plumbing Services'),
                    subtitle: const Text('Active • ₹350/hr'),
                    trailing: Switch(value: true, onChanged: (_) {}),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.ac_unit, color: AppColors.primary),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
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
            Card(
              child: Column(
                children: const [
                  _TxRow(title: 'Plumbing - Priya M.', amount: '+₹1,050'),
                  Divider(height: 1),
                  _TxRow(title: 'Pipe replacement - Sharma', amount: '+₹900'),
                  Divider(height: 1),
                  _TxRow(title: 'Withdrawal to bank', amount: '-₹5,000'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _Heading('Job History'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: const [
                  _JobRow(title: 'Kitchen plumbing - Priya M.', date: '28 Aug', status: 'Completed'),
                  Divider(height: 1),
                  _JobRow(title: 'Pipe replacement - Sharma', date: '25 Aug', status: 'Completed'),
                  Divider(height: 1),
                  _JobRow(title: 'Geyser checkup - Anita', date: '22 Aug', status: 'Completed'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _Heading('My Reviews'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _ReviewRow(name: 'Priya M.', stars: 5, text: 'Excellent work, fixed the sink quickly!', date: '2 weeks ago'),
                    const Divider(height: 16),
                    _ReviewRow(name: 'Amit K.', stars: 5, text: 'Very professional and on time.', date: '1 month ago'),
                    const Divider(height: 16),
                    _ReviewRow(name: 'Neha S.', stars: 4, text: 'Good job overall.', date: '2 months ago'),
                  ],
                ),
              ),
            ),
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
  const _Stat2({required this.value, required this.label, required this.color});

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
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
            const Icon(Icons.account_circle, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star,
                  size: 14,
                  color: i < stars ? Colors.amber : AppColors.divider,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final String title;
  final String amount;
  const _TxRow({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isCredit = amount.startsWith('+');
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  const _JobRow({required this.title, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(date, style: const TextStyle(fontSize: 12)),
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
