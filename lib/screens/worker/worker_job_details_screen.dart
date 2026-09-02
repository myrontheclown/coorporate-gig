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
                      backgroundColor: AppColors.primary,
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
                          ? AppColors.success
                          : _status == 'declined'
                              ? AppColors.error
                              : AppColors.warning,
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
                    const SizedBox(height: 20),
                    const _Detail(
                      icon: Icons.notes,
                      label: 'Description',
                      value: 'Fix leaking kitchen sink and replace old pipes under the washbasin.',
                    ),
                    const SizedBox(height: 20),
                    const _Detail(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: 'Flat 402, Royal Residency, Grant Road, Mumbai',
                    ),
                    const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            // Attached photos
            const _Heading('Attached Photos'),
            const SizedBox(height: 8),
            Row(
              children: [
                _PhotoTile(icon: Icons.photo_camera_outlined, label: 'Sink photo'),
                const SizedBox(width: 8),
                _PhotoTile(icon: Icons.photo_camera_outlined, label: 'Pipes'),
                const SizedBox(width: 8),
                _PhotoTile(icon: Icons.add_a_photo_outlined, label: 'Add more'),
              ],
            ),
            const SizedBox(height: 16),
            // OTP handoff process
            Card(
              color: AppColors.primary.withValues(alpha: 0.06),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'On arrival, ask the client to share the OTP to securely start the service.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
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
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
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
                      style: TextStyle(color: AppColors.error),
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

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PhotoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
