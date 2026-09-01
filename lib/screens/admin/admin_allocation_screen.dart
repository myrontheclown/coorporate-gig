import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// Workforce Allocation screen.
///
/// Shows current demand, available workers, assigned workers, skill
/// shortages, demand hotspots and recommended allocation cards.
class AdminAllocationScreen extends StatelessWidget {
  const AdminAllocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workforce Allocation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(title: 'Demand vs Supply'),
          SizedBox(height: 8),
          Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  _BarRow(label: 'Current Demand', value: 134, max: 160),
                  SizedBox(height: 8),
                  _BarRow(label: 'Available Workers', value: 128, max: 160, color: AppColors.cooperative),
                  SizedBox(height: 8),
                  _BarRow(label: 'Currently Assigned', value: 42, max: 160, color: AppColors.primary),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SectionHeader(title: 'Skill Shortages'),
          SizedBox(height: 8),
          _Shortage(skill: 'Electricians', short: 4, severity: 0.85),
          _Shortage(skill: 'Plumbers', short: 2, severity: 0.6),
          _Shortage(skill: 'Housekeeping', short: 2, severity: 0.55),
          SizedBox(height: 20),
          SectionHeader(title: 'Demand Hotspots'),
          SizedBox(height: 8),
          _Hotspot(name: 'Panaji', demand: 0.9, skills: 'Electricians, Plumbers'),
          _Hotspot(name: 'Mapusa', demand: 0.7, skills: 'Housekeeping, Electricians'),
          _Hotspot(name: 'Vasco', demand: 0.6, skills: 'Plumbers'),
          SizedBox(height: 20),
          SectionHeader(title: 'Recommended Allocation'),
          SizedBox(height: 8),
          _AllocCard(
            service: 'Electrician',
            area: 'Panaji',
            demand: 'High',
            available: 6,
            required: 9,
            recommended: 3,
            note: 'Panaji requires 3 additional electricians tomorrow.',
            color: AppColors.chartAccent,
          ),
          _AllocCard(
            service: 'Plumber',
            area: 'Mapusa',
            demand: 'Medium',
            available: 8,
            required: 10,
            recommended: 2,
            note: 'Mapusa needs 2 additional plumbers tomorrow.',
            color: AppColors.primary,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color? color;
  const _BarRow({
    required this.label,
    required this.value,
    required this.max,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Row(
      children: [
        SizedBox(
          width: 120,
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
            color: c,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: c,
          ),
        ),
      ],
    );
  }
}

class _Shortage extends StatelessWidget {
  final String skill;
  final int short;
  final double severity;
  const _Shortage({
    required this.skill,
    required this.short,
    required this.severity,
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
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.work_off,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    'Short by $short workers',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                value: severity,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: AppColors.divider,
                color: severity > 0.8 ? AppColors.warning : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hotspot extends StatelessWidget {
  final String name;
  final double demand;
  final String skills;
  const _Hotspot({
    required this.name,
    required this.demand,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(demand * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    skills,
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

class _AllocCard extends StatelessWidget {
  final String service;
  final String area;
  final String demand;
  final int available;
  final int required;
  final int recommended;
  final String note;
  final Color color;
  const _AllocCard({
    required this.service,
    required this.area,
    required this.demand,
    required this.available,
    required this.required,
    required this.recommended,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.bolt, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        area,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: 'Demand: $demand',
                  color: demand == 'High' ? AppColors.warning : AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _AllocStat(label: 'Available', value: '$available'),
                _AllocStat(label: 'Required', value: '$required'),
                _AllocStat(
                  label: 'Recommended',
                  value: '+$recommended',
                  highlight: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _AllocStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.chartAccent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}