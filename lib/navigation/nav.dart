import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../screens/admin/admin_home_shell.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/client/client_home_shell.dart';
import '../screens/worker/worker_home_shell.dart';
import '../screens/role_selection/role_selection_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
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

  /// Navigate to the appropriate sign-in screen for a role.
  static void toSignIn(BuildContext context, String role) {
    final screen = _signInForRole(role);
    push(context, screen);
  }

  /// Navigate to the appropriate dashboard after successful authentication.
  static void navigateAfterAuth(BuildContext context, String role) {
    switch (role) {
      case 'customer':
        toClient(context);
        break;
      case 'worker':
        toWorker(context);
        break;
      case 'cooperative_admin':
        toAdmin(context);
        break;
      default:
        toClient(context);
    }
  }

  /// Go to role selection (sign out destination).
  static void toRoleSelection(BuildContext context) {
    clearAll(context, const RoleSelectionScreen());
  }

  static void toClient(BuildContext context) {
    AppState.resetWorkflowState();
    AppState.currentRole.value = 'customer';
    _loadProfileIfAvailable('customer');
    clearAll(context, const ClientHomeShell());
  }

  static void toWorker(BuildContext context) {
    AppState.resetWorkflowState();
    AppState.currentRole.value = 'worker';
    _loadProfileIfAvailable('worker');
    clearAll(context, const WorkerHomeShell());
  }

  static void toAdmin(BuildContext context) {
    AppState.resetWorkflowState();
    AppState.currentRole.value = 'cooperative_admin';
    _loadProfileIfAvailable('cooperative_admin');
    clearAll(context, const AdminHomeShell());
  }

  static Widget _signInForRole(String role) {
    switch (role) {
      case 'customer':
        return const SignInScreen(
          role: 'customer',
          title: 'Welcome back',
          subtitle: 'Sign in to continue booking trusted services.',
          roleIndicator: 'Signing in as Client',
          roleIcon: Icons.person_outline,
          roleColor: AppColors.primary,
        );
      case 'worker':
        return const SignInScreen(
          role: 'worker',
          title: 'Welcome back, Worker',
          subtitle: 'Sign in to manage your jobs and earnings.',
          roleIndicator: 'Signing in as Worker',
          roleIcon: Icons.engineering_outlined,
          roleColor: AppColors.cooperative,
        );
      case 'cooperative_admin':
        return const SignInScreen(
          role: 'cooperative_admin',
          title: 'Cooperative Admin',
          subtitle: 'Sign in to manage your cooperative workforce.',
          roleIndicator: 'Signing in as Cooperative Admin',
          roleIcon: Icons.account_balance_outlined,
          roleColor: AppColors.warning,
        );
      default:
        return _signInForRole('customer');
    }
  }

  static void _loadProfileIfAvailable(String role) async {
    final uid = AuthService.currentUserId;
    if (uid != null && uid.isNotEmpty) {
      // If profile is not already populated or doesn't match the current user, fetch it
      if (AppState.currentUserProfile.value == null ||
          AppState.currentUserProfile.value!.id != uid) {
        final profile = await AuthService.fetchCurrentUserProfile();
        if (profile != null) {
          AppState.currentUserProfile.value = profile;
          // Always use the role stored in user_profile as source of truth
          AppState.currentRole.value = profile.role;
        }
      }

      // If worker and worker profile not yet in AppState, load it
      if (AppState.currentRole.value == 'worker' &&
          AppState.currentWorkerProfile.value == null) {
        final worker = await WorkerProfileService.getWorkerByUserId(uid);
        if (worker != null) {
          AppState.currentWorkerProfile.value = worker;
        }
      }
    }
  }
}
