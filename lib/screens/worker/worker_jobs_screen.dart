import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'worker_active_job_screen.dart';
import 'worker_job_details_screen.dart';

class WorkerJobsScreen extends StatefulWidget {
  const WorkerJobsScreen({super.key});

  @override
  State<WorkerJobsScreen> createState() => _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends State<WorkerJobsScreen> {
  int _tab = 0;

  static const _tabs = ['New', 'Upcoming', 'Active', 'Completed'];

  final _new = [
    _Job(
      client: 'Mrs. Priya',
      service: 'Plumbing',
      location: 'Grant Road',
      time: 'Today, 3:00 PM',
      distance: '1.2 km',
      earnings: '₹1,050',
      status: 'New',
      detail: 'Fix leaking kitchen sink & replace pipes',
    ),
    _Job(
      client: 'Mr. Sharma',
      service: 'Plumbing',
      location: 'Dadar',
      time: 'Today, 5:00 PM',
      distance: '2.8 km',
      earnings: '₹900',
      status: 'New',
      detail: 'Bathroom water tank installation',
    ),
  ];

  final _upcoming = [
    _Job(
      client: 'Ms. Priya',
      service: 'Plumbing',
      location: 'Grant Road',
      time: 'Tomorrow, 10:00 AM',
      distance: '1.0 km',
      earnings: '₹1,050',
      status: 'Confirmed',
      detail: 'Kitchen plumbing work',
    ),
    _Job(
      client: 'Ms. Anita',
      service: 'Plumbing',
      location: 'Malad',
      time: 'Wed, 9:00 AM',
      distance: '4.2 km',
      earnings: '₹500',
      status: 'Upcoming',
      detail: 'Geyser not heating, needs checkup',
    ),
  ];

  final _active = [
    _Job(
      client: 'Ms. Priya',
      service: 'Plumbing',
      location: 'Grant Road',
      time: 'Started 2:00 PM',
      distance: '1.0 km',
      earnings: '₹1,050',
      status: 'In Progress',
      detail: 'Kitchen sink repair - in progress',
    ),
  ];

  final _completed = [
    _Job(
      client: 'Sharma family',
      service: 'Plumbing',
      location: 'Dadar',
      time: '29 Aug',
      distance: '2.8 km',
      earnings: '₹900',
      status: 'Completed',
      detail: 'Pipe replacement',
    ),
    _Job(
      client: 'Verma S.',
      service: 'Plumbing',
      location: 'Andheri',
      time: '25 Aug',
      distance: '3.1 km',
      earnings: '₹750',
      status: 'Completed',
      detail: 'Sink repair',
    ),
    _Job(
      client: 'Iyer S.',
      service: 'Plumbing',
      location: 'Powai',
      time: '20 Aug',
      distance: '5.4 km',
      earnings: '₹1,200',
      status: 'Completed',
      detail: 'Bathroom fitting',
    ),
  ];

  List<_Job> get _current {
    switch (_tab) {
      case 0:
        return _new;
      case 1:
        return _upcoming;
      case 2:
        return _active;
      case 3:
        return _completed;
      default:
        return _new;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return _Tab(
                    label: _tabs[i],
                    count: _countFor(i),
                    selected: _tab == i,
                    onTap: () => setState(() => _tab = i),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: _current.length,
              itemBuilder: (context, i) {
                return _JobCard(
                  job: _current[i],
                  onTap: () {
                    if (_current[i].status == 'In Progress') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerActiveJobScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerJobDetailsScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _countFor(int tab) {
    switch (tab) {
      case 0:
        return _new.length;
      case 1:
        return _upcoming.length;
      case 2:
        return _active.length;
      case 3:
        return _completed.length;
      default:
        return 0;
    }
  }
}

class _Job {
  final String client;
  final String service;
  final String location;
  final String time;
  final String distance;
  final String earnings;
  final String status;
  final String detail;

  const _Job({
    required this.client,
    required this.service,
    required this.location,
    required this.time,
    required this.distance,
    required this.earnings,
    required this.status,
    required this.detail,
  });
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(
            count > 0 ? '$label ($count)' : label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final _Job job;
  final VoidCallback onTap;
  const _JobCard({required this.job, required this.onTap});

  Color get _statusColor {
    switch (job.status) {
      case 'New':
        return AppColors.warning;
      case 'In Progress':
        return AppColors.success;
      case 'Completed':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.service,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'for ${job.client}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: job.status, color: _statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.detail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: _Meta(
                      icon: Icons.location_on_outlined,
                      text: '${job.location} • ${job.distance}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: _Meta(icon: Icons.schedule, text: job.time),
                  ),
                  const Spacer(),
                  Text(
                    job.earnings,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}