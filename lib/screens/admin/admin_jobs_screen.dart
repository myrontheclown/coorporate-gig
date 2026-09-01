import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'admin_allocation_screen.dart';

class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {
  int _tab = 0;

  final _jobs = [
    {'title': 'Kitchen sink repair', 'client': 'Priya M.', 'service': 'Plumbing', 'status': 'Pending', 'assignee': ''},
    {'title': 'Full house deep cleaning', 'client': 'Rahul V.', 'service': 'Housekeeping', 'status': 'Allocated', 'assignee': 'Sunita Devi'},
    {'title': 'Wiring replacement', 'client': 'Anita D.', 'service': 'Electrician', 'status': 'In Progress', 'assignee': 'Arjun Verma'},
    {'title': 'AC gas refilling', 'client': 'Neha S.', 'service': 'AC Repair', 'status': 'Pending', 'assignee': ''},
    {'title': 'Wardrobe repair', 'client': 'Iyer S.', 'service': 'Carpentry', 'status': 'Allocated', 'assignee': 'Mohammed Ali'},
    {'title': 'Interior painting', 'client': 'Kohli R.', 'service': 'Painting', 'status': 'Pending', 'assignee': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0
        ? _jobs.where((j) => j['status'] == 'Pending').toList()
        : _jobs.where((j) => j['status'] != 'Pending').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs & Allocation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Tab(label: 'Pending (${_jobs.where((j) => j['status'] == 'Pending').length})', index: 0),
                const SizedBox(width: 8),
                _Tab(label: 'Active / Allocated', index: 1),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final j = list[i];
                final isPending = j['status'] == 'Pending';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                              child: const Icon(Icons.work_outline, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                j['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            StatusBadge(
                              label: j['status']!,
                              color: j['status'] == 'Pending'
                                  ? Colors.orange
                                  : j['status'] == 'In Progress'
                                      ? Colors.blue
                                      : Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${j['service']} • Client: ${j['client']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (isPending) ...[
                              const Expanded(
                                child: Text(
                                  'Awaiting allocation',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Nav.push(
                                  context,
                                  const AdminAllocationScreen(),
                                ),
                                child: const Text('Allocate'),
                              ),
                            ] else ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    (j['assignee'] ?? '').isEmpty
                                        ? null
                                        : AppColors.primary,
                                child: (j['assignee'] ?? '').isEmpty
                                    ? null
                                    : Text(
                                        _initials(j['assignee']!),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Assigned: ${j['assignee']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Text(
                                'Track',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2
        ? parts[0][0] + parts[1][0]
        : name.substring(0, 1).toUpperCase();
  }

  Widget _Tab({required String label, required int index}) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
