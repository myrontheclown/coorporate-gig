import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_workers_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_ai_dashboard_screen.dart';
import 'admin_federation_screen.dart';

class AdminHomeShell extends StatefulWidget {
  const AdminHomeShell({super.key});

  @override
  State<AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends State<AdminHomeShell> {
  int _index = 0;

  final _screens = [
    const AdminDashboardScreen(),
    const AdminWorkersScreen(),
    const AdminJobsScreen(),
    const AdminAiDashboardScreen(),
    const AdminFederationScreen(),
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
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Workers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'Federation',
          ),
        ],
      ),
    );
  }
}
