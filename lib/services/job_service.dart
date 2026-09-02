import 'package:flutter/foundation.dart';
import '../models/job.dart';
import 'supabase_service.dart';

class JobService {
  static const String _tableName = 'jobs';
  static const String _selectQuery =
      '*, worker_profile:worker_id(*, user_profile:user_id(*), cooperative_profile:cooperative_id(*)), customer_profile:customer_id(*)';

  /// Retrieves all jobs requested by a specific customer.
  static Future<List<Job>> getJobsForCustomer(String customerId) async {
    if (!SupabaseService.isReady || customerId.isEmpty) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select(_selectQuery)
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [JobService.getJobsForCustomer] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves all jobs assigned to a specific worker.
  static Future<List<Job>> getJobsForWorker(
    String workerId, {
    String? status,
  }) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return [];

    try {
      var query = SupabaseService.client!
          .from(_tableName)
          .select(_selectQuery)
          .eq('worker_id', workerId);

      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.eq('status', status.toLowerCase());
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [JobService.getJobsForWorker] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves all jobs in the cooperative/system (for Admin view).
  static Future<List<Job>> getAllJobs({String? status}) async {
    if (!SupabaseService.isReady) return [];

    try {
      var query = SupabaseService.client!.from(_tableName).select(_selectQuery);

      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.eq('status', status.toLowerCase());
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [JobService.getAllJobs] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Creates a new job record.
  static Future<Job?> createJob(Job job) async {
    if (!SupabaseService.isReady) return null;

    try {
      final data = job.toJson();
      if (data['id'] == null || (data['id'] as String).isEmpty) {
        data.remove('id'); // Let Supabase generate UUID default if empty
      }

      final response = await SupabaseService.client!
          .from(_tableName)
          .insert(data)
          .select(_selectQuery)
          .single();

      return Job.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [JobService.createJob] Error: $e\n$stack');
      }
      return null;
    }
  }

  /// Updates job status (pending -> accepted -> in_progress -> completed -> cancelled).
  static Future<bool> updateJobStatus(
    String jobId,
    String status, {
    DateTime? completedAt,
  }) async {
    if (!SupabaseService.isReady || jobId.isEmpty) return false;

    try {
      final Map<String, dynamic> updateData = {'status': status.toLowerCase()};
      if (completedAt != null) {
        updateData['completed_at'] = completedAt.toIso8601String();
      } else if (status.toLowerCase() == 'completed') {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await SupabaseService.client!
          .from(_tableName)
          .update(updateData)
          .eq('id', jobId);

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [JobService.updateJobStatus] Error: $e\n$stack');
      }
      return false;
    }
  }

  /// Assigns a worker to a pending job.
  static Future<bool> assignWorker(String jobId, String workerId) async {
    if (!SupabaseService.isReady || jobId.isEmpty) return false;

    try {
      await SupabaseService.client!.from(_tableName).update({
        'worker_id': workerId,
        'status': 'accepted',
      }).eq('id', jobId);

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [JobService.assignWorker] Error: $e\n$stack');
      }
      return false;
    }
  }
}
