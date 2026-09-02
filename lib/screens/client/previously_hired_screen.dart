import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_models.dart';
import '../../models/worker.dart';
import '../../models/worker_profile.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/supabase_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/worker_card.dart';
import 'worker_profile_screen.dart';

class PreviouslyHiredScreen extends StatefulWidget {
  const PreviouslyHiredScreen({super.key});

  @override
  State<PreviouslyHiredScreen> createState() => _PreviouslyHiredScreenState();
}

class _PreviouslyHiredScreenState extends State<PreviouslyHiredScreen> {
  List<_PreviouslyHiredItem> _items = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    AppState.currentUserProfile.addListener(_onProfileChanged);
    _loadPreviouslyHired();
  }

  @override
  void dispose() {
    AppState.currentUserProfile.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      _loadPreviouslyHired();
    }
  }

  Future<void> _loadPreviouslyHired() async {
    final isAuthenticated =
        SupabaseService.isReady && AuthService.currentUser != null;

    if (!isAuthenticated) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
          _items = _getMockItems();
        });
      }
      return;
    }

    final customerId = AuthService.currentUser!.id;

    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.getJobsForCustomer(customerId);
      final Map<String, _PreviouslyHiredItem> workerMap = {};
      final Map<String, WorkerProfile?> workerProfileCache = {};

      for (final job in jobs) {
        if (job.status.toLowerCase() == 'completed' &&
            job.workerId != null &&
            job.workerId!.isNotEmpty) {
          final workerId = job.workerId!;
          WorkerProfile? wp = job.workerProfile ?? workerProfileCache[workerId];

          if (wp == null && !workerProfileCache.containsKey(workerId)) {
            try {
              wp = await WorkerProfileService.getWorkerById(workerId);
              workerProfileCache[workerId] = wp;
            } catch (_) {
              workerProfileCache[workerId] = null;
            }
          } else if (wp != null && !workerProfileCache.containsKey(workerId)) {
            workerProfileCache[workerId] = wp;
          }

          if (wp == null) {
            // If the worker profile cannot be resolved, skip only that worker
            continue;
          }

          final worker = wp.toWorker(fallbackProfession: job.jobTitle);
          if (!workerMap.containsKey(worker.id)) {
            workerMap[worker.id] = _PreviouslyHiredItem(
              worker: worker,
              hiredDate: job.completedAt ??
                  job.scheduledAt ??
                  job.createdAt ??
                  DateTime.now(),
              profession:
                  job.jobTitle.isNotEmpty ? job.jobTitle : worker.profession,
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _hasFetched = true;
          _items = workerMap.values.toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_PreviouslyHiredItem> _getMockItems() {
    return MockModels.previouslyHiredWorkers.map((w) {
      final booked = MockModels.completedBookings
          .where((b) => b.workerName == w.name)
          .toList();
      final date = booked.isNotEmpty ? booked.first.date : DateTime.now();
      final prof = booked.isNotEmpty ? booked.first.profession : w.profession;
      return _PreviouslyHiredItem(
        worker: w,
        hiredDate: date,
        profession: prof,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previously Hired Workers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadPreviouslyHired,
          ),
        ],
      ),
      body: _isLoading && !_hasFetched
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPreviouslyHired,
              child: _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 56,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No previously hired workers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Workers you hire will appear here for easy rebooking.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return Column(
                          children: [
                            WorkerCard(
                              worker: item.worker,
                              onTap: () {
                                AppState.activeWorker = item.worker;
                                Nav.push(
                                  context,
                                  WorkerProfileScreen(worker: item.worker),
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Hired on ${item.hiredDate.day} '
                                '${_month(item.hiredDate.month)} '
                                '${item.hiredDate.year} • ${item.profession}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
            ),
    );
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }
}

class _PreviouslyHiredItem {
  final Worker worker;
  final DateTime hiredDate;
  final String profession;

  const _PreviouslyHiredItem({
    required this.worker,
    required this.hiredDate,
    required this.profession,
  });
}
