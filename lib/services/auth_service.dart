import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_state.dart';
import '../models/user_profile.dart';
import '../models/worker_profile.dart';
import 'mock_auth_service.dart';
import 'supabase_service.dart';
import 'user_profile_service.dart';
import 'worker_profile_service.dart';

class AuthService {
  /// Currently authenticated Supabase user.
  static User? get currentUser {
    return SupabaseService.client?.auth.currentUser;
  }

  /// ID of the currently authenticated Supabase user.
  /// Falls back to mock user ID when Supabase is not configured.
  static String? get currentUserId {
    final supabaseId = currentUser?.id;
    if (supabaseId != null && supabaseId.isNotEmpty) return supabaseId;
    return MockAuthService.currentUserId;
  }

  /// Stream of Supabase authentication state changes.
  static Stream<AuthState>? get authStateChanges {
    return SupabaseService.client?.auth.onAuthStateChange;
  }

  /// Whether mock mode is active (Supabase not configured).
  static bool get isMockMode => !SupabaseService.isReady;

  /// Fetches the UserProfile corresponding to the authenticated user.
  static Future<UserProfile?> fetchCurrentUserProfile() async {
    if (isMockMode) {
      return MockAuthService.currentProfile;
    }
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return null;
    return await UserProfileService.getProfile(uid);
  }

  /// Authenticates using email and password.
  /// Uses Supabase when configured, falls back to mock auth.
  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (!SupabaseService.isReady) {
      if (kDebugMode) {
        print('[AuthService.signIn] Supabase is not configured.');
      }
      return null;
    }

