import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'worker_job_details_screen.dart';

class WorkerJobRequestsScreen extends StatefulWidget {
  const WorkerJobRequestsScreen({super.key});

  @override
  State<WorkerJobRequestsScreen> createState() =>
      _WorkerJobRequestsScreenState();
}

class _WorkerJobRequestsScreenState extends State<WorkerJobRequestsScreen> {
  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'j1',
      'service': 'Plumbing',
      'client': 'Mrs. Priya',
      'detail': 'Fix leaking kitchen sink & replace pipes',
      'amount': 1050,
      'distance': '1.2 km',
      'time': 'Today, 3:00 PM',
      'status': 'new',
    },
    {
      'id': 'j2',
      'service': 'Plumbing',
      'client': 'Mr. Sharma',
      'detail': 'Bathroom water tank installation',
      'amount': 900,
      'distance': '2.8 km',
      'time': 'Today, 5:00 PM',
      'status': 'new',
    },
    {
      'id': 'j3',
      'service': 'Plumbing',
      'client': 'Ms. Anita',
      'detail': 'Geyser not heating, needs checkup',
      'amount': 500,
      'distance': '3.5 km',
      'time': 'Tomorrow, 9:00 AM',
      'status': 'new',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Job Requests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, i) {
          final r = _requests[i];
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.plumbing,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['service'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              r['client'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge(
                        label: 'New',
                        color: Colors.orange,
                        icon: Icons.new_releases,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    r['detail'],
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        r['distance'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        r['time'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '₹${r['amount']}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _decline(i),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Nav.push(
                            context,
                            const WorkerJobDetailsScreen(),
                          ),
                          child: const Text('View & Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _decline(int index) {
    setState(() => _requests.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request declined')),
    );
  }
}
