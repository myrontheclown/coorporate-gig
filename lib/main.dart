import 'package:flutter/material.dart';
import 'screens/auth/session_restore_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
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
      home: const SessionRestoreScreen(),
    );
  }
}
