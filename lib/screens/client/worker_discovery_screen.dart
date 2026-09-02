import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_chip.dart';
import '../../widgets/worker_card.dart';
import 'notification_screen.dart';
import 'search_results_screen.dart';
import 'worker_profile_screen.dart';

class WorkerDiscoveryScreen extends StatefulWidget {
  const WorkerDiscoveryScreen({super.key});

  @override
  State<WorkerDiscoveryScreen> createState() => _WorkerDiscoveryScreenState();
}

class _WorkerDiscoveryScreenState extends State<WorkerDiscoveryScreen> {
  String _selectedService = 'All';
  Worker? _selectedMapWorker;
  List<Worker> _supabaseWorkers = [];

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      // onDutyOnly: true — discovery only shows workers who are on duty
      final profiles = await WorkerProfileService.getWorkers(onDutyOnly: true);
      if (profiles.isNotEmpty && mounted) {
        setState(() {
          _supabaseWorkers = profiles.map((p) => p.toWorker()).toList();
        });
      }
    } catch (_) {
      // Fallback seamlessly
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock fallback: only on-duty workers surface in discovery
    final allWorkers = _supabaseWorkers.isNotEmpty
        ? _supabaseWorkers
        : MockData.onDutyWorkersByRating;

    final filtered = _selectedService == 'All'
        ? allWorkers
        : allWorkers
            .where((w) => w.profession
                .toLowerCase()
                .contains(_selectedService.toLowerCase()))
            .toList();

    final nearby = filtered.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            _HomeHeader(onNotifications: () {
              Nav.push(context, const NotificationListScreen());
            }),
            const SizedBox(height: 20),
            // Greeting
            ValueListenableBuilder(
              valueListenable: AppState.currentUserProfile,
              builder: (context, profile, _) {
                final name = profile?.fullName.isNotEmpty == true
                    ? profile!.fullName
                    : 'Rahul';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening, $name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find trusted professionals near you.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Search
            GigSearchBar(
              onTap: () => Nav.push(context, const SearchResultsScreen()),
              trailing: const Icon(
                Icons.tune,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            // Service chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MockData.services.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return ServiceChip(
                      label: 'All',
                      selected: _selectedService == 'All',
                      onTap: () => setState(() => _selectedService = 'All'),
                    );
                  }
                  final s = MockData.services[i - 1];
                  return ServiceChip(
                    label: s.name,
                    icon: _iconFor(s.icon),
                    selected: _selectedService == s.name,
                    onTap: () => setState(() => _selectedService = s.name),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Map section
            MapCard(
              workers: nearby,
              selectedWorker: _selectedMapWorker,
              onViewProfile: _selectedMapWorker == null
                  ? null
                  : () {
                      AppState.activeWorker = _selectedMapWorker;
                      Nav.push(
                        context,
                        WorkerProfileScreen(worker: _selectedMapWorker!),
                      );
                    },
            ),
            const SizedBox(height: 20),
            // Available near you
            SectionHeader(
              title: 'Available near you',
              actionLabel: 'See All',
              onAction: () => Nav.push(context, const SearchResultsScreen()),
            ),
            const SizedBox(height: 4),
            for (final w in nearby)
              WorkerCard(
                worker: w,
                onTap: () {
                  AppState.activeWorker = w;
                  Nav.push(context, WorkerProfileScreen(worker: w));
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'plumbing':
        return Icons.plumbing;
      case 'bolt':
        return Icons.bolt;
      case 'construction':
        return Icons.construction;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'format_paint':
        return Icons.format_paint;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'eco':
        return Icons.eco;
      case 'restaurant':
        return Icons.restaurant;
      case 'security':
        return Icons.security;
      default:
        return Icons.build;
    }
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onNotifications;
  const _HomeHeader({required this.onNotifications});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 2),
                ValueListenableBuilder(
                  valueListenable: AppState.currentUserProfile,
                  builder: (context, profile, _) {
                    final loc = profile?.city.isNotEmpty == true
                        ? '${profile!.address.isNotEmpty ? "${profile.address}, " : ""}${profile.city}'
                        : 'Grant Road, Mumbai';
                    return Text(
                      loc,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          icon: const Badge(
            label: Text('2'),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}