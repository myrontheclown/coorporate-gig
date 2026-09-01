import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../screens/admin/admin_home_shell.dart';
import '../screens/client/client_home_shell.dart';
import '../screens/worker/worker_home_shell.dart';
import '../services/auth_service.dart';
import '../services/worker_profile_service.dart';

class Nav {
  static void push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pop(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }

  static void clearAll(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  static void toClient(BuildContext context) {
    AppState.reset();
    AppState.currentRole.value = 'customer';
    _loadProfileIfAvailable('customer');
    clearAll(context, const ClientHomeShell());
  }

  static void toWorker(BuildContext context) {
    AppState.reset();
    AppState.currentRole.value = 'worker';
    _loadProfileIfAvailable('worker');
    clearAll(context, const WorkerHomeShell());
  }

  static void toAdmin(BuildContext context) {
    AppState.reset();
    AppState.currentRole.value = 'cooperative_admin';
    _loadProfileIfAvailable('cooperative_admin');
    clearAll(context, const AdminHomeShell());
  }

  static void _loadProfileIfAvailable(String role) async {
    final uid = AuthService.currentUserId;
    if (uid != null && uid.isNotEmpty) {
      final profile = await AuthService.fetchCurrentUserProfile();
      if (profile != null) {
        AppState.currentUserProfile.value = profile;
        if (role == 'worker') {
          final worker = await WorkerProfileService.getWorkerByUserId(uid);
          if (worker != null) {
            AppState.currentWorkerProfile.value = worker;
          }
        }
      }
    }
  }
}
