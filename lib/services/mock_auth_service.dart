import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Lightweight mock authentication service.
///
/// Used when Supabase is not configured. Any syntactically valid email
/// combined with a password of 6+ characters results in a successful
/// mock login. Replace with real Supabase calls when ready.
class MockAuthService {
  static String? _currentUserId;
  static UserProfile? _currentProfile;
  static final Map<String, UserProfile> _registeredUsers = {};

  static bool get isAuthenticated => _currentUserId != null;

  static String? get currentUserId => _currentUserId;

  static UserProfile? get currentProfile => _currentProfile;

  static Future<MockAuthResult> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (password.length < 6) {
      return MockAuthResult(
        success: false,
        error: 'Invalid credentials.',
      );
    }

    final userId = 'mock-${email.hashCode.abs()}';
    _currentUserId = userId;

    _currentProfile = UserProfile(
      id: userId,
      fullName: _nameFromEmail(email),
      email: email.trim(),
      role: role,
      createdAt: DateTime.now(),
    );

    return MockAuthResult(
      success: true,
      userId: userId,
      profile: _currentProfile,
    );
  }

  static Future<MockAuthResult> signUp({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String phone = '',
    String? profession,
    String? cooperative,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (password.length < 6) {
      return MockAuthResult(
        success: false,
        error: 'Password must be at least 6 characters.',
      );
    }

    final userId = 'mock-${email.hashCode.abs()}';

    final profile = UserProfile(
      id: userId,
      fullName: fullName,
      email: email.trim(),
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );

    _registeredUsers[email.trim()] = profile;

    _currentUserId = userId;
    _currentProfile = profile;

    return MockAuthResult(
      success: true,
      userId: userId,
      profile: profile,
    );
  }

  static Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (kDebugMode) {
      print('[MockAuth] Password reset requested for: $email');
    }
    return true;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUserId = null;
    _currentProfile = null;
  }

  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local
        .split(RegExp(r'[._\-]'))
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }
}

class MockAuthResult {
  final bool success;
  final String? userId;
  final UserProfile? profile;
  final String? error;

  const MockAuthResult({
    required this.success,
    this.userId,
    this.profile,
    this.error,
  });
}
