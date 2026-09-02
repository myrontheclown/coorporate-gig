import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Why the device location could not be obtained.
enum LocationAccessStatus {
  granted,
  denied,
  permanentlyDenied,
  servicesDisabled,
  timeout,
  unknown,
}

/// Structured result of a location request so screens never have to deal
/// with raw plugin exceptions.
class LocationAccessResult {
  final LatLng? position;

  /// Estimated horizontal accuracy in meters (when the platform reports it).
  final double? accuracyMeters;
  final LocationAccessStatus status;

  const LocationAccessResult({
    this.position,
    this.accuracyMeters,
    this.status = LocationAccessStatus.granted,
  });

  bool get ok => position != null;
}

/// Wraps device GPS / permission access. Android, iOS and web safe.
///
/// Consuming widgets never import `geolocator` directly, keeping them
/// testable and easy to swap for another provider.
class LocationService {
  static const Duration _timeout = Duration(seconds: 12);

  /// Whether device location services are switched on.
  static Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Opens the system settings for the app (used after permanent denial).
  static Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  /// Requests permission (if needed) and returns the current position.
  ///
  /// Never throws; failures are returned as a [LocationAccessResult] with a
  /// non-`granted` status so callers can render friendly UI.
  static Future<LocationAccessResult> getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const LocationAccessResult(
          status: LocationAccessStatus.servicesDisabled,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationAccessResult(
          status: LocationAccessStatus.denied,
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationAccessResult(
          status: LocationAccessStatus.permanentlyDenied,
        );
      }
      if (permission == LocationPermission.unableToDetermine) {
        return const LocationAccessResult(
          status: LocationAccessStatus.unknown,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(_timeout);

      return LocationAccessResult(
        position: LatLng(position.latitude, position.longitude),
        accuracyMeters: position.accuracy.isFinite ? position.accuracy : null,
      );
    } on LocationServiceDisabledException {
      return const LocationAccessResult(
        status: LocationAccessStatus.servicesDisabled,
      );
    } on TimeoutException {
      return const LocationAccessResult(status: LocationAccessStatus.timeout);
    } catch (_) {
      return const LocationAccessResult(status: LocationAccessStatus.unknown);
    }
  }

  /// Friendly, human-readable descriptions for each failure state.
  static String describeFailure(LocationAccessStatus status) {
    switch (status) {
      case LocationAccessStatus.denied:
        return 'Location permission was denied. You can still pick a spot on the map.';
      case LocationAccessStatus.permanentlyDenied:
        return 'Location permission is permanently blocked. Allow location access in settings to use this feature.';
      case LocationAccessStatus.servicesDisabled:
        return 'Location services are switched off. Turn them on to find your current location.';
      case LocationAccessStatus.timeout:
        return "Couldn't get your location in time. Try again or pick a spot on the map.";
      case LocationAccessStatus.unknown:
        return "Couldn't get your location. Try again or pick a spot on the map.";
      case LocationAccessStatus.granted:
        return '';
    }
  }
}