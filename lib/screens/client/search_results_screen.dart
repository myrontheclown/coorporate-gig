import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../data/app_state.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/worker_card.dart';
import 'worker_profile_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _query = '';
  String _filter = 'Relevance';
  List<String> _filters = ['Relevance', 'Rating', 'Price', 'Distance'];

  List<Worker> get _results {
    var list = [...MockData.workers];
    if (_query.isNotEmpty) {
      list = MockData.workers
          .where((w) =>
              w.name.toLowerCase().contains(_query.toLowerCase()) ||
              w.profession.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    switch (_filter) {
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price':
        list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'Distance':
        break;
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search plumber, electrician, chef...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.tune),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                return ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _filter == f ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _filter = f),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Text(
                  '${results.length} workers found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text(
                  '2.4 km radius',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
                SizedBox(width: 6),
                Text(
                  'View Map',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  ' • results shown on map',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final w = results[i];
                return WorkerCard(
                  worker: w,
                  onTap: () {
                    AppState.activeWorker = w;
                    Nav.push(context, WorkerProfileScreen(worker: w));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
