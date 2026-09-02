import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_models.dart';
import '../../data/user_data.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<UserRequest> _supabaseRequests = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    AppState.currentUserProfile.addListener(_onProfileChanged);
    _loadRequests();
  }

  @override
  void dispose() {
    AppState.currentUserProfile.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      _loadRequests();
    }
  }

  Future<void> _loadRequests() async {
    final isAuthenticated =
        SupabaseService.isReady && AuthService.currentUser != null;

    if (!isAuthenticated) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
          _supabaseRequests = UserData.requests;
        });
      }
      return;
    }

    final customerId = AuthService.currentUser!.id;

    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.getJobsForCustomer(customerId);
      if (mounted) {
        setState(() {
          _hasFetched = true;
          _supabaseRequests = jobs.map((j) => j.toUserRequest()).toList();
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

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        SupabaseService.isReady && AuthService.currentUser != null;
    final requests = isAuthenticated
        ? _supabaseRequests
        : (_supabaseRequests.isNotEmpty
            ? _supabaseRequests
            : UserData.requests);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading && !_hasFetched
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: requests.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 56,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No service requests yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Requests you post will appear here.',
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
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, i) {
                        final r = requests[i];
                        return _RequestCard(request: r);
                      },
                    ),
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
                      onPressed: () => _showMatchedWorker(context, request),
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

  void _showMatchedWorker(BuildContext context, UserRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Matched Worker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  request.service,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.workerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Matched to your request',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.notes, label: 'Request', value: request.service),
                _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date', value: request.date),
                _InfoRow(icon: Icons.description_outlined, label: 'Description', value: request.description),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    late Color color;
    late IconData icon;
    switch (status) {
      case 'In Progress':
        color = AppColors.primary;
        icon = Icons.build;
        break;
      case 'Completed':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'Matched':
        color = AppColors.primary;
        icon = Icons.handshake;
        break;
      default:
        color = AppColors.warning;
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
