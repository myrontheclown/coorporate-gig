import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'worker_job_details_screen.dart';

class WorkerJobsScreen extends StatefulWidget {
  const WorkerJobsScreen({super.key});

  @override
  State<WorkerJobsScreen> createState() => _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends State<WorkerJobsScreen> {
  int _tab = 0;

  final _upcoming = [
    {'title': 'Kitchen plumbing - Priya M.', 'time': 'Tomorrow, 10:00 AM', 'loc': 'Grant Road', 'amount': '₹1,050', 'status': 'Confirmed'},
    {'title': 'Geyser checkup - Anita D.', 'time': 'Wed, 9:00 AM', 'loc': 'Malad', 'amount': '₹500', 'status': 'Upcoming'},
  ];
  final _history = [
    {'title': 'Pipe replacement - Sharma', 'time': '29 Aug', 'loc': 'Dadar', 'amount': '₹900', 'status': 'Completed'},
    {'title': 'Sink repair - Verma', 'time': '25 Aug', 'loc': 'Andheri', 'amount': '₹750', 'status': 'Completed'},
    {'title': 'Bathroom fitting - Iyer', 'time': '20 Aug', 'loc': 'Powai', 'amount': '₹1,200', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final active =
        _tab == 0 ? _upcoming : _history;
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Tab(label: 'Upcoming', index: 0),
                const SizedBox(width: 8),
                _Tab(label: 'Job History', index: 1),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: active.length,
              itemBuilder: (context, i) {
                final j = active[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkerJobDetailsScreen(),
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.plumbing,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      j['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${j['time']} • ${j['loc']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          j['amount']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        StatusBadge(
                          label: j['status']!,
                          color: j['status'] == 'Completed'
                              ? Colors.green
                              : Colors.indigo,
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
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