    try {
      final response = await SupabaseService.client!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e, stack) {
      if (kDebugMode) {
        print('[AuthService.signIn] Error: $e\n$stack');
      }
      rethrow;
    }
  }

  /// Sign in with mock or Supabase auth, returning a structured result.
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    if (!SupabaseService.isReady) {
      return _mockSignIn(email, password, role);
    }

    try {
      final response = await signIn(email: email, password: password);
      final user = response?.user ?? currentUser;
      if (user != null) {
        final profile = await UserProfileService.getProfile(user.id);
        if (profile == null) {
          if (kDebugMode) {
            print(
              '⚠️ [AuthService.signInWithEmailAndPassword] User ${user.id} has no public.user_profile record.',
            );
          }
          return const AuthResult(
            success: false,
            error: 'User profile not found. Please contact support.',
          );
        }

        // Use the role stored in public.user_profile as the source of truth.
        final resolvedRole =
            profile.role.isNotEmpty ? profile.role : role;

        // Load worker profile into AppState if worker
        if (resolvedRole == 'worker') {
          final workerProfile =
              await WorkerProfileService.getWorkerByUserId(user.id);
          if (workerProfile != null) {
            AppState.currentWorkerProfile.value = workerProfile;
          }
        }

        return AuthResult(
          success: true,
          userId: user.id,
          profile: profile,
          role: resolvedRole,
        );
      }
      return const AuthResult(success: false, error: 'Sign in failed.');
    } catch (e) {
      return AuthResult(
        success: false,
        error: _parseAuthError(e),
      );
    }
  }

  /// Registers a new user via Supabase Auth.
  /// The PostgreSQL trigger `handle_new_user()` creates public.user_profile.
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String role,
    String fullName = '',
    String phone = '',
    String address = '',
    String city = '',
    String state = '',
    String pincode = '',
    int experienceYears = 0,
    String? cooperativeId,
  }) async {
    if (!SupabaseService.isReady) {
      if (kDebugMode) {
        print('[AuthService.signUp] Supabase is not configured.');
      }
      return null;
    }

    try {
      final response = await SupabaseService.client!.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );

      final user = response.user;
      // Note: public.user_profile is automatically created by the PostgreSQL
      // trigger on auth.users INSERT with user.id == public.user_profile.id.
      // We do not execute a duplicate Flutter insert here.

      // If worker profile metadata is provided and a session is active,
      // create the worker_profile row if it doesn't already exist.
      if (user != null && response.session != null && role == 'worker') {
        final existingWorker =
            await WorkerProfileService.getWorkerByUserId(user.id);
        if (existingWorker == null) {
          final workerProfile = WorkerProfile(
            id: '',
            userId: user.id,
            cooperativeId: cooperativeId,
            experienceYears: experienceYears,
            address: address,
            city: city,
            state: state,
            pincode: pincode,
            verificationStatus: 'pending',
            availabilityStatus: 'available',
            createdAt: DateTime.now(),
          );
          final data = workerProfile.toJson();
          data.remove('id');
          await SupabaseService.client!.from('worker_profile').insert(data);
        }
      }

      return response;
    } catch (e, stack) {
      if (kDebugMode) {
        print('[AuthService.signUp] Error: $e\n$stack');
      }
      rethrow;
    }
  }

  /// Create account with mock or Supabase auth.
  static Future<AuthResult> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String phone = '',
    String extra = '',
  }) async {
    if (!SupabaseService.isReady) {
      return _mockSignUp(email, password, fullName, role, extra, phone: phone);
    }

    try {
      final response = await signUp(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        phone: phone,
      );

      if (response == null) {
        return const AuthResult(
          success: false,
          error: 'Account creation failed.',
        );
      }

      // Case A: Email confirmation required — user created in auth.users
      // but session is null until they verify their email.
      if (response.user != null && response.session == null) {
        return AuthResult(
          success: true,
          userId: response.user!.id,
          role: role,
          // Signal the UI that confirmation is pending
          error: 'email_confirmation_required',
        );
      }

      // Case B: Email confirmation disabled / auto-confirmed — session established.
      if (response.user != null) {
        // Retrieve the user_profile created by the database trigger
        final profile =
            await UserProfileService.getProfile(response.user!.id);
        final resolvedRole = profile?.role ?? role;
        return AuthResult(
          success: true,
          userId: response.user!.id,
          profile: profile,
          role: resolvedRole,
        );
      }
      return const AuthResult(
        success: false,
        error: 'Account creation failed.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: _parseAuthError(e),
      );
    }
  }

  /// Reset password with mock or Supabase auth.
  static Future<void> resetPassword({required String email}) async {
    if (!SupabaseService.isReady) {
      await MockAuthService.resetPassword(email);
      return;
    }

    try {
      await SupabaseService.client!.auth.resetPasswordForEmail(email.trim());
    } catch (e, stack) {
      if (kDebugMode) {
        print('[AuthService.resetPassword] Error: $e\n$stack');
      }
    }
  }

  /// Signs out of the current session and clears application auth state.
  static Future<void> signOut() async {
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client!.auth.signOut();
      } catch (e, stack) {
        if (kDebugMode) {
          print('[AuthService.signOut] Error: $e\n$stack');
        }
      }
    }
    await MockAuthService.signOut();
    // Clear all authenticated and workflow state
    AppState.reset();
  }

  // -- Mock helpers --

  static Future<AuthResult> _mockSignIn(
    String email,
    String password,
    String role,
  ) async {
    final result = await MockAuthService.signIn(
      email: email,
      password: password,
      role: role,
    );

    return AuthResult(
      success: result.success,
      userId: result.userId,
      profile: result.profile,
      error: result.error,
      role: result.profile?.role ?? role,
    );
  }

  static Future<AuthResult> _mockSignUp(
    String email,
    String password,
    String fullName,
    String role,
    String extra, {
    String phone = '',
  }) async {
    final result = await MockAuthService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
      profession: role == 'worker' ? extra : null,
      cooperative: role == 'cooperative_admin' ? extra : null,
    );

    return AuthResult(
      success: result.success,
      userId: result.userId,
      profile: result.profile,
      error: result.error,
      role: result.profile?.role ?? role,
    );
  }

  static String _parseAuthError(dynamic e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      final code = (e.code ?? '').toLowerCase();

      if (code == 'user_already_exists' ||
          msg.contains('already registered') ||
          msg.contains('user already exists') ||
          msg.contains('already exists')) {
        return 'An account with this email already exists.';
      }
      if (code == 'invalid_credentials' ||
          msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials')) {
        return 'Invalid email or password.';
      }
      if (code == 'email_not_confirmed' ||
          msg.contains('email not confirmed')) {
        return 'Please verify your email before signing in. Check your inbox for a confirmation link.';
      }
      if (code == 'weak_password' ||
          msg.contains('weak password') ||
          msg.contains('password should be') ||
          msg.contains('at least 6 characters') ||
          msg.contains('password_too_short')) {
        return 'Password is too weak. Use at least 6 characters.';
      }
      if (code == 'validation_failed' ||
          msg.contains('invalid email') ||
          msg.contains('valid email')) {
        return 'Please enter a valid email address.';
      }
      if (code == 'over_request_rate_limit' ||
          msg.contains('rate limit') ||
          msg.contains('too many requests')) {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      if (msg.contains('user not found')) {
        return 'No account found with this email.';
      }
      if (msg.isNotEmpty) {
        return e.message;
      }
    }

    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('email not confirmed') ||
        msg.contains('email_not_confirmed')) {
      return 'Please verify your email before signing in. Check your inbox for a confirmation link.';
    }
    if (msg.contains('already registered') ||
        msg.contains('user_already_exists') ||
        msg.contains('user already exists')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('invalid email') || msg.contains('invalid_email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('weak password') || msg.contains('password_too_short')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('network') ||
        msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('timeout')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (msg.contains('too many requests') || msg.contains('rate_limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('user not found')) {
      return 'No account found with this email.';
    }
    return 'An error occurred. Please try again.';
  }
}

class AuthResult {
  final bool success;
  final String? userId;
  final UserProfile? profile;
  final String? error;

  /// The resolved role — read from user_profile when available, otherwise
  /// falls back to the role selected on the role-selection screen.
  final String role;

  const AuthResult({
    required this.success,
    this.userId,
    this.profile,
    this.error,
    this.role = 'customer',
  });
}
