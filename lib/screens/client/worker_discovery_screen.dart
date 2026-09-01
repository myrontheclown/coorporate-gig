import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
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

  @override
  Widget build(BuildContext context) {
    final nearby = MockData.workersByRating.take(6).toList();

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
            const Text(
              'Good evening, Rahul',
              style: TextStyle(
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
                separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                const Text(
                  'Grant Road, Mumbai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
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