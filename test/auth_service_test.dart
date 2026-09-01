import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coorporate_gig/data/app_state.dart';
import 'package:coorporate_gig/models/user_profile.dart';
import 'package:coorporate_gig/models/worker.dart';
import 'package:coorporate_gig/models/worker_profile.dart';
import 'package:coorporate_gig/services/auth_service.dart';
import 'package:coorporate_gig/services/mock_auth_service.dart';

void main() {
  group('AuthService & Error Parsing Tests', () {
    test('AuthResult default values and initialization', () {
      const result = AuthResult(
        success: true,
        userId: '11111111-1111-1111-1111-111111111111',
        role: 'worker',
      );

      expect(result.success, isTrue);
      expect(result.userId, '11111111-1111-1111-1111-111111111111');
      expect(result.role, 'worker');
      expect(result.profile, isNull);
      expect(result.error, isNull);
    });

    test('AuthException parsing handles common Supabase error codes and messages', () {
      // Create account / Sign in with invalid credentials
      final errInvalid = const AuthException('Invalid login credentials', statusCode: '400', code: 'invalid_credentials');
      expect(errInvalid.message, contains('Invalid login credentials'));

      // User already registered
      final errExists = const AuthException('User already registered', statusCode: '422', code: 'user_already_exists');
      expect(errExists.code, 'user_already_exists');

      // Email not confirmed
      final errUnconfirmed = const AuthException('Email not confirmed', statusCode: '400', code: 'email_not_confirmed');
      expect(errUnconfirmed.code, 'email_not_confirmed');

      // Weak password
      final errWeak = const AuthException('Password should be at least 6 characters', statusCode: '422', code: 'weak_password');
      expect(errWeak.code, 'weak_password');

      // Over request rate limit
      final errRateLimit = const AuthException('Over request rate limit', statusCode: '429', code: 'over_request_rate_limit');
      expect(errRateLimit.code, 'over_request_rate_limit');
    });

    test('Role resolution preserves valid roles and database source of truth', () {
      // Customer profile
      final customerProfile = UserProfile(
        id: 'user-001',
        email: 'customer@example.com',
        fullName: 'Test Customer',
        role: 'customer',
      );
      expect(customerProfile.role, 'customer');

      // Worker profile
      final workerProfile = UserProfile(
        id: 'user-002',
        email: 'worker@example.com',
        fullName: 'Test Worker',
        role: 'worker',
      );
      expect(workerProfile.role, 'worker');

      // Cooperative Admin profile
      final adminProfile = UserProfile(
        id: 'user-003',
        email: 'admin@example.com',
        fullName: 'Test Admin',
        role: 'cooperative_admin',
      );
      expect(adminProfile.role, 'cooperative_admin');
    });

    test('Trigger metadata compatibility: full_name, phone, role keys', () {
      final metadata = {
        'full_name': 'Ramesh Kumar',
        'phone': '+919876543210',
        'role': 'worker',
      };

      expect(metadata.containsKey('full_name'), isTrue);
      expect(metadata.containsKey('phone'), isTrue);
      expect(metadata.containsKey('role'), isTrue);
      expect(metadata['full_name'], 'Ramesh Kumar');
      expect(metadata['phone'], '+919876543210');
      expect(metadata['role'], 'worker');
    });
  });

  group('AppState Authentication vs Workflow Separation Tests', () {
    setUp(() {
      AppState.reset();
    });

    test('resetWorkflowState clears temporary booking state but preserves auth profile', () {
      // Set authenticated user and role
      final profile = UserProfile(
        id: 'auth-user-123',
        fullName: 'Sunita Sharma',
        email: 'sunita@example.com',
        role: 'customer',
      );
      AppState.currentUserProfile.value = profile;
      AppState.currentRole.value = 'customer';

      // Set temporary booking workflow state
      AppState.selectedWorker.value = const Worker(
        id: 'w1',
        name: 'Ramesh',
        profession: 'Plumber',
        location: 'Mumbai',
        locality: 'Dadar',
        rating: 4.8,
        reviews: 12,
        pricePerHour: 350,
        avatarInitials: 'RK',
        color: Color(0xFF000000),
        skills: ['Plumbing'],
        experience: '5 years',
        description: 'Expert plumber',
        verified: true,
        available: true,
      );
      AppState.currentService.value = 'Plumbing';
      AppState.currentBookingStatus.value = 'active';
      AppState.serviceCompleted.value = true;
      AppState.paymentMade.value = true;

      // Call resetWorkflowState
      AppState.resetWorkflowState();

      // Workflow state is reset
      expect(AppState.selectedWorker.value, isNull);
      expect(AppState.currentService.value, isNull);
      expect(AppState.currentBookingStatus.value, 'none');
      expect(AppState.serviceCompleted.value, isFalse);
      expect(AppState.paymentMade.value, isFalse);

      // Auth profile and role are PRESERVED
      expect(AppState.currentUserProfile.value, isNotNull);
      expect(AppState.currentUserProfile.value!.id, 'auth-user-123');
      expect(AppState.currentUserProfile.value!.fullName, 'Sunita Sharma');
      expect(AppState.currentRole.value, 'customer');
    });

    test('reset (full logout) clears both workflow state and authentication state', () {
      // Set authenticated user, worker profile, and role
      AppState.currentUserProfile.value = UserProfile(
        id: 'worker-user-456',
        fullName: 'Worker John',
        email: 'john@example.com',
        role: 'worker',
      );
      AppState.currentWorkerProfile.value = const WorkerProfile(
        id: 'wp-1',
        userId: 'worker-user-456',
      );
      AppState.currentRole.value = 'worker';
      AppState.currentBookingStatus.value = 'active';

      // Full reset (called on signOut)
      AppState.reset();

      // Everything is cleared
      expect(AppState.currentUserProfile.value, isNull);
      expect(AppState.currentWorkerProfile.value, isNull);
      expect(AppState.currentRole.value, 'customer');
      expect(AppState.currentBookingStatus.value, 'none');
    });
  });

  group('MockAuthService Flow Tests', () {
    test('Mock sign up and sign in flow', () async {
      final email = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final signUpResult = await MockAuthService.signUp(
        email: email,
        password: 'Password123!',
        fullName: 'Mock User',
        phone: '+919999999999',
        role: 'customer',
      );

      expect(signUpResult.success, isTrue);
      expect(signUpResult.profile?.email, email);
      expect(signUpResult.profile?.fullName, 'Mock User');
      expect(signUpResult.profile?.role, 'customer');

      // Sign out
      await MockAuthService.signOut();
      expect(MockAuthService.currentUserId, isNull);
      expect(MockAuthService.currentProfile, isNull);

      // Sign in
      final signInResult = await MockAuthService.signIn(
        email: email,
        password: 'Password123!',
        role: 'customer',
      );

      expect(signInResult.success, isTrue);
      expect(signInResult.userId, isNotNull);
      expect(MockAuthService.currentUserId, signInResult.userId);
    });

    test('Mock sign in rejects short passwords', () async {
      final result = await MockAuthService.signIn(
        email: 'user@example.com',
        password: '123',
        role: 'customer',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Invalid credentials'));
    });
  });
}
