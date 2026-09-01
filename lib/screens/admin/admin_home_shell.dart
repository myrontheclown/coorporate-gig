import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav.dart';
import 'admin_dashboard_screen.dart';
import 'admin_operations_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_workers_screen.dart';

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
    const AdminOperationsScreen(),
    const AdminProfileScreen(),
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
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: 'Workers',
          ),
          AppBottomNavItem(
            icon: Icons.handyman_outlined,
            activeIcon: Icons.handyman,
            label: 'Operations',
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