import 'package:flutter/foundation.dart';
import '../models/worker_profile.dart';
import 'worker_profile_service.dart';

/// Outcome of a map-worker load, kept explicit so the UI can distinguish
/// "queried, but no rows exist" from "the query itself failed (e.g. RLS)".
class WorkerMapLoad {
  final List<WorkerProfile> workers;
  final bool failed;

  const WorkerMapLoad(this.workers, {this.failed = false});
}

/// Dedicated data source for the client-side worker map.
///
/// Only workers that are [verified + available] and carry valid coordinates
/// may be rendered as map markers. This is a thin, purpose-built wrapper over
/// the shared [WorkerProfileService] catalog, so it stays consistent with every
/// other client module.
///
/// IMPORTANT: this query is deliberately INDEPENDENT of the customer location.
/// No distance/radius, geo-bounds or "near me" conditions are applied here —
/// the full eligible dataset always loads, and the customer location is used
/// later in Flutter only for centering the map and calculating distances.
///
/// Worker identity + coordinates come from `public.worker_profile`
/// (latitude / longitude). Names are enriched from `public.user_profile`
/// (worker_profile.user_id -> user_profile.id) in a best-effort, batched way:
/// if the name lookup fails, the worker marker is STILL created from
/// worker_profile.latitude/longitude.
class WorkerLocationService {
  /// Workers eligible for the client map (verified + available + coords).
  ///
  /// Fails safe: an unavailable Supabase client or a failed query returns an
  /// empty list with [WorkerMapLoad.failed] set, never an exception.
  static Future<WorkerMapLoad> getMapWorkers() async {
    final load = await WorkerProfileService.loadWorkers(
      availabilityStatus: 'available',
      verificationStatus: 'verified',
      requiredCoordinates: true,
    );

    if (kDebugMode) {
      print('📍 [WorkerLocationService] Loaded workers: '
          '${load.workers.length} (failed=${load.failed}).');
    }

    return WorkerMapLoad(load.workers, failed: load.failed);
  }
}
