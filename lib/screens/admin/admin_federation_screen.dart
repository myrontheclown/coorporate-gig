import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

class AdminFederationScreen extends StatelessWidget {
  const AdminFederationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Federation Administration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FederationHero(),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  _Stat(v: '12', l: 'Cooperatives', accent: true),
                  _Stat(v: '428', l: 'Total Workers'),
                  _Stat(v: '86', l: 'Active Services'),
                  _Stat(v: '134', l: "Today's Demand"),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SectionHeader(title: 'Federated Cooperatives'),
          SizedBox(height: 8),
          _Coop(name: 'Shram Shakti Plumbers Coop', members: 92, jobs: 34, load: 0.8),
          _Coop(name: 'Goa Domestic Workers Coop', members: 188, jobs: 56, load: 0.65),
          _Coop(name: 'Mapusa Electricians Union', members: 61, jobs: 22, load: 0.55),
          SizedBox(height: 20),
          SectionHeader(title: 'Regional Demand'),
          SizedBox(height: 8),
          _Region(name: 'Panaji', demand: 0.9, note: 'High - electricians needed'),
          _Region(name: 'Mapusa', demand: 0.7, note: 'Moderate - housekeeping'),
          _Region(name: 'Vasco', demand: 0.55, note: 'Steady - plumbers'),
          SizedBox(height: 20),
          SectionHeader(title: 'Federation Administration'),
          SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _AdminTile(
                  icon: Icons.verified_user,
                  title: 'Verification & Onboarding',
                  subtitle: '18 pending requests',
                ),
                Divider(height: 1, indent: 56),
                _AdminTile(
                  icon: Icons.school,
                  title: 'Training Programs',
                  subtitle: '2 active batches',
                ),
                Divider(height: 1, indent: 56),
                _AdminTile(
                  icon: Icons.price_change,
                  title: 'Rate Regulation',
                  subtitle: 'Standard ₹200-₹500/hr',
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FederationHero extends StatelessWidget {
  const _FederationHero();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cooperative,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Goa Federation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                StatusBadge(
                  label: 'Active',
                  color: AppColors.success,
                ),
              ],
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cooperative federation • India',
                style: TextStyle(color: Colors.white70, fontSize: 12),
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
  final bool accent;
  const _Stat({required this.v, required this.l, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            v,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accent ? AppColors.cooperative : AppColors.textPrimary,
            ),
          ),
          Text(
            l,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Coop extends StatelessWidget {
  final String name;
  final int members;
  final int jobs;
  final double load;
  const _Coop({
    required this.name,
    required this.members,
    required this.jobs,
    required this.load,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cooperative.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.groups,
                color: AppColors.cooperative,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '$members members • $jobs active jobs',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                StatusBadge(
                  label: load > 0.75 ? 'High load' : 'Balanced',
                  color: load > 0.75 ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(load * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Region extends StatelessWidget {
  final String name;
  final double demand;
  final String note;
  const _Region({
    required this.name,
    required this.demand,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.chartAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              child: LinearProgressIndicator(
                value: demand,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: AppColors.divider,
                color: demand > 0.8 ? AppColors.chartAccent : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.cooperative),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}