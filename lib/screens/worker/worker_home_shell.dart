import 'package:flutter/material.dart';
import 'worker_dashboard_screen.dart';
import 'worker_job_requests_screen.dart';
import 'worker_jobs_screen.dart';
import 'worker_earnings_screen.dart';
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
    const WorkerJobRequestsScreen(),
    const WorkerJobsScreen(),
    const WorkerEarningsScreen(),
    const WorkerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
