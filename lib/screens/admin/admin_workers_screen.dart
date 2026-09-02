import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';
import 'admin_worker_detail_screen.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  String _filter = 'All';
  final _query = TextEditingController();
  final Map<String, bool> _active = {};
  List<Worker> _supabaseWorkers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    try {
      final list = await WorkerProfileService.getWorkers();
      if (list.isNotEmpty && mounted) {
        setState(() {
          _supabaseWorkers = list.map((w) {
            final workerUi = w.toWorker();
            _active[workerUi.id] = workerUi.available;
            return workerUi;
          }).toList();
        });
      }
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddWorker() {
    final nameController = TextEditingController();
    final skillController = TextEditingController();
    final rateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Worker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Records the worker in your cooperative roster.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter worker name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: skillController,
                  decoration: const InputDecoration(
                    labelText: 'Profession / skill',
                    hintText: 'e.g. Plumber',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a profession' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Rate per hour (₹)',
                  ),
                  validator: (v) {
                    final value = int.tryParse(v ?? '');
                    return (value == null || value <= 0)
                        ? 'Enter a valid hourly rate'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      final name = nameController.text.trim();
                      final skill = skillController.text.trim();
                      final rate = int.parse(rateController.text.trim());
                      final worker = Worker(
                        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        profession: skill,
                        location: 'Your cooperative area',
                        locality: 'Local',
                        rating: 5.0,
                        reviews: 0,
                        distanceKm: 1.0,
                        pricePerHour: rate.toDouble(),
                        avatarInitials: name.split(' ').map((p) => p[0]).take(2).join().toUpperCase(),
                        color: AppColors.primary,
                        skills: [skill],
                        experience: 'Newly onboarded',
                        description: 'Added by cooperative admin.',
                        available: true,
                      );
                      Navigator.pop(ctx);
                      setState(() {
                        _supabaseWorkers.insert(0, worker);
                        _active[worker.id] = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added $name to the roster.')),
                      );
                    },
                    child: const Text('Add to Roster'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = _supabaseWorkers.isNotEmpty ? _supabaseWorkers : MockData.workers;

    final workers = all.where((w) {
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
                  onPressed: () => _showAddWorker(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Worker'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && workers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: workers.length,
                    itemBuilder: (context, i) {
                      final w = workers[i];
                      final currentAct = _active[w.id] ?? w.available;
                      return _AdminWorkerCard(
                        worker: w,
                        active: currentAct,
                        onToggle: () async {
                          final newVal = !currentAct;
                          setState(() => _active[w.id] = newVal);
                          if (w.id.length == 36) {
                            await WorkerProfileService.updateAvailability(
                              w.id,
                              newVal ? 'available' : 'off_duty',
                            );
                          }
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
                          const SizedBox(width: 8),
                          // On-duty / off-duty indicator — display only, no filter
                          StatusBadge(
                            label: worker.isOnDuty ? 'On Duty' : 'Off Duty',
                            color: worker.isOnDuty
                                ? AppColors.dutyOn
                                : AppColors.dutyOff,
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