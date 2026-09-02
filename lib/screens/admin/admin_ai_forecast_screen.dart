import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// AI Demand Forecasting prototype screen.
///
/// Shows historical demand, AI forecast, expected skill demand and
/// workforce recommendations using simulated (mock) forecast data.
class AdminAiForecastScreen extends StatelessWidget {
  const AdminAiForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Demand Forecast')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MockNotice(),
          SizedBox(height: 16),
          SectionHeader(title: 'Historical Demand → AI Forecast'),
          SizedBox(height: 8),
          Card(child: Padding(padding: EdgeInsets.all(12), child: _ForecastChart())),
          SizedBox(height: 20),
          SectionHeader(title: 'Forecast by Service'),
          SizedBox(height: 8),
          _ForecastRow(
            service: 'Electrician',
            today: 32,
            tomorrow: 41,
            pct: '+28%',
            recommended: 4,
          ),
          _ForecastRow(
            service: 'Plumber',
            today: 26,
            tomorrow: 29,
            pct: '+12%',
            recommended: 2,
          ),
          _ForecastRow(
            service: 'Housekeeping',
            today: 48,
            tomorrow: 52,
            pct: '+8%',
            recommended: 2,
          ),
          _ForecastRow(
            service: 'Carpenter',
            today: 20,
            tomorrow: 19,
            pct: '-5%',
            recommended: 0,
          ),
          SizedBox(height: 20),
          SectionHeader(title: 'Expected Skill Demand'),
          SizedBox(height: 8),
          _SkillDemand(skill: 'Electricians', demand: 0.85, note: 'High growth - electrical & panel work'),
          _SkillDemand(skill: 'Plumbers', demand: 0.6, note: 'Steady growth - pipe & leakage'),
          _SkillDemand(skill: 'Housekeeping', demand: 0.55, note: 'Stable - routine demand'),
          _SkillDemand(skill: 'Carpenters', demand: 0.3, note: 'Low - soft demand'),
          SizedBox(height: 20),
          _WorkforceRecommendation(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MockNotice extends StatelessWidget {
  const _MockNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI Demand Forecast • Prototype. Forecast values are simulated until a live ML service is connected.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastChart extends StatelessWidget {
  static const List<double> _hist = [0.5, 0.7, 0.6, 0.8, 0.7, 0.9, 0.7];
  static const List<double> _forecast = [0.9, 1.0, 1.1, 1.0, 1.2, 1.15, 1.25];
  const _ForecastChart();

  @override
  Widget build(BuildContext context) {
    final all = [..._hist, ..._forecast];
    final maxV = 1.3;
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(all.length, (i) {
              final isForecast = i >= _hist.length;
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
                              ? AppColors.chartAccent
                              : AppColors.primary.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isForecast
                            ? null
                            : null,
                      ),
                      const SizedBox(height: 3),
                      if (i == 6 || i == 13)
                        Text(
                          i == 6 ? 'Today' : 'Next week',
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
            _Legend(color: AppColors.chartAccent, label: 'AI Forecast'),
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

class _ForecastRow extends StatelessWidget {
  final String service;
  final int today;
  final int tomorrow;
  final String pct;
  final int recommended;
  const _ForecastRow({
    required this.service,
    required this.today,
    required this.tomorrow,
    required this.pct,
    required this.recommended,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = pct.startsWith('+');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$service Demand',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                StatusBadge(
                  label: pct,
                  color: isUp ? AppColors.success : AppColors.error,
                  icon: isUp ? Icons.trending_up : Icons.trending_down,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _DemandCell(label: 'Today', value: today.toString()),
                _DemandCell(label: 'Forecast tomorrow', value: tomorrow.toString()),
                _DemandCell(label: 'Expected chg', value: pct),
                _DemandCell(label: 'Rec. workers', value: '$recommended'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemandCell extends StatelessWidget {
  final String label;
  final String value;
  const _DemandCell({required this.label, required this.value});

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
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillDemand extends StatelessWidget {
  final String skill;
  final double demand;
  final String note;
  const _SkillDemand({
    required this.skill,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: LinearProgressIndicator(
                value: demand,
                minHeight: 8,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: AppColors.divider,
                color: demand > 0.7
                    ? AppColors.chartAccent
                    : demand > 0.5
                        ? AppColors.primary
                        : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkforceRecommendation extends StatelessWidget {
  const _WorkforceRecommendation();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cooperative.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.groups, color: AppColors.cooperative),
                SizedBox(width: 8),
                Text(
                  'Workforce Recommendation',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.cooperative,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on the AI demand forecast, the following additional workers are recommended tomorrow:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const _RecLine(skill: 'Electricians', add: 4, color: AppColors.chartAccent),
            const _RecLine(skill: 'Plumbers', add: 2, color: AppColors.chartAccent),
            const _RecLine(skill: 'Housekeeping', add: 2, color: AppColors.chartAccent),
            const _RecLine(skill: 'Carpenters', add: 0, color: AppColors.cooperative),
            const SizedBox(height: 8),
            const StatusBadge(
              label: 'Simulated forecast data',
              color: AppColors.primary,
              icon: Icons.auto_awesome,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecLine extends StatelessWidget {
  final String skill;
  final int add;
  final Color color;
  const _RecLine({required this.skill, required this.add, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(skill, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              add == 0 ? '0 needed' : '+$add workers',
              style: TextStyle(
                color: color,
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