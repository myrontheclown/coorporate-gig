import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/worker_profile.dart';
import 'mock_auth_service.dart';
import 'supabase_service.dart';
import 'user_profile_service.dart';

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
      if (response?.user != null) {
        final profile = await fetchCurrentUserProfile();
        return AuthResult(
          success: true,
          userId: response!.user!.id,
          profile: profile,
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

  /// Create account with mock or Supabase auth.
  static Future<AuthResult> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String extra = '',
  }) async {
    if (!SupabaseService.isReady) {
      return _mockSignUp(email, password, fullName, role, extra);
    }

    try {
      final response = await signUp(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
      );
      if (response?.user != null) {
        return AuthResult(
          success: true,
          userId: response!.user!.id,
        );
      }
      return const AuthResult(success: false, error: 'Account creation failed.');
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

  /// Registers a new user via Supabase Auth and creates their user_profile.
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
          'role': role,
        },
      );

      final user = response.user;
      if (user != null) {
        final profile = UserProfile(
          id: user.id,
          fullName: fullName,
          email: email.trim(),
          phone: phone,
          role: role,
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          createdAt: DateTime.now(),
        );

        await UserProfileService.createProfile(profile);

        if (role == 'worker') {
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

          if (SupabaseService.isReady) {
            final data = workerProfile.toJson();
            data.remove('id');
            await SupabaseService.client!.from('worker_profile').insert(data);
          }
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

  /// Signs out of the current session.
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
    );
  }

  static Future<AuthResult> _mockSignUp(
    String email,
    String password,
    String fullName,
    String role,
    String extra,
  ) async {
    final result = await MockAuthService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      profession: role == 'worker' ? extra : null,
      cooperative: role == 'cooperative_admin' ? extra : null,
    );

    return AuthResult(
      success: result.success,
      userId: result.userId,
      profile: result.profile,
      error: result.error,
    );
  }

  static String _parseAuthError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    return 'An error occurred. Please try again.';
  }
}

class AuthResult {
  final bool success;
  final String? userId;
  final UserProfile? profile;
  final String? error;

  const AuthResult({
    required this.success,
    this.userId,
    this.profile,
    this.error,
  });
}
