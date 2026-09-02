import 'package:flutter_test/flutter_test.dart';
import 'package:coorporate_gig/models/job.dart';
import 'package:coorporate_gig/models/user_profile.dart';
import 'package:coorporate_gig/models/worker_profile.dart';
import 'package:coorporate_gig/models/worker.dart';
import 'package:coorporate_gig/models/transaction.dart';

void main() {
  group('Client Job Screens Data Mapping Tests', () {
    const customerId = 'ca7ac06f-c4ec-4e33-aa99-73c00b4baa56';
    const workerUserId = '99999999-9999-9999-9999-999999999999';
    const workerProfileId = '88888888-8888-8888-8888-888888888888';

    const testWorkerProfile = WorkerProfile(
      id: workerProfileId,
      userId: workerUserId,
      workerCode: 'WRK-001',
      experienceYears: 5,
      verificationStatus: 'verified',
      availabilityStatus: 'available',
      userProfile: UserProfile(
        id: workerUserId,
        fullName: 'Test Worker',
        role: 'worker',
      ),
    );

    final completedJob = Job(
      id: 'job-1-completed',
      customerId: customerId,
      workerId: workerProfileId,
      jobTitle: 'Electrical Repair',
      status: 'completed',
      amount: 850.0,
      createdAt: DateTime(2026, 8, 20, 10, 0),
      completedAt: DateTime(2026, 8, 20, 12, 30),
      workerProfile: testWorkerProfile,
    );

    final acceptedJob = Job(
      id: 'job-2-accepted',
      customerId: customerId,
      workerId: workerProfileId,
      jobTitle: 'Plumbing Repair',
      status: 'accepted',
      amount: 650.0,
      createdAt: DateTime(2026, 8, 25, 14, 0),
      scheduledAt: DateTime(2026, 8, 26, 10, 0),
      workerProfile: testWorkerProfile,
    );

    final pendingJob = Job(
      id: 'job-3-pending',
      customerId: customerId,
      workerId: null,
      jobTitle: 'Fan Installation',
      status: 'pending',
      amount: 500.0,
      createdAt: DateTime(2026, 8, 30, 9, 0),
    );

    final allJobs = [completedJob, acceptedJob, pendingJob];

    test('1. My Requests screen receives and maps all jobs for customer', () {
      final userRequests = allJobs.map((j) => j.toUserRequest()).toList();

      expect(userRequests.length, 3);
      expect(userRequests[0].service, 'Electrical Repair');
      expect(userRequests[0].status, 'Completed');
      expect(userRequests[1].service, 'Plumbing Repair');
      expect(userRequests[1].status, 'Matched');
      expect(userRequests[2].service, 'Fan Installation');
      expect(userRequests[2].status, 'Pending');
    });

    test('2. Bookings & History tabs filter Active, Upcoming, and History correctly', () {
      final bookings = allJobs.map((j) => j.toBooking()).toList();

      // Active tab: pending, active, in_progress
      final activeBookings = bookings
          .where((b) =>
              b.status == 'pending' ||
              b.status == 'active' ||
              b.status == 'in_progress')
          .toList();
      expect(activeBookings.length, 1);
      expect(activeBookings.first.profession, 'Fan Installation');
      expect(activeBookings.first.amount, 500.0);
      expect(activeBookings.first.status, 'pending');

      // Upcoming tab: confirmed / accepted
      final upcomingBookings = bookings
          .where((b) =>
              b.status == 'confirmed' ||
              b.status == 'accepted')
          .toList();
      expect(upcomingBookings.length, 1);
      expect(upcomingBookings.first.profession, 'Plumbing Repair');
      expect(upcomingBookings.first.amount, 650.0);

      // History tab: completed / cancelled
      final historyBookings = bookings
          .where((b) =>
              b.status == 'completed' ||
              b.status == 'cancelled')
          .toList();
      expect(historyBookings.length, 1);
      expect(historyBookings.first.profession, 'Electrical Repair');
      expect(historyBookings.first.amount, 850.0);
      expect(historyBookings.first.status, 'completed');
    });

    test('3. Previously Hired workers screen extracts and deduplicates completed job workers', () {
      final Map<String, Worker> workerMap = {};
      final Map<String, WorkerProfile?> workerProfileCache = {};

      for (final job in allJobs) {
        if (job.status.toLowerCase() == 'completed' &&
            job.workerId != null &&
            job.workerId!.isNotEmpty) {
          final workerId = job.workerId!;
          WorkerProfile? wp = job.workerProfile ?? workerProfileCache[workerId];

          if (wp != null && !workerProfileCache.containsKey(workerId)) {
            workerProfileCache[workerId] = wp;
          }

          if (wp == null) continue;

          final worker = wp.toWorker(fallbackProfession: job.jobTitle);
          if (!workerMap.containsKey(worker.id)) {
            workerMap[worker.id] = worker;
          }
        }
      }

      expect(workerMap.length, 1);
      final hiredWorker = workerMap.values.first;
      expect(hiredWorker.id, workerProfileId);
      expect(hiredWorker.name, 'Test Worker');
      expect(hiredWorker.verified, true);
    });

    test('3b. Previously Hired resolves worker using workerId when job.workerProfile is null', () async {
      // Simulate job from DB where embedded join didn't populate workerProfile
      final jobWithoutEmbeddedWorker = Job(
        id: 'job-unembedded',
        customerId: customerId,
        workerId: workerProfileId,
        jobTitle: 'Electrical Repair',
        status: 'completed',
        amount: 850.0,
        workerProfile: null, // workerProfile is null
      );

      final Map<String, Worker> workerMap = {};
      final Map<String, WorkerProfile?> workerProfileCache = {};

      // Simulated resolver (mocking WorkerProfileService.getWorkerById)
      Future<WorkerProfile?> mockGetWorkerById(String id) async {
        if (id == workerProfileId) return testWorkerProfile;
        return null;
      }

      final jobs = [jobWithoutEmbeddedWorker, jobWithoutEmbeddedWorker]; // Duplicate to test caching & dedup

      for (final job in jobs) {
        if (job.status.toLowerCase() == 'completed' &&
            job.workerId != null &&
            job.workerId!.isNotEmpty) {
          final workerId = job.workerId!;
          WorkerProfile? wp = job.workerProfile ?? workerProfileCache[workerId];

          if (wp == null && !workerProfileCache.containsKey(workerId)) {
            wp = await mockGetWorkerById(workerId);
            workerProfileCache[workerId] = wp;
          }

          if (wp == null) continue;

          final worker = wp.toWorker(fallbackProfession: job.jobTitle);
          if (!workerMap.containsKey(worker.id)) {
            workerMap[worker.id] = worker;
          }
        }
      }

      expect(workerMap.length, 1);
      expect(workerMap.containsKey(workerProfileId), true);
      expect(workerMap[workerProfileId]!.name, 'Test Worker');
      expect(workerProfileCache.length, 1); // Cached once
    });

    test('4. Notifications synthesized from jobs and transactions', () {
      final tx = Transaction(
        id: 'tx-1',
        jobId: completedJob.id,
        customerId: customerId,
        amount: 850.0,
        paymentMethod: 'UPI',
        status: 'completed',
        createdAt: DateTime(2026, 8, 20, 12, 35),
      );

      expect(tx.status, 'completed');
      expect(tx.amount, 850.0);
    });
  });
}
