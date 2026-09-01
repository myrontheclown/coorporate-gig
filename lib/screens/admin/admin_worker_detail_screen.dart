import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';

class AdminWorkerDetailScreen extends StatelessWidget {
  final String name;
  final String prof;
  final String initials;
  final Color color;
  const AdminWorkerDetailScreen({
    super.key,
    required this.name,
    required this.prof,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Details')),
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
                    CircleAvatarImage(
                      initials: initials,
                      color: color,
                      size: 64,
                      online: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ],
                          ),
                          Text(
                            prof,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const StatusBadge(
                            label: 'On Duty',
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _S(value: '4.8★', label: 'Rating'),
                    _S(value: '48', label: 'Jobs Done'),
                    _S(value: '8 yrs', label: 'Exp'),
                    _S(value: '₹8,450', label: 'This Month'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Availability'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('On Duty'),
                    subtitle: const Text('Receiving job requests'),
                    value: true,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Available for travel'),
                    subtitle: const Text('Up to 10 km radius'),
                    value: true,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: Text('Service Area'),
                    subtitle: Text('Grant Road, Mumbai'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Skills'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Pipe fitting', 'Drainage', 'Leak repair', 'Bathroom fitting',
              ].map((s) => Chip(
                    label: Text(s),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 16),
            const _Heading('Recent Jobs'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _Job(i: 'Plumbing - Priya M.', a: '₹1,050', d: 'Completed', color: Colors.green),
                  const Divider(height: 1),
                  _Job(i: 'Pipe replacement - Sharma', a: '₹900', d: 'Completed', color: Colors.green),
                  const Divider(height: 1),
                  _Job(i: 'Geyser checkup - Anita', a: '₹500', d: 'In Progress', color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Performance'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _Bar(label: 'On-time arrival', value: 0.95),
                    const SizedBox(height: 8),
                    _Bar(label: 'Completion rate', value: 0.98),
                    const SizedBox(height: 8),
                    _Bar(label: 'Response rate', value: 0.88),
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

class _S extends StatelessWidget {
  final String value;
  final String label;
  const _S({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
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

class _Job extends StatelessWidget {
  final String i;
  final String a;
  final String d;
  final Color color;
  const _Job({required this.i, required this.a, required this.d, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(i, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(a, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
      trailing: StatusBadge(label: d, color: color),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  const _Bar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
