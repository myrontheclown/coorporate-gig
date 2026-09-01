import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final topWorkers = MockData.workersByRating.take(4).toList();
    final filtered = _selectedService == 'All'
        ? MockData.workers
        : MockData.workersByService(_selectedService);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coorporate Gig', style: TextStyle(fontSize: 18)),
            Text(
              'Good morning, Priya 👋',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Nav.push(context, const NotificationListScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => Nav.push(context, const SearchResultsScreen()),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textMuted),
                      SizedBox(width: 10),
                      Text(
                        'Search workers or services...',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Popular Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Nav.push(
                      context,
                      const SearchResultsScreen(),
                    ),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: MockData.services.length,
                itemBuilder: (context, i) {
                  final s = MockData.services[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _ServicePill(
                      service: s,
                      selected: _selectedService == s.name,
                      onTap: () => setState(() => _selectedService = s.name),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Top Rated Workers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ...topWorkers.map(
              (w) => WorkerCard(
                worker: w,
                onTap: () {
                  AppState.activeWorker = w;
                  Nav.push(context, WorkerProfileScreen(worker: w));
                },
              ),
            ),
            if (_selectedService != 'All') ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'More Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...filtered.map(
                (w) => WorkerCard(
                  worker: w,
                  onTap: () {
                    AppState.activeWorker = w;
                    Nav.push(context, WorkerProfileScreen(worker: w));
                  },
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _PromoBanner(
                  onTap: () => Nav.push(context, const SearchResultsScreen()),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  final dynamic service;
  final bool selected;
  final VoidCallback onTap;

  const _ServicePill({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconFor(service.icon),
              color: selected ? Colors.white : const Color(0xFF6B7280),
              size: 26,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
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

class _PromoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PromoBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_user, color: Colors.white, size: 40),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verified Professionals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'All workers background-verified by cooperatives',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
