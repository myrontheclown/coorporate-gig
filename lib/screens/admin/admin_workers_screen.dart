import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
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

  final List<Map<String, dynamic>> _workers = [
    {'name': 'Ramesh Kumar', 'prof': 'Plumber', 'loc': 'Grant Road', 'rating': '4.8', 'jobs': 48, 'status': 'On Duty', 'initials': 'RK', 'color': Color(0xFF0284C7)},
    {'name': 'Sunita Devi', 'prof': 'Housekeeping', 'loc': 'Andheri', 'rating': '4.9', 'jobs': 76, 'status': 'On Duty', 'initials': 'SD', 'color': Color(0xFF16A34A)},
    {'name': 'Arjun Verma', 'prof': 'Electrician', 'loc': 'Dadar', 'rating': '4.7', 'jobs': 51, 'status': 'Available', 'initials': 'AV', 'color': Color(0xFFF59E0B)},
    {'name': 'Mohammed Ali', 'prof': 'Carpenter', 'loc': 'Kurla', 'rating': '4.6', 'jobs': 39, 'status': 'Available', 'initials': 'MA', 'color': Color(0xFF8B5E3C)},
    {'name': 'Meera Nair', 'prof': 'Painter', 'loc': 'Bandra', 'rating': '4.5', 'jobs': 27, 'status': 'Off Duty', 'initials': 'MN', 'color': Color(0xFF7C3AED)},
    {'name': 'Suresh Yadav', 'prof': 'AC Repair', 'loc': 'Powai', 'rating': '4.7', 'jobs': 32, 'status': 'On Duty', 'initials': 'SY', 'color': Color(0xFF0EA5E9)},
  ];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _workers.where((w) {
      final matchQuery = _query.text.isEmpty ||
          w['name']!.toLowerCase().contains(_query.text.toLowerCase());
      final matchFilter = _filter == 'All' || w['status'] == _filter;
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
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'On Duty', 'Available', 'Off Duty']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: _filter == f,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _filter == f
                                ? Colors.white
                                : AppColors.textSecondary,
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
                  '${list.length} workers',
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
              itemCount: list.length,
              itemBuilder: (context, i) {
                final w = list[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => Nav.push(
                      context,
                      AdminWorkerDetailScreen(
                        name: w['name']!,
                        prof: w['prof']!,
                        initials: w['initials']!,
                        color: w['color'] as Color,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    leading: CircleAvatarImage(
                      initials: w['initials']!,
                      color: w['color'] as Color,
                      size: 44,
                    ),
                    title: Text(
                      w['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${w['prof']} • ${w['loc']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(' ${w['rating']}'),
                          ],
                        ),
                        const SizedBox(height: 2),
                        StatusBadge(
                          label: w['status']!,
                          color: w['status'] == 'On Duty'
                              ? Colors.green
                              : w['status'] == 'Available'
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ],
                    ),
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
