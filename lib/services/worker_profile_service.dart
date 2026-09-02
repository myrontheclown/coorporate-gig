import 'package:flutter/foundation.dart';

import '../models/cooperative_profile.dart';
import '../models/user_profile.dart';
import '../models/worker.dart';
import '../models/worker_profile.dart';
import 'supabase_service.dart';

/// Outcome of a worker load, kept explicit so the UI can distinguish
/// "queried, but no rows exist" from "the query itself failed (e.g. RLS)".
class WorkerCatalogLoad {
  final List<WorkerProfile> workers;
  final bool failed;

  const WorkerCatalogLoad(this.workers, {this.failed = false});
}

/// Central, reusable data source for workers.
///
/// Worker identity + coordinates live in `public.worker_profile`
/// (latitude / longitude). The worker's NAME lives in
/// `public.user_profile`, matched via `worker_profile.user_id ->
/// user_profile.id`. Cooperative name lives in `public.cooperative_profile`
/// via `worker_profile.cooperative_id`.
///
/// All client modules (home map/list, search, discovery, admin, and any
/// modules merged later) should go through this service so fetching stays
/// consistent.
///
/// Robustness guarantees:
///  - Fetches rows with a plain `select('*')` — never relies on a fragile
///    nested FK join whose failure would hide real workers.
///  - Names/profile image/cooperative are enriched in batched best-effort
///    queries. A failing enrichment NEVER drops a worker; it only leaves the
///    worker with a safe fallback label ("Worker").
class WorkerProfileService {
  static const String _tableName = 'worker_profile';
  static const String _userTable = 'user_profile';
  static const String _cooperativeTable = 'cooperative_profile';

  /// Fetch worker rows and enrich them with their linked user_profile
  /// (full_name, profile_image) and cooperative_profile (name, logo_url).
  ///
  /// Optional filters:
  ///  - [availabilityStatus]: 'available', 'on_duty', ... or null for all.
  ///  - [verificationStatus]: 'verified', 'pending', ... or null for all.
  ///  - [requiredCoordinates]: only rows with non-null latitude/longitude.
  ///
  /// Does not throw. Returns an empty list on failure/offline.
  static Future<List<WorkerProfile>> getWorkers({
    String? availabilityStatus,
    String? verificationStatus,
    bool requiredCoordinates = false,
  }) async {
    final load = await loadWorkers(
      availabilityStatus: availabilityStatus,
      verificationStatus: verificationStatus,
      requiredCoordinates: requiredCoordinates,
    );
    return load.workers;
  }

  /// Like [getWorkers] but also reports [WorkerCatalogLoad.failed] so callers
  /// can distinguish an empty database from a failed query.
  static Future<WorkerCatalogLoad> loadWorkers({
    String? availabilityStatus,
    String? verificationStatus,
    bool requiredCoordinates = false,
  }) async {
    if (!SupabaseService.isReady) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService] Supabase not ready — offline mode.');
      }
      return const WorkerCatalogLoad([]);
    }

    try {
      var query = SupabaseService.client!.from(_tableName).select('*');

      if (availabilityStatus != null &&
          availabilityStatus.isNotEmpty &&
          availabilityStatus != 'All') {
        query = query.eq(
          'availability_status',
          availabilityStatus.toLowerCase(),
        );
      }

      if (verificationStatus != null && verificationStatus.isNotEmpty) {
        query = query.eq(
          'verification_status',
          verificationStatus.toLowerCase(),
        );
      }

      if (requiredCoordinates) {
        query = query.not('latitude', 'is', null).not('longitude', 'is', null);
      }

      final response = await query.order('created_at', ascending: false);

      final rows = (response as List)
          .map((json) => WorkerProfile.fromJson(json as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        print('📍 [WorkerProfileService] Loaded ${rows.length} workers.');
      }

      await _enrich(rows);

      return WorkerCatalogLoad(rows);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [WorkerProfileService.getWorkers] Error: $e\n$stack');
      }
      return const WorkerCatalogLoad([], failed: true);
    }
  }

  /// Reusable UI catalog: real verified + available workers as [Worker]
  /// models, ready to render in any list/grid. Falls back to nothing on
  /// failure (caller decides its own empty/offline state).
  static Future<List<Worker>> workerCatalog({
    bool verifiedOnly = false,
    bool availableOnly = false,
  }) async {
    final load = await loadWorkers(
      availabilityStatus: availableOnly ? 'available' : null,
      verificationStatus: verifiedOnly ? 'verified' : null,
    );
    return load.workers.map((p) => p.toWorker()).toList();
  }

  /// Retrieves a single worker by worker_profile id.
  static Future<WorkerProfile?> getWorkerById(String workerId) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select('*')
          .eq('id', workerId)
          .maybeSingle();

      if (response != null) {
        return WorkerProfile.fromJson(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.getWorkerById] Primary query error: $e',
        );
      }
    }

    try {
      final fallbackResponse = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('id', workerId)
          .maybeSingle();

      if (fallbackResponse != null) {
        return WorkerProfile.fromJson(fallbackResponse);
      }
    } catch (e2) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.getWorkerById] Fallback query error: $e2',
        );
      }
    }

    return null;
  }

  /// Retrieves a worker profile by user_id.
  static Future<WorkerProfile?> getWorkerByUserId(String userId) async {
    if (!SupabaseService.isReady || userId.isEmpty) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return WorkerProfile.fromJson(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.getWorkerByUserId] Primary query error: $e',
        );
      }
    }

    try {
      final fallbackResponse = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (fallbackResponse != null) {
        return WorkerProfile.fromJson(fallbackResponse);
      }
    } catch (e2) {
      if (kDebugMode) {
        print(
          '⚠️ [WorkerProfileService.getWorkerByUserId] Fallback query error: $e2',
        );
      }
    }

    return null;
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

  /// Best-effort: attach real names/images/cooperative from the linked
  /// profiles. Uses one batched query per related table. Never throws and
  /// never drops workers — a failure only leaves labels blank.
  static Future<void> _enrich(List<WorkerProfile> workers) async {
    if (workers.isEmpty) return;

    final userIds = workers
        .map((w) => w.userId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final cooperativeIds = workers
        .map((w) => w.cooperativeId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final usersById = <String, UserProfile>{};
    if (userIds.isNotEmpty) {
      try {
        final userRows = await SupabaseService.client!
            .from(_userTable)
            .select('id, full_name, profile_image')
            .inFilter('id', userIds);
        final userList = (userRows as List).cast<Map<String, dynamic>>();
        for (final row in userList) {
          final user = UserProfile.fromJson(row);
          if (user.id.isNotEmpty) usersById[user.id] = user;
        }
      } catch (e, stack) {
        if (kDebugMode) {
          print(
            '⚠️ [WorkerProfileService] user_profile enrichment failed '
            '(workers still returned): $e\n$stack',
          );
        }
      }
    }

    final coopsById = <String, CooperativeProfile>{};
    if (cooperativeIds.isNotEmpty) {
      try {
        final coopRows = await SupabaseService.client!
            .from(_cooperativeTable)
            .select('id, name, logo_url')
            .inFilter('id', cooperativeIds);
        final coopList = (coopRows as List).cast<Map<String, dynamic>>();
        for (final row in coopList) {
          final coop = CooperativeProfile.fromJson(row);
          if (coop.id.isNotEmpty) coopsById[coop.id] = coop;
        }
      } catch (e, stack) {
        if (kDebugMode) {
          print(
            '⚠️ [WorkerProfileService] cooperative_profile enrichment '
            'failed (workers still returned): $e\n$stack',
          );
        }
      }
    }

    for (var i = 0; i < workers.length; i++) {
      final w = workers[i];
      workers[i] = WorkerProfile(
        id: w.id,
        userId: w.userId,
        cooperativeId: w.cooperativeId,
        workerCode: w.workerCode,
        experienceYears: w.experienceYears,
        address: w.address,
        city: w.city,
        state: w.state,
        pincode: w.pincode,
        latitude: w.latitude,
        longitude: w.longitude,
        verificationStatus: w.verificationStatus,
        availabilityStatus: w.availabilityStatus,
        createdAt: w.createdAt,
        userProfile: usersById[w.userId],
        cooperativeProfile: coopsById[w.cooperativeId ?? ''],
      );
    }
  }
}
