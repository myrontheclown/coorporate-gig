import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminAiDashboardScreen extends StatelessWidget {
  const AdminAiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Operations Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AiHeader(),
            const SizedBox(height: 16),
            const _Heading('Demand Forecast - Next Week'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _ForecastChart(),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Demand Hotspots'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _Hotspot(name: 'Grant Road', demand: 92, icons: 'Plumbing, Housekeeping'),
                  const Divider(height: 1),
                  _Hotspot(name: 'Dadar', demand: 78, icons: 'Electrician, Painting'),
                  const Divider(height: 1),
                  _Hotspot(name: 'Andheri West', demand: 65, icons: 'AC Repair, Housekeeping'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Skill Gaps'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SkillGap(skill: 'AC Technicians', gap: 'Need 3 more', severity: 0.85),
                  const Divider(height: 1, indent: 16),
                  _SkillGap(skill: 'Trained Cleaners', gap: 'Need 5 more', severity: 0.7),
                  const Divider(height: 1, indent: 16),
                  _SkillGap(skill: 'Carpenters', gap: 'Need 2 more', severity: 0.6),
                  const Divider(height: 1, indent: 16),
                  _SkillGap(skill: 'Safety-certified', gap: 'Need 4 more', severity: 0.75),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Workforce vs Demand'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _WorkforceBar(label: 'Required Workforce', value: 156, max: 160, color: AppColors.primary),
                    const SizedBox(height: 8),
                    _WorkforceBar(label: 'Available Workforce', value: 128, max: 160, color: Colors.green),
                    const SizedBox(height: 8),
                    _WorkforceBar(label: 'Currently Allocated', value: 42, max: 160, color: Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('AI Recommended Allocation'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
                        SizedBox(width: 8),
                        Text(
                          'Suggested: Allocate 14 workers\nto Grant Road hotspot',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _AllocRow(prof: 'Plumbers', current: 32, needed: 40, recommended: '8'),
                    _AllocRow(prof: 'Cleaners', current: 45, needed: 50, recommended: '5'),
                    _AllocRow(prof: 'Electricians', current: 20, needed: 27, recommended: '7'),
                    const SizedBox(height: 8),
                    const StatusBadge(
                      label: 'AI confidence 92%',
                      color: Colors.green,
                      icon: Icons.auto_awesome,
                    ),
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

class _AiHeader extends StatelessWidget {
  const _AiHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GigForce AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Demand forecasting & intelligent workforce allocation',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: 'Live',
            color: Colors.greenAccent,
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
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _ForecastChart extends StatelessWidget {
  final List<double> hist = [0.5, 0.7, 0.6, 0.8, 0.7, 0.9, 0.7];
  final List<double> forecast = [0.9, 1.0, 1.1, 1.0, 1.2, 1.15, 1.25];
  @override
  Widget build(BuildContext context) {
    final all = [...hist, ...forecast];
    final maxV = 1.3;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(all.length, (i) {
              final isForecast = i >= hist.length;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 140 * (all[i] / maxV),
                        decoration: BoxDecoration(
                          color: isForecast
                              ? AppColors.accent
                              : AppColors.primary.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: isForecast
                              ? Border.all(
                                  color: AppColors.accentLight,
                                  width: 1,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (i == 6 || i == 13)
                        Text(
                          days[i],
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Legend(color: AppColors.primary.withValues(alpha: 0.7), label: 'Historical'),
            const SizedBox(width: 16),
            _Legend(color: AppColors.accent, label: 'AI Forecast'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Hotspot extends StatelessWidget {
  final String name;
  final int demand;
  final String icons;
  const _Hotspot({required this.name, required this.demand, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(
                      '$demand%',
                      style: TextStyle(
                        color: demand > 80 ? Colors.deepOrange : AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(icons, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: demand / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: AppColors.divider,
              color: demand > 80 ? Colors.deepOrange : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillGap extends StatelessWidget {
  final String skill;
  final String gap;
  final double severity;
  const _SkillGap({required this.skill, required this.gap, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.work_off, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(gap, style: const TextStyle(fontSize: 11, color: Colors.red)),
              ],
            ),
          ),
          StatusBadge(
            label: severity > 0.8 ? 'Critical' : 'Moderate',
            color: severity > 0.8 ? Colors.red : Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _WorkforceBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  const _WorkforceBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / max,
            minHeight: 10,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: AppColors.divider,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AllocRow extends StatelessWidget {
  final String prof;
  final int current;
  final int needed;
  final String recommended;
  const _AllocRow({
    required this.prof,
    required this.current,
    required this.needed,
    required this.recommended,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.build, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(prof, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text(
            '$current → $needed',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$recommended',
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
