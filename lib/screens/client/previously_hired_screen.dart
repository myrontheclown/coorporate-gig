import 'package:flutter/material.dart';
import '../../data/mock_models.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/worker_card.dart';
import 'worker_profile_screen.dart';

class PreviouslyHiredScreen extends StatelessWidget {
  const PreviouslyHiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workers = MockModels.previouslyHiredWorkers;
    return Scaffold(
      appBar: AppBar(title: const Text('Previously Hired Workers')),
      body: workers.isEmpty
          ? const Center(
              child: Text(
                'No previously hired workers',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: workers.map((w) {
                final booked =
                    MockModels.completedBookings
                        .where((b) => b.workerName == w.name)
                        .toList();
                return Column(
                  children: [
                    WorkerCard(
                      worker: w,
                      onTap: () {
                        AppState.activeWorker = w;
                        Nav.push(context, WorkerProfileScreen(worker: w));
                      },
                    ),
                    if (booked.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Hired on '
                          '${booked.first.date.day} ${_month(booked.first.date.month)} '
                          '${booked.first.date.year} • ${booked.first.profession}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }
}
