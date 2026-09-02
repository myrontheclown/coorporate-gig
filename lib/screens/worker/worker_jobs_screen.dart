import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';
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

  List<Job> _supabaseJobs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final workerId = AppState.currentWorkerProfile.value?.id ?? '';
    if (workerId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.getJobsForWorker(workerId);
      if (jobs.isNotEmpty && mounted) {
        setState(() => _supabaseJobs = jobs);
      }
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final _mockNew = [
    const _Job(
      client: 'Mrs. Priya',
      service: 'Plumbing',
      location: 'Grant Road',
      time: 'Today, 3:00 PM',
      distance: '1.2 km',
      earnings: '₹1,050',
      status: 'New',
      detail: 'Fix leaking kitchen sink & replace pipes',
    ),
    const _Job(
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

  final _mockUpcoming = [
    const _Job(
      client: 'Ms. Priya',
      service: 'Plumbing',
      location: 'Grant Road',
      time: 'Tomorrow, 10:00 AM',
      distance: '1.0 km',
      earnings: '₹1,050',
      status: 'Confirmed',
      detail: 'Kitchen plumbing work',
    ),
    const _Job(
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

  final _mockActive = [
    const _Job(
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

  final _mockCompleted = [
    const _Job(
      client: 'Sharma family',
      service: 'Plumbing',
      location: 'Dadar',
      time: '29 Aug',
      distance: '2.8 km',
      earnings: '₹900',
      status: 'Completed',
      detail: 'Pipe replacement',
    ),
    const _Job(
      client: 'Verma S.',
      service: 'Plumbing',
      location: 'Andheri',
      time: '25 Aug',
      distance: '3.1 km',
      earnings: '₹750',
      status: 'Completed',
      detail: 'Sink repair',
    ),
    const _Job(
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

  _Job _convertJob(Job j) {
    final clientName = j.customerProfile?.fullName.isNotEmpty == true
        ? j.customerProfile!.fullName
        : 'Customer';
    final location = j.customerProfile?.city.isNotEmpty == true
        ? j.customerProfile!.city
        : 'Grant Road';
    final date = j.scheduledAt ?? j.createdAt ?? DateTime.now();

    String statusLabel = 'New';
    if (j.status == 'in_progress') statusLabel = 'In Progress';
    if (j.status == 'accepted') statusLabel = 'Confirmed';
    if (j.status == 'completed') statusLabel = 'Completed';

    return _Job(
      id: j.id,
      client: clientName,
      service: j.jobTitle.isNotEmpty ? j.jobTitle : 'Services',
      location: location,
      time: '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
      distance: '1.5 km',
      earnings: '₹${j.amount.toInt()}',
      status: statusLabel,
      detail: j.description,
    );
  }

  List<_Job> get _current {
    if (_supabaseJobs.isNotEmpty) {
      final converted = _supabaseJobs.map(_convertJob).toList();
      switch (_tab) {
        case 0:
          return converted.where((j) => j.status == 'New' || j.status == 'pending').toList();
        case 1:
          return converted.where((j) => j.status == 'Confirmed' || j.status == 'Upcoming').toList();
        case 2:
          return converted.where((j) => j.status == 'In Progress').toList();
        case 3:
          return converted.where((j) => j.status == 'Completed').toList();
        default:
          return converted;
      }
    }

    switch (_tab) {
      case 0:
        return _mockNew;
      case 1:
        return _mockUpcoming;
      case 2:
        return _mockActive;
      case 3:
        return _mockCompleted;
      default:
        return _mockNew;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _current;

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
                separatorBuilder: (_, _) => const SizedBox(width: 8),
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
            child: _isLoading && currentList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : currentList.isEmpty
                    ? const Center(
                        child: Text(
                          'No jobs in this category',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: currentList.length,
                        itemBuilder: (context, i) {
                          return _JobCard(
                            job: currentList[i],
                            onTap: () {
                              if (currentList[i].status == 'In Progress') {
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
    if (_supabaseJobs.isNotEmpty) {
      final converted = _supabaseJobs.map(_convertJob).toList();
      switch (tab) {
        case 0:
          return converted.where((j) => j.status == 'New' || j.status == 'pending').length;
        case 1:
          return converted.where((j) => j.status == 'Confirmed' || j.status == 'Upcoming').length;
        case 2:
          return converted.where((j) => j.status == 'In Progress').length;
        case 3:
          return converted.where((j) => j.status == 'Completed').length;
        default:
          return 0;
      }
    }

    switch (tab) {
      case 0:
        return _mockNew.length;
      case 1:
        return _mockUpcoming.length;
      case 2:
        return _mockActive.length;
      case 3:
        return _mockCompleted.length;
      default:
        return 0;
    }
  }
}

class _Job {
  final String? id;
  final String client;
  final String service;
  final String location;
  final String time;
  final String distance;
  final String earnings;
  final String status;
  final String detail;

  const _Job({
    this.id,
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