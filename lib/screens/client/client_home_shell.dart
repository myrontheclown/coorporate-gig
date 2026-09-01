import 'package:flutter/material.dart';
import 'bookings_history_screen.dart';
import 'client_profile_screen.dart';
import 'my_requests_screen.dart';
import 'notification_screen.dart';
import 'worker_discovery_screen.dart';

class ClientHomeShell extends StatefulWidget {
  const ClientHomeShell({super.key});

  @override
  State<ClientHomeShell> createState() => _ClientHomeShellState();
}

class _ClientHomeShellState extends State<ClientHomeShell> {
  int _index = 0;

  final _screens = [
    const WorkerDiscoveryScreen(),
    const MyRequestsScreen(),
    const BookingsHistoryScreen(),
    const NotificationListScreen(),
    const ClientProfileScreen(),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
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
