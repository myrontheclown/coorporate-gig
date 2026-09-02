import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../data/app_state.dart';
import '../utils/location_utils.dart';
import 'location_service.dart';
import 'supabase_service.dart';

/// A resolved client position (GPS fix or persisted profile coordinates).
class ClientLocationFix {
  final LatLng position;
  final double? accuracyMeters;

  const ClientLocationFix(this.position, {this.accuracyMeters});
}

/// Owns the client-side location pipeline: fresh GPS, persisted
/// user_profile coordinates, and a throttled sync back to Supabase.
///
/// Responsibilities:
///  - resolve the initial map position (GPS -> saved profile -> fallback)
///  - publish the latest device fix so the map can update locally
///  - persist meaningful GPS changes to public.user_profile (debounced)
///
/// Supabase writes live here, never inside UI widgets. The app's existing
/// Supabase JS/postgrest client is reused — no second client is created.
class ClientLocationService {
  // ---------------------------------------------------------------------------
  // Sync policy — single place to tune database write frequency.
  // ---------------------------------------------------------------------------

  /// Only persist a new fix when it differs from the last stored one by at
  /// least this much (metres).
  static const double minSyncDistanceMeters = 150;

  /// Always persist at least this often when the app stays open.
  static const Duration minSyncInterval = Duration(minutes: 10);

  // ---------------------------------------------------------------------------
  // Local state
  // ---------------------------------------------------------------------------

  /// Latest known client position (updated locally on every useful GPS event).
  static final ValueNotifier<ClientLocationFix?> currentFix =
      ValueNotifier(null);

  static LatLng? _lastSyncedPosition;
  static DateTime? _lastSyncTime;

  /// Reads the persisted location from the authenticated user profile,
  /// if present.
  static LatLng? savedProfileLocation() {
    final profile = AppState.currentUserProfile.value;
    if (profile != null &&
        profile.latitude != null &&
        profile.longitude != null) {
      return LatLng(profile.latitude!, profile.longitude!);
    }
    return null;
  }

  /// Resolves the initial client position using:
  ///  1. a fresh device GPS fix (persisted to user_profile, throttled)
  ///  2. the saved user_profile latitude/longitude
  ///  3. null (caller falls back to the app's demo location)
  static Future<ClientLocationFix?> resolveInitialLocation() async {
    final gps = await LocationService.getCurrentPosition();
    if (gps.ok && gps.position != null) {
      final fix = ClientLocationFix(
        gps.position!,
        accuracyMeters: gps.accuracyMeters,
      );
      currentFix.value = fix;
      unawaited(
        syncLocation(gps.position!, accuracyMeters: gps.accuracyMeters),
      );
      return fix;
    }

    final saved = savedProfileLocation();
    if (saved != null) {
      final fix = ClientLocationFix(saved);
      currentFix.value = fix;
      return fix;
    }

    return null;
  }

  /// Syncs a device fix to public.user_profile, throttled by movement and
  /// time. Local map state is updated immediately by the caller; this method
  /// only decides whether the DATABASE write is worth sending.
  ///
  /// Never throws. Runs only when Supabase is ready and a user is signed in.
  static Future<void> syncLocation(
    LatLng position, {
    double? accuracyMeters,
  }) async {
    if (!SupabaseService.isReady) return;

    final uid = SupabaseService.client?.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;

    final now = DateTime.now();
    if (!shouldPersist(
      lastPosition: _lastSyncedPosition,
      lastTime: _lastSyncTime,
      current: position,
      now: now,
    )) {
      return;
    }

    try {
      await SupabaseService.client!
          .from('user_profile')
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
          })
          .eq('id', uid);

      _lastSyncedPosition = position;
      _lastSyncTime = now;

      final profile = AppState.currentUserProfile.value;
      if (profile != null) {
        AppState.currentUserProfile.value = profile.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      if (kDebugMode) {
        print(
          '📍 [ClientLocationService] Saved location to user_profile '
          '(${position.latitude.toStringAsFixed(5)}, '
          '${position.longitude.toStringAsFixed(5)}).',
        );
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          '⚠️ [ClientLocationService] user_profile UPDATE failed. '
          'Check RLS (needs UPDATE on OWN row): $e\n$stack',
        );
      }
    }
  }

  /// Pure throttle decision, extracted for unit testing.
  ///
  /// Persist when: no previous write yet, the previous write is older than
  /// [minSyncInterval], OR the fix moved at least [minSyncDistanceMeters].
  static bool shouldPersist({
    required LatLng? lastPosition,
    required DateTime? lastTime,
    required LatLng current,
    required DateTime now,
  }) {
    if (lastPosition == null || lastTime == null) return true;
    final elapsed = now.difference(lastTime);
    if (elapsed >= minSyncInterval) return true;
    final metersSinceLast = geoDistanceKm(lastPosition, current) * 1000;
    return metersSinceLast >= minSyncDistanceMeters;
  }
}