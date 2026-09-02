import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../models/job.dart';
import 'supabase_service.dart';
import 'worker_profile_service.dart';

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

      final jobs = (response as List)
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();

      for (var i = 0; i < jobs.length; i++) {
        if (jobs[i].workerId != null &&
            jobs[i].workerId!.isNotEmpty &&
            (jobs[i].workerProfile == null ||
                jobs[i].workerProfile!.userProfile == null)) {
          final wp =
              await WorkerProfileService.getWorkerById(jobs[i].workerId!);
          if (wp != null) {
            jobs[i] = jobs[i].copyWith(workerProfile: wp);
          }
        }
      }

      return jobs;
    } catch (e) {
      if (kDebugMode) {
        print(
            '⚠️ [JobService.getJobsForCustomer] Primary query failed: $e. Trying fallback query...');
      }
      try {
        final response = await SupabaseService.client!
            .from(_tableName)
            .select()
            .eq('customer_id', customerId)
            .order('created_at', ascending: false);

        final jobs = (response as List)
            .map((json) => Job.fromJson(json as Map<String, dynamic>))
            .toList();

        for (var i = 0; i < jobs.length; i++) {
          if (jobs[i].workerId != null && jobs[i].workerId!.isNotEmpty) {
            final wp =
                await WorkerProfileService.getWorkerById(jobs[i].workerId!);
            if (wp != null) {
              jobs[i] = jobs[i].copyWith(workerProfile: wp);
            }
          }
        }

        return jobs;
      } catch (e2, stack2) {
        if (kDebugMode) {
          print(
              '⚠️ [JobService.getJobsForCustomer] Fallback query error: $e2\n$stack2');
        }
        return [];
      }
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

  /// Uploads a list of photos (XFile – works on mobile & web) to Supabase Storage
  /// under the 'job-photos' bucket and returns the comma-joined public URLs.
  static Future<String> uploadJobPhotos(List<XFile> photos, String jobId) async {
    if (!SupabaseService.isReady || photos.isEmpty) return '';

    final urls = <String>[];
    for (int i = 0; i < photos.length; i++) {
      try {
        final xfile = photos[i];
        final bytes = await xfile.readAsBytes();
        final ext = xfile.name.split('.').last;
        final path = 'jobs/$jobId/photo_$i.$ext';

        // uploadBinary works on both mobile and web
        await SupabaseService.client!
            .storage
            .from('job-photos')
            .uploadBinary(path, bytes,
                fileOptions: const FileOptions(upsert: true));

        final publicUrl = SupabaseService.client!
            .storage
            .from('job-photos')
            .getPublicUrl(path);
        urls.add(publicUrl);
      } catch (e, stack) {
        if (kDebugMode) {
          print('⚠️ [JobService.uploadJobPhotos] Error uploading photo $i: $e\n$stack');
        }
      }
    }
    return urls.join(',');
  }

  /// Convenience: uploads photos, then creates (or updates) the job with image_url.
  static Future<Job?> createJobWithPhotos({
    required Job job,
    required List<XFile> photos,
  }) async {
    // 1. Create the job first (without image_url) so we have a stable id.
    final created = await createJob(job);
    if (created == null) return null;

    // 2. Upload photos.
    String imageUrl = '';
    if (photos.isNotEmpty) {
      imageUrl = await uploadJobPhotos(photos, created.id);
    }

    // 3. Patch the image_url if photos were uploaded.
    if (imageUrl.isNotEmpty) {
      try {
        await SupabaseService.client!
            .from(_tableName)
            .update({'image_url': imageUrl})
            .eq('id', created.id);
      } catch (e, stack) {
        if (kDebugMode) {
          print('⚠️ [JobService.createJobWithPhotos] Failed to set image_url: $e\n$stack');
        }
      }
      return created.copyWith(imageUrl: imageUrl);
    }

    return created;
  }
}
