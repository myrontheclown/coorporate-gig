import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import 'admin_worker_detail_screen.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  String _filter = 'All';
  final _query = TextEditingController();

  // Simulated availability override for deactivate/activate action.
  final Map<String, bool> _active = {};

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workers = MockData.workers.where((w) {
      final matchQuery = _query.text.isEmpty ||
          w.name.toLowerCase().contains(_query.text.toLowerCase());
      final effectiveActive = _active[w.id] ?? w.available;
      final matchFilter = _filter == 'All' ||
          (_filter == 'Active' && effectiveActive) ||
          (_filter == 'Inactive' && !effectiveActive);
      return matchQuery && matchFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search workers...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Active', 'Inactive']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: _filter == f,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color:
                                _filter == f ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  '${workers.length} workers',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Worker'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: workers.length,
              itemBuilder: (context, i) {
                final w = workers[i];
                return _AdminWorkerCard(
                  worker: w,
                  active: _active[w.id] ?? w.available,
                  onToggle: () {
                    setState(() => _active[w.id] = !(_active[w.id] ?? w.available));
                  },
                  onView: () => Nav.push(
                    context,
                    AdminWorkerDetailScreen(worker: w),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminWorkerCard extends StatelessWidget {
  final Worker worker;
  final bool active;
  final VoidCallback onToggle;
  final VoidCallback onView;
  const _AdminWorkerCard({
    required this.worker,
    required this.active,
    required this.onToggle,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatarImage(
                  initials: worker.avatarInitials,
                  color: worker.color,
                  size: 48,
                  online: active,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              worker.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (worker.verified)
                            const Icon(
                              Icons.verified,
                              color: AppColors.success,
                              size: 16,
                            ),
                        ],
                      ),
                      Text(
                        worker.profession,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.rating, size: 14),
                          Text(
                            ' ${worker.ratingLabel}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${worker.jobsCompleted} jobs',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: active,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: worker.skills.take(3).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              worker.cooperative.isEmpty ? 'No cooperative' : worker.cooperative,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.cooperative,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onView,
                    child: const Text('View'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onToggle,
                    child: Text(active ? 'Deactivate' : 'Activate'),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: ElevatedButton(onPressed: null, child: Text('Assign')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}