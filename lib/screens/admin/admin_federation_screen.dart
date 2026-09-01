import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminFederationScreen extends StatelessWidget {
  const AdminFederationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cooperative Federation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Shram Shakti Cooperative\nFederation, Mumbai',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: 'Active',
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Stat(v: '28', l: 'Cooperatives'),
                        _Stat(v: '1,850', l: 'Workers'),
                        _Stat(v: '₹12L', l: 'Monthly GMV'),
                        _Stat(v: '96%', l: 'Fulfillment'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Federated Cooperatives'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _Coop(name: 'Mumbai Plumbers Coop', members: 42, jobs: 18, load: 0.8),
                  const Divider(height: 1, indent: 16),
                  _Coop(name: 'Andheri Domestic Workers', members: 68, jobs: 24, load: 0.65),
                  const Divider(height: 1, indent: 16),
                  _Coop(name: 'Dadar Electricians Union', members: 31, jobs: 12, load: 0.55),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Workforce Overview'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _OverviewRow(label: 'Total Workforce', value: '1,850'),
                    _OverviewRow(label: 'On Duty', value: '742', color: Colors.green),
                    _OverviewRow(label: 'Available', value: '520', color: Colors.blue),
                    _OverviewRow(label: 'On Leave / Training', value: '588', color: Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Federation Administration'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _AdminTile(icon: Icons.verified_user, title: 'Verification & Onboarding', subtitle: '124 pending requests', color: AppColors.primary),
                  const Divider(height: 1),
                  _AdminTile(icon: Icons.school, title: 'Training Programs', subtitle: '3 active batches', color: Colors.purple),
                  const Divider(height: 1),
                  _AdminTile(icon: Icons.price_change, title: 'Rate Regulation', subtitle: 'Standard ₹200-₹500/hr', color: Colors.teal),
                  const Divider(height: 1),
                  _AdminTile(icon: Icons.tune, title: 'Inter-cooperative Dispatch', subtitle: 'Cross-coop job sharing', color: Colors.indigo),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Cross-Cooperative Network Graph'),
            const SizedBox(height: 8),
            Card(
              child: SizedBox(
                height: 160,
                child: Center(
                  child: _NetworkGraph(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String v;
  final String l;
  const _Stat({required this.v, required this.l});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            v,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            l,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  }
}

class _Coop extends StatelessWidget {
  final String name;
  final int members;
  final int jobs;
  final double load;
  const _Coop({required this.name, required this.members, required this.jobs, required this.load});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.groups, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('$members members • $jobs active jobs', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            children: [
              StatusBadge(
                label: load > 0.75 ? 'High load' : 'Balanced',
                color: load > 0.75 ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 4),
              Text(
                '${(load * 100).toInt()}%',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _OverviewRow({required this.label, required this.value, this.color});

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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _AdminTile({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}

class _NetworkGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Mumbai Federation', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Node(label: 'Plumbers', color: Colors.blue),
            _Node(label: 'Cleaning', color: Colors.green),
            _Node(label: 'Electric', color: Colors.amber),
            _Node(label: 'Carpentry', color: Colors.brown),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Jobs shared across cooperatives',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final String label;
  final Color color;
  const _Node({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(Icons.groups, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
