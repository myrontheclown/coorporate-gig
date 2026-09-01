import 'package:flutter/material.dart';
import 'screens/role_selection/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CoorporateGigApp());
}

class CoorporateGigApp extends StatelessWidget {
  const CoorporateGigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coorporate Gig',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RoleSelectionScreen(),
    );
  }
}
