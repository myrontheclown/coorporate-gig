import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';

class AdminAllocationScreen extends StatefulWidget {
  const AdminAllocationScreen({super.key});

  @override
  State<AdminAllocationScreen> createState() => _AdminAllocationScreenState();
}

class _AdminAllocationScreenState extends State<AdminAllocationScreen> {
  int? _selected;
  bool _allocated = false;
  bool _loading = false;

  final List<Map<String, dynamic>> _candidates = [
    {'name': 'Suresh Yadav', 'prof': 'Plumber', 'score': 96, 'dist': '1.2 km', 'free': '2:30 PM', 'initials': 'SY', 'color': Color(0xFF0EA5E9)},
    {'name': 'Rajesh Kumar', 'prof': 'Plumber', 'score': 88, 'dist': '2.4 km', 'free': '3:00 PM', 'initials': 'RK', 'color': Color(0xFF0284C7)},
    {'name': 'Dinesh Patil', 'prof': 'Plumber', 'score': 74, 'dist': '3.1 km', 'free': '4:00 PM', 'initials': 'DP', 'color': Color(0xFF334155)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Allocation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
                SizedBox(width: 8),
                Text(
                  'AI Recommended Allocation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Top workers ranked by availability, distance, rating & skill match',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < _candidates.length; i++)
              _CandidateTile(
                candidate: _candidates[i],
                rank: i + 1,
                selected: _selected == i,
                onTap: () {
                  if (!_allocated) setState(() => _selected = i);
                },
              ),
            const SizedBox(height: 20),
            if (_allocated)
              _AllocatedCard(name: _candidates[_selected!]['name']!)
            else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.handshake),
                onPressed: _selected == null
                    ? null
                    : () {
                        setState(() => _loading = true);
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              _loading = false;
                              _allocated = true;
                            });
                          }
                        });
                      },
                label: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Allocate AI Top Match'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Manual Override'),
              ),
            ],
            if (_allocated) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _allocated = false;
                      _selected = null;
                    });
                  },
                  child: const Text('Re-assign'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final int rank;
  final bool selected;
  final VoidCallback onTap;

  const _CandidateTile({
    required this.candidate,
    required this.rank,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              rank == 1
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatarImage(
                          initials: candidate['initials'],
                          color: candidate['color'],
                          size: 44,
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    )
                  : CircleAvatarImage(
                      initials: candidate['initials'],
                      color: candidate['color'],
                      size: 44,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          candidate['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${candidate['score']}% match',
                          style: TextStyle(
                            color: (candidate['score'] as int) > 90
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${candidate['prof']} • ${candidate['dist']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Free from ${candidate['free']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllocatedCard extends StatelessWidget {
  final String name;
  const _AllocatedCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 8),
              const Text(
                'Job Allocated!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '$name has been notified',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const StatusBadge(
                label: 'Client & worker notified',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Nav.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
