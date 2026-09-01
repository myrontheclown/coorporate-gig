import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../screens/role_selection/role_selection_screen.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';

/// Shown on app startup. Checks whether a valid Supabase session exists
/// and restores the appropriate experience, or falls through to role selection.
class SessionRestoreScreen extends StatefulWidget {
  const SessionRestoreScreen({super.key});

  @override
  State<SessionRestoreScreen> createState() => _SessionRestoreScreenState();
}

class _SessionRestoreScreenState extends State<SessionRestoreScreen> {
  @override
  void initState() {
    super.initState();
    // Defer until after the first frame so Navigator is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    // No Supabase — go straight to role selection (mock mode)
    if (!SupabaseService.isReady) {
      _goToRoleSelection();
      return;
    }

    final session = SupabaseService.client?.auth.currentSession;
    if (session == null) {
      _goToRoleSelection();
      return;
    }

    // Session exists — load user profile and navigate to the right experience
    try {
      final profile = await AuthService.fetchCurrentUserProfile();
      if (!mounted) return;

      if (profile == null) {
        // Auth user exists but no profile row — log them out cleanly
        await AuthService.signOut();
        _goToRoleSelection();
        return;
      }

      AppState.currentUserProfile.value = profile;
      AppState.currentRole.value = profile.role;

      if (profile.role == 'worker') {
        final workerProfile =
            await WorkerProfileService.getWorkerByUserId(profile.id);
        if (!mounted) return;
        if (workerProfile != null) {
          AppState.currentWorkerProfile.value = workerProfile;
        }
      }

      if (!mounted) return;
      Nav.navigateAfterAuth(context, profile.role);
    } catch (_) {
      if (!mounted) return;
      _goToRoleSelection();
    }
  }

  void _goToRoleSelection() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
