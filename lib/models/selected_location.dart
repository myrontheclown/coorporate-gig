import 'package:latlong2/latlong.dart';

/// A resolved place chosen by the user through the location picker.
///
/// Keeps full coordinate precision and carries an optional address /
/// place identifier (e.g. an OSM place id) so it can be stored in the
/// backend without losing information.
class SelectedLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeId;

  /// City / locality of the resolved address when the provider knows it.
  final String? city;
  final String? locality;

  /// Region / postcode of the resolved address (when the provider knows it).
  final String? state;
  final String? pincode;

  /// Full display name returned by the geocoding provider (if any).
  final String? displayName;

  const SelectedLocation({
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.placeId,
    this.city,
    this.locality,
    this.state,
    this.pincode,
    this.displayName,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  /// Fallback location built purely from coordinates (used when reverse
  /// geocoding is unavailable or fails). The map is always usable even
  /// if no readable address can be resolved.
  factory SelectedLocation.fromCoordinates(
    LatLng point, {
    String? placeId,
  }) {
    return SelectedLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      address:
          '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
      placeId: placeId,
    );
  }

  /// Maps to Supabase-compatible column keys so the selected location can be
  /// persisted with latitude / longitude / address / place_id.
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'place_id': placeId,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  factory SelectedLocation.fromMap(Map<String, dynamic> map) {
    final lat = map['latitude'];
    final lon = map['longitude'];
    return SelectedLocation(
      latitude: lat is num
          ? lat.toDouble()
          : double.tryParse(lat?.toString() ?? '0') ?? 0.0,
      longitude: lon is num
          ? lon.toDouble()
          : double.tryParse(lon?.toString() ?? '0') ?? 0.0,
      address: map['address'] as String? ?? '',
      placeId: map['place_id'] as String?,
      city: map['city'] as String?,
      locality: map['locality'] as String?,
      state: map['state'] as String?,
      pincode: map['pincode'] as String?,
      displayName: map['display_name'] as String?,
    );
  }

  SelectedLocation copyWith({
    String? address,
    String? city,
    String? locality,
    String? state,
    String? pincode,
  }) {
    return SelectedLocation(
      latitude: latitude,
      longitude: longitude,
      address: address ?? this.address,
      placeId: placeId,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      displayName: displayName,
    );
  }
}