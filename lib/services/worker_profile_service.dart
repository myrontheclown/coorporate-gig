import 'package:flutter/foundation.dart';
import '../models/worker_profile.dart';
import 'supabase_service.dart';

class WorkerProfileService {
  static const String _tableName = 'worker_profile';
  static const String _skillsTableName = 'worker_skills';

  static const String _selectQuery =
      '*, user_profile:user_id(*), cooperative_profile:cooperative_id(*)';

  /// Retrieves list of workers with user and cooperative profiles joined.
  static Future<List<WorkerProfile>> getWorkers({
    String? availabilityStatus,
    String? verificationStatus,
  }) async {
    if (!SupabaseService.isReady) return [];

    try {
      var query =
          SupabaseService.client!.from(_tableName).select(_selectQuery);

      if (availabilityStatus != null &&
          availabilityStatus.isNotEmpty &&
          availabilityStatus != 'All') {
        query = query.eq(
          'availability_status',
          availabilityStatus.toLowerCase(),
        );
      }

      if (verificationStatus != null &&
          verificationStatus.isNotEmpty) {
        query = query.eq(
          'verification_status',
          verificationStatus.toLowerCase(),
        );
      }

      final response =
          await query.order('created_at', ascending: false);

      return (response as List)
          .map(
            (json) => WorkerProfile.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.getWorkers] Error: $e\n$stack',
        );
      }
      return [];
    }
  }

  /// Retrieves a single worker by worker_profile id.
  static Future<WorkerProfile?> getWorkerById(
    String workerId,
  ) async {
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
        print(
          '⚠️ [WorkerProfileService.getWorkerById] Error: $e\n$stack',
        );
      }
      return null;
    }
  }

  /// Retrieves a worker profile by user_id.
  static Future<WorkerProfile?> getWorkerByUserId(
    String userId,
  ) async {
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
        print(
          '⚠️ [WorkerProfileService.getWorkerByUserId] Error: $e\n$stack',
        );
      }
      return null;
    }
  }

  // ============================================================
  // UPDATE WORKER PROFILE
  // ============================================================

  /// Updates worker-specific information.
  ///
  /// This updates:
  /// - Emergency contact name
  /// - Emergency contact phone
  /// - Service area
  /// - Working area
  static Future<bool> updateWorkerDetails({
    required String workerId,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String serviceArea,
    required String workingArea,
  }) async {
    if (!SupabaseService.isReady || workerId.isEmpty) {
      return false;
    }

    try {
      await SupabaseService.client!
          .from(_tableName)
          .update({
            'emergency_contact_name': emergencyContactName,
            'emergency_contact_phone': emergencyContactPhone,
            'service_area': serviceArea,
            'working_area': workingArea,
          })
          .eq('id', workerId);

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.updateWorkerDetails] '
          'Error: $e\n$stack',
        );
      }

      return false;
    }
  }

  // ============================================================
  // WORKER SKILLS
  // ============================================================

  /// Gets all skills belonging to a worker.
  static Future<List<String>> getWorkerSkills(
    String workerId,
  ) async {
    if (!SupabaseService.isReady || workerId.isEmpty) {
      return [];
    }

    try {
      final response = await SupabaseService.client!
          .from(_skillsTableName)
          .select('skill_name')
          .eq('worker_id', workerId)
          .order('created_at', ascending: true);

      return (response as List)
          .map(
            (item) => item['skill_name']?.toString() ?? '',
          )
          .where((skill) => skill.isNotEmpty)
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.getWorkerSkills] '
          'Error: $e\n$stack',
        );
      }

      return [];
    }
  }

  /// Replaces the worker's existing skills with the supplied list.
  static Future<bool> updateWorkerSkills({
    required String workerId,
    required List<String> skills,
  }) async {
    if (!SupabaseService.isReady || workerId.isEmpty) {
      return false;
    }

    try {
      final client = SupabaseService.client!;

      // Remove existing skills first.
      await client
          .from(_skillsTableName)
          .delete()
          .eq('worker_id', workerId);

      // Remove empty skills and duplicates.
      final cleanedSkills = skills
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toSet()
          .toList();

      // If there are no skills, we are done.
      if (cleanedSkills.isEmpty) {
        return true;
      }

      // Insert the new skills.
      final rows = cleanedSkills
          .map(
            (skill) => {
              'worker_id': workerId,
              'skill_name': skill,
            },
          )
          .toList();

      await client.from(_skillsTableName).insert(rows);

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.updateWorkerSkills] '
          'Error: $e\n$stack',
        );
      }

      return false;
    }
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  /// Updates worker availability status.
  static Future<bool> updateAvailability(
    String workerId,
    String status,
  ) async {
    if (!SupabaseService.isReady || workerId.isEmpty) {
      return false;
    }

    try {
      await SupabaseService.client!
          .from(_tableName)
          .update({
            'availability_status': status,
          })
          .eq('id', workerId);

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.updateAvailability] '
          'Error: $e\n$stack',
        );
      }

      return false;
    }
  }

  // ============================================================
  // VERIFICATION
  // ============================================================

  /// Updates worker verification status.
  static Future<bool> updateVerification(
    String workerId,
    String status,
  ) async {
    if (!SupabaseService.isReady || workerId.isEmpty) {
      return false;
    }

    try {
      await SupabaseService.client!
          .from(_tableName)
          .update({
            'verification_status': status,
          })
          .eq('id', workerId);

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.updateVerification] '
          'Error: $e\n$stack',
        );
      }

      return false;
    }
  }
}