import 'package:flutter/foundation.dart';
import '../models/worker_profile.dart';
import 'supabase_service.dart';

class WorkerProfileService {
  static const String _tableName = 'worker_profile';
  static const String _selectQuery = '*, user_profile:user_id(*), cooperative_profile:cooperative_id(*)';

  /// Retrieves list of workers with user and cooperative profiles joined.
  /// Pass [onDutyOnly] = true to restrict to workers where is_on_duty = true.
  static Future<List<WorkerProfile>> getWorkers({
    String? availabilityStatus,
    String? verificationStatus,
    bool onDutyOnly = false,
  }) async {
    if (!SupabaseService.isReady) return [];

    try {
      var query = SupabaseService.client!.from(_tableName).select(_selectQuery);

      if (availabilityStatus != null && availabilityStatus.isNotEmpty && availabilityStatus != 'All') {
        query = query.eq('availability_status', availabilityStatus.toLowerCase());
      }

      if (verificationStatus != null && verificationStatus.isNotEmpty) {
        query = query.eq('verification_status', verificationStatus.toLowerCase());
      }

      if (onDutyOnly) {
        query = query.eq('is_on_duty', true);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => WorkerProfile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.getWorkers] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves a single worker by worker_profile id.
  static Future<WorkerProfile?> getWorkerById(String workerId) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select(_selectQuery)
          .eq('id', workerId)
          .maybeSingle();

      if (response == null) return null;
      return WorkerProfile.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.getWorkerById] Error: $e\n$stack');
      }
      return null;
    }
  }

  /// Retrieves a worker profile by user_id.
  static Future<WorkerProfile?> getWorkerByUserId(String userId) async {
    if (!SupabaseService.isReady || userId.isEmpty) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select(_selectQuery)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return WorkerProfile.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.getWorkerByUserId] Error: $e\n$stack');
      }
      return null;
    }
  }

  /// Updates worker availability status ('available', 'on_duty', 'off_duty', 'busy').
  static Future<bool> updateAvailability(String workerId, String status) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return false;

    try {
      await SupabaseService.client!
          .from(_tableName)
          .update({'availability_status': status})
          .eq('id', workerId);
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.updateAvailability] Error: $e\n$stack');
      }
      return false;
    }
  }

  /// Sets the on-duty flag for a worker and records the timestamp.
  /// Returns true on success, false on failure (Supabase not ready or error).
  /// In mock mode (Supabase not configured) returns true immediately so the
  /// optimistic UI update is not reverted.
  static Future<bool> setOnDutyStatus(String workerId, bool isOnDuty) async {
    if (!SupabaseService.isReady) return true; // mock-mode: always succeed

    if (workerId.isEmpty) return false;

    try {
      await SupabaseService.client!
          .from(_tableName)
          .update({
            'is_on_duty': isOnDuty,
            'on_duty_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', workerId);
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.setOnDutyStatus] Error: $e\n$stack');
      }
      return false;
    }
  }

  /// Updates worker verification status ('verified', 'pending', 'rejected').
  static Future<bool> updateVerification(String workerId, String status) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return false;

    try {
      await SupabaseService.client!
          .from(_tableName)
          .update({'verification_status': status})
          .eq('id', workerId);
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.updateVerification] Error: $e\n$stack');
      }
      return false;
    }
  }
}
