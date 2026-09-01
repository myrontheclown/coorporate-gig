import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/service.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/service_chip.dart';
import '../../widgets/worker_card.dart';
import 'worker_profile_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchResultsScreen({super.key, this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _controller;
  String _query = '';
  String _selectedService = 'All';
  String _sort = 'Relevance';
  bool _showRecent = true;

  static const List<String> _sorts = [
    'Relevance',
    'Rating',
    'Price',
    'Distance',
  ];

  List<Worker> _supabaseWorkers = [];
  final List<String> _recentSearches = ['Plumber', 'AC repair', 'Housekeeping'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _query = widget.initialQuery ?? '';
    if (_query.isNotEmpty) _showRecent = false;
    _fetchWorkers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkers() async {
    try {
      final list = await WorkerProfileService.getWorkers();
      if (list.isNotEmpty && mounted) {
        setState(() {
          _supabaseWorkers = list.map((w) => w.toWorker()).toList();
        });
      }
    } catch (_) {}
  }

  List<Worker> get _base {
    return _supabaseWorkers.isNotEmpty
        ? [..._supabaseWorkers]
        : [...MockData.workers];
  }

  List<Worker> get _results {
    var list = _base;

    // Category filter — match by profession or related skill/service name
    if (_selectedService != 'All') {
      final serviceName = _selectedService;
      list = list
          .where((w) =>
              w.profession.toLowerCase().contains(serviceName.toLowerCase()) ||
              w.skills.any((s) =>
                  s.toLowerCase().contains(serviceName.toLowerCase())) ||
              serviceName.toLowerCase().contains(w.profession.toLowerCase()))
          .toList();
    }

    // Text query — match name, profession, or skills
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((w) =>
              w.name.toLowerCase().contains(q) ||
              w.profession.toLowerCase().contains(q) ||
              w.skills.any((s) => s.toLowerCase().contains(q)) ||
              w.location.toLowerCase().contains(q))
          .toList();
    }

    switch (_sort) {
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price':
        list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'Distance':
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      default:
        break;
    }
    return list;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim();
      _showRecent = value.trim().isEmpty && _selectedService == 'All';
    });
  }

  void _submitSearch(String query) {
    setState(() {
      _controller.text = query;
      _query = query;
      _showRecent = false;
      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _controller.clear();
      _query = '';
      _selectedService = 'All';
      _showRecent = true;
    });
  }

  IconData _iconForService(String icon) {
    switch (icon) {
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

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              onChanged: _onSearchChanged,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: 'Search plumber, electrician, chef...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: MockData.services.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ServiceChip(
                    label: 'All',
                    selected: _selectedService == 'All',
                    onTap: () => setState(() {
                      _selectedService = 'All';
                      _showRecent = _query.isEmpty;
                    }),
                  );
                }
                final s = MockData.services[i - 1];
                return ServiceChip(
                  label: s.name,
                  icon: _iconForService(s.icon),
                  selected: _selectedService == s.name,
                  onTap: () => setState(() {
                    _selectedService = s.name;
                    _showRecent = false;
                  }),
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sorts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _sorts[i];
                return _SortChip(
                  label: f,
                  selected: _sort == f,
                  onTap: () => setState(() => _sort = f),
                );
              },
            ),
          ),
          if (!_showRecent)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${results.length} worker${results.length == 1 ? '' : 's'} found',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'within ${_selectedService == 'All' ? 'your area' : _selectedService.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: _showRecent
                ? _buildRecentAndPopular(context)
                : results.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final w = results[i];
                          return WorkerCard(
                            worker: w,
                            onTap: () {
                              AppState.activeWorker = w;
                              Nav.push(
                                context,
                                WorkerProfileScreen(worker: w),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAndPopular(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        const Text(
          'Recent searches',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No recent searches yet',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((q) {
              return ActionChip(
                avatar: const Icon(Icons.history, size: 16, color: AppColors.textMuted),
                label: Text(q),
                onPressed: () => _submitSearch(q),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.divider),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
        const Text(
          'Popular services',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: MockData.services.take(6).map((Service s) {
            return _PopularCard(
              label: s.name,
              icon: _iconForService(s.icon),
              onTap: () => _submitSearch(s.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No workers found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another service or adjust your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _clearSearch,
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PopularCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
