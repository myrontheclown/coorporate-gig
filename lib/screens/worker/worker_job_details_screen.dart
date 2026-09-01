import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'worker_active_job_screen.dart';

class WorkerJobDetailsScreen extends StatefulWidget {
  const WorkerJobDetailsScreen({super.key});

  @override
  State<WorkerJobDetailsScreen> createState() =>
      _WorkerJobDetailsScreenState();
}

class _WorkerJobDetailsScreenState extends State<WorkerJobDetailsScreen> {
  String _status = 'new'; // new, accepted, declined

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF1B5E20),
                      child: Text(
                        'PM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priya Mehta',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Client • 4.9★',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: _status == 'accepted'
                          ? 'Accepted'
                          : _status == 'declined'
                              ? 'Declined'
                              : 'New Request',
                      color: _status == 'accepted'
                          ? Colors.green
                          : _status == 'declined'
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _Detail(
                      icon: Icons.plumbing,
                      label: 'Service',
                      value: 'Plumbing Repair',
                    ),
                    const Divider(height: 20),
                    const _Detail(
                      icon: Icons.notes,
                      label: 'Description',
                      value: 'Fix leaking kitchen sink and replace old pipes under the washbasin.',
                    ),
                    const Divider(height: 20),
                    const _Detail(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: 'Flat 402, Royal Residency, Grant Road, Mumbai',
                    ),
                    const Divider(height: 20),
                    const _Detail(
                      icon: Icons.schedule,
                      label: 'Preferred time',
                      value: 'Today, 3:00 PM - 6:00 PM',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Earnings',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '₹1,050',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '3 hrs • ₹350/hr',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_status == 'new')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => setState(() => _status = 'declined'),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _status = 'accepted');
                        AppState.workerOnDuty.value = true;
                      },
                      child: const Text('Accept Job'),
                    ),
                  ),
                ],
              )
            else if (_status == 'accepted')
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => Nav.push(
                      context,
                      const WorkerActiveJobScreen(),
                    ),
                    label: const Text('Start Job / Next Step'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _status = 'declined'),
                    child: const Text('Cancel acceptance'),
                  ),
                ],
              )
            else
              Center(
                child: Column(
                  children: [
                    const Text(
                      'You declined this job',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _status = 'new'),
                      child: const Text('Undo'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Detail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
