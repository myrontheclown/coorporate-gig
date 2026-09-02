import 'package:flutter_test/flutter_test.dart';
import 'package:coorporate_gig/models/user_profile.dart';
import 'package:coorporate_gig/models/cooperative_profile.dart';
import 'package:coorporate_gig/models/worker_profile.dart';
import 'package:coorporate_gig/models/job.dart';
import 'package:coorporate_gig/models/transaction.dart';

void main() {
  group('Supabase Models Serialization & UI Converters', () {
    test('UserProfile json serialization round-trip', () {
      final user = UserProfile(
        id: '11111111-1111-1111-1111-111111111111',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '+919999999999',
        role: 'customer',
        address: '123 Test St',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
      );

      final json = user.toJson();
      final fromJson = UserProfile.fromJson(json);

      expect(fromJson.id, user.id);
      expect(fromJson.fullName, user.fullName);
      expect(fromJson.email, user.email);
      expect(fromJson.role, 'customer');
      expect(fromJson.city, 'Mumbai');
    });

    test('CooperativeProfile json serialization', () {
      final coop = CooperativeProfile(
        id: '22222222-2222-2222-2222-222222222222',
        name: 'Mumbai Workers Cooperative',
        registrationNumber: 'COOP-1234',
        type: 'Labor',
        city: 'Mumbai',
      );

      final json = coop.toJson();
      final fromJson = CooperativeProfile.fromJson(json);

      expect(fromJson.id, coop.id);
      expect(fromJson.name, 'Mumbai Workers Cooperative');
      expect(fromJson.registrationNumber, 'COOP-1234');
    });

    test('WorkerProfile toWorker adapter produces valid Worker UI model', () {
      const user = UserProfile(
        id: '11111111-1111-1111-1111-111111111111',
        fullName: 'Ramesh Kumar',
        city: 'Mumbai',
        address: 'Grant Road',
      );

      const coop = CooperativeProfile(
        id: '22222222-2222-2222-2222-222222222222',
        name: 'Mumbai Workers Coop',
      );

      const wp = WorkerProfile(
        id: '33333333-3333-3333-3333-333333333333',
        userId: '11111111-1111-1111-1111-111111111111',
        experienceYears: 8,
        verificationStatus: 'verified',
        availabilityStatus: 'on_duty',
        userProfile: user,
        cooperativeProfile: coop,
      );

      final uiWorker = wp.toWorker(fallbackProfession: 'Plumbing Specialist');

      expect(uiWorker.id, wp.id);
      expect(uiWorker.name, 'Ramesh Kumar');
      expect(uiWorker.profession, 'Plumbing Specialist');
      expect(uiWorker.verified, true);
      expect(uiWorker.available, true);
      expect(uiWorker.cooperative, 'Mumbai Workers Coop');
      expect(uiWorker.avatarInitials, 'RK');
    });

    test('Job toBooking and toUserRequest adapters produce valid UI models', () {
      final job = Job(
        id: '44444444-4444-4444-4444-444444444444',
        customerId: '11111111-1111-1111-1111-111111111111',
        jobTitle: 'Plumbing Repair',
        description: 'Fixing water leak',
        status: 'in_progress',
        amount: 1050,
      );

      final booking = job.toBooking();
      expect(booking.id, job.id);
      expect(booking.status, 'active');
      expect(booking.amount, 1050);

      final request = job.toUserRequest();
      expect(request.id, job.id);
      expect(request.status, 'In Progress');
      expect(request.service, 'Plumbing Repair');
    });

    test('Transaction json serialization', () {
      final tx = Transaction(
        id: '55555555-5555-5555-5555-555555555555',
        jobId: '44444444-4444-4444-4444-444444444444',
        customerId: '11111111-1111-1111-1111-111111111111',
        amount: 1050.0,
        paymentMethod: 'UPI',
        status: 'completed',
        transactionReference: 'TXN12345678',
      );

      final json = tx.toJson();
      final fromJson = Transaction.fromJson(json);

      expect(fromJson.id, tx.id);
      expect(fromJson.amount, 1050.0);
      expect(fromJson.paymentMethod, 'UPI');
      expect(fromJson.status, 'completed');
    });
  });
}
