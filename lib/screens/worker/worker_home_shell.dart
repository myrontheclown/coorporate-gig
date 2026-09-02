import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav.dart';
import 'worker_dashboard_screen.dart';
import 'worker_jobs_screen.dart';
import 'worker_profile_screen.dart';

class WorkerHomeShell extends StatefulWidget {
  const WorkerHomeShell({super.key});

  @override
  State<WorkerHomeShell> createState() => _WorkerHomeShellState();
}

class _WorkerHomeShellState extends State<WorkerHomeShell> {
  int _index = 0;

  final _screens = [
    const WorkerDashboardScreen(),
    const WorkerJobsScreen(),
    const WorkerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          AppBottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          AppBottomNavItem(
            icon: Icons.work_outline,
            activeIcon: Icons.work,
            label: 'Jobs',
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}