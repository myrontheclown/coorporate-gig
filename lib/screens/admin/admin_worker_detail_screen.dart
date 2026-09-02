import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';

class AdminWorkerDetailScreen extends StatelessWidget {
  final Worker worker;
  const AdminWorkerDetailScreen({super.key, required this.worker});

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
                      initials: worker.avatarInitials,
                      color: worker.color,
                      size: 64,
                      online: worker.available,
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
                                  worker.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (worker.verified) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            worker.profession,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          StatusBadge(
                            label: worker.available
                                ? worker.bestMatch
                                    ? 'On Duty'
                                    : 'Available'
                                : 'Inactive',
                            color: worker.available
                                ? AppColors.success
                                : AppColors.textMuted,
                            icon: worker.available
                                ? Icons.check_circle
                                : Icons.pause_circle,
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
                    _S(value: '${worker.ratingLabel}★', label: 'Rating'),
                    _S(value: worker.jobsCompleted.toString(), label: 'Jobs Done'),
                    _S(value: worker.experience, label: 'Exp'),
                    _S(
                      value: '₹${worker.pricePerHour.toInt()}',
                      label: '/hr',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Verification'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Aadhaar Verified'),
                    subtitle: const Text('Identity verified'),
                    value: worker.verified,
                    activeTrackColor: AppColors.success.withValues(alpha: 0.4),
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Skill Verified'),
                    subtitle: const Text('Practical assessment passed'),
                    value: worker.skillVerified,
                    activeTrackColor: AppColors.success.withValues(alpha: 0.4),
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('On Duty'),
                    subtitle: const Text('Receiving job requests'),
                    value: worker.available,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Cooperative'),
            const SizedBox(height: 8),
            Card(
              color: AppColors.cooperative.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: AppColors.cooperative,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        worker.cooperative.isEmpty
                            ? 'Not affiliated'
                            : worker.cooperative,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.cooperative,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Heading('Skills'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: worker.skills.map((s) {
                return Chip(
                  label: Text(s),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.handyman_outlined),
                onPressed: () => _showAssignJob(context),
                label: const Text('Assign to Job'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignJob(BuildContext context) {
    const jobs = [
      (title: 'Pipe leak repair', location: 'Fatorda', loc: 'B2-104'),
      (title: 'AC servicing', location: 'Margao', loc: '3rd Floor'),
      (title: 'House deep clean', location: 'Vasco', loc: 'Flat 5'),
      (title: 'Furniture assembly', location: 'Ponda', loc: 'Shop 12'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign ${worker.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pending jobs in your cooperative',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                for (final job in jobs)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.build_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${job.location} • ${job.loc}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Assigned ${worker.name} to "${job.title}".',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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