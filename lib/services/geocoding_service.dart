import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/map_config.dart';
import '../models/selected_location.dart';

/// Raised when a geocoding request cannot be completed. UI renders
/// [message] directly (no raw exception text is ever shown).
class GeocodingException implements Exception {
  final String message;
  final bool isNetworkError;
  const GeocodingException(this.message, {this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Abstraction that keeps screens decoupled from HTTP details, so a
/// different OpenStreetMap-compatible provider can be swapped in later.
abstract class GeocodingProvider {
  /// Forward geocoding / place search.
  Future<List<SelectedLocation>> searchPlaces(
    String query, {
    LatLng? near,
  });

  /// Reverse geocoding: resolves coordinates into a readable address.
  Future<SelectedLocation?> reverseGeocode(LatLng position);
}

/// Nominatim (OpenStreetMap) implementation with a respectful, identifiable
/// user agent. Public endpoint — no API key required.
class NominatimGeocodingProvider implements GeocodingProvider {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  final String _userAgent;

  NominatimGeocodingProvider([
    this._userAgent = 'CoorporateGig/${MapTileConfig.userAgentPackageName}',
  ]);

  Map<String, String> get _headers => {
        'User-Agent': _userAgent,
        'Accept': 'application/json',
      };

  Future<dynamic> _get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 429) {
        throw const GeocodingException(
          'Too many search requests right now. Please try again in a moment.',
        );
      }
      if (response.statusCode >= 500) {
        throw const GeocodingException(
          'Location service is temporarily unavailable. Please try again.',
        );
      }
      if (response.statusCode != 200) {
        throw const GeocodingException(
          "Couldn't load location details. Please try again.",
        );
      }
      return jsonDecode(response.body);
    } on GeocodingException {
      rethrow;
    } catch (_) {
      throw const GeocodingException(
        'Network error while loading location details. Check your connection.',
        isNetworkError: true,
      );
    }
  }

  @override
  Future<List<SelectedLocation>> searchPlaces(
    String query, {
    LatLng? near,
  }) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query,
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '6',
        if (near != null) ...{
          'lat': near.latitude.toString(),
          'lon': near.longitude.toString(),
          'viewbox': _viewBoxAround(near),
          'bounded': '1',
        },
      },
    );

    final decoded = await _get(uri.toString());
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => _toSelectedLocation(item))
        .toList();
  }

  @override
  Future<SelectedLocation?> reverseGeocode(LatLng position) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'format': 'jsonv2',
        'addressdetails': '1',
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
      },
    );

    final decoded = await _get(uri.toString());
    if (decoded is! Map || decoded.isEmpty) {
      return null;
    }
    return _toSelectedLocation(decoded);
  }

  SelectedLocation _toSelectedLocation(Map<dynamic, dynamic> json) {
    final latitude = double.tryParse(json['lat']?.toString() ?? '');
    final longitude = double.tryParse(json['lon']?.toString() ?? '');
    final displayName = json['display_name']?.toString() ?? '';

    final osmType = json['osm_type']?.toString() ?? '';
    final osmId = json['osm_id']?.toString() ?? '';
    final placeId = osmId.isNotEmpty ? '$osmType-$osmId' : null;

    final address =
        json['address'] is Map ? Map<String, dynamic>.from(json['address']) : {};
    final city = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['municipality'];
    final locality = address['suburb'] ??
        address['neighbourhood'] ??
        address['district'] ??
        address['quarter'] ??
        address['hamlet'];
    final road = address['road'] ??
        address['pedestrian'] ??
        address['service'] ??
        address['footway'];
    final houseNumber = address['house_number'] ?? address['building'];
    final state = address['state'];
    final pincode = address['postcode'];

    final shortAddress = _buildShortAddress(
      road: road?.toString(),
      houseNumber: houseNumber?.toString(),
      locality: locality?.toString(),
      displayName: displayName,
    );

    return SelectedLocation(
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      address: shortAddress,
      placeId: placeId,
      city: city?.toString(),
      locality: locality?.toString(),
      state: state?.toString(),
      pincode: pincode?.toString(),
      displayName: displayName,
    );
  }

  String _buildShortAddress({
    String? road,
    String? houseNumber,
    String? locality,
    required String displayName,
  }) {
    if (road != null && road.isNotEmpty) {
      final street = houseNumber != null && houseNumber.isNotEmpty
          ? '$houseNumber $road'
          : road;
      return locality != null && locality.isNotEmpty
          ? '$locality, $street'
          : street;
    }
    if (locality != null && locality.isNotEmpty) return locality;

    // Fall back to the first two segments of the full display name.
    final segments = displayName
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (segments.isNotEmpty) {
      return segments.take(2).join(', ');
    }
    return displayName;
  }

  /// A viewbox a few kilometers around the given point so a `bounded`
  /// search returns nearby places first.
  static String _viewBoxAround(LatLng center) {
    const delta = 0.04;
    return '${(center.longitude - delta).toStringAsFixed(5)},'
        '${(center.latitude + delta).toStringAsFixed(5)},'
        '${(center.longitude + delta).toStringAsFixed(5)},'
        '${(center.latitude - delta).toStringAsFixed(5)}';
  }
}

/// Facade used by UI. Keeps HTTP details and provider selection in one place.
class GeocodingService {
  static GeocodingProvider provider = NominatimGeocodingProvider();

  static Future<List<SelectedLocation>> searchPlaces(
    String query, {
    LatLng? near,
  }) {
    return provider.searchPlaces(query, near: near);
  }

  static Future<SelectedLocation?> reverseGeocode(LatLng position) {
    return provider.reverseGeocode(position);
  }
}