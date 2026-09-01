import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../data/mock_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = UserData.requests;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New request flow coming from Home')),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          return _RequestCard(request: r);
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final UserRequest request;
  const _RequestCard({required this.request});

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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconFor(request.service),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.service,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        request.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(request.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              request.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (request.workerName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.workerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (request.status == 'Matched') ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    late Color color;
    late IconData icon;
    switch (status) {
      case 'In Progress':
        color = Colors.blue;
        icon = Icons.build;
        break;
      case 'Completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Matched':
        color = AppColors.primary;
        icon = Icons.handshake;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top;
    }
    return StatusBadge(label: status, color: color, icon: icon);
  }

  IconData _iconFor(String service) {
    switch (service) {
      case 'Plumbing':
        return Icons.plumbing;
      case 'Housekeeping':
        return Icons.cleaning_services;
      case 'AC Repair':
        return Icons.ac_unit;
      case 'Carpentry':
        return Icons.construction;
      default:
        return Icons.build;
    }
  }
}
