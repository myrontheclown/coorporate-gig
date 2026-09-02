import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:coorporate_gig/models/selected_location.dart';

void main() {
  group('SelectedLocation', () {
    test('preserves full coordinate precision', () {
      const location = SelectedLocation(
        latitude: 18.96251150819438,
        longitude: 72.81750960648832,
        address: 'Grant Road, Mumbai',
      );

      expect(location.latitude, 18.96251150819438);
      expect(location.longitude, 72.81750960648832);
      expect(location.latLng, isA<LatLng>());
      expect(location.latLng.latitude, location.latitude);
      expect(location.latLng.longitude, location.longitude);
    });

    test('fromCoordinates builds a coordinate-only fallback', () {
      final location = SelectedLocation.fromCoordinates(
        const LatLng(18.9600, 72.8150),
      );

      expect(location.latitude, 18.96);
      expect(location.longitude, 72.815);
      expect(location.address, contains('18.960000'));
      expect(location.placeId, isNull);
    });

    test('toMap / fromMap round-trips all persistable fields', () {
      const location = SelectedLocation(
        latitude: 19.136411,
        longitude: 72.829889,
        address: 'Lokhandwala, Andheri West',
        placeId: 'way-123456789',
        city: 'Mumbai',
        locality: 'Andheri West',
        state: 'Maharashtra',
        pincode: '400053',
      );

      final map = location.toMap();
      expect(map['latitude'], 19.136411);
      expect(map['longitude'], 72.829889);
      expect(map['address'], 'Lokhandwala, Andheri West');
      expect(map['place_id'], 'way-123456789');
      expect(map['state'], 'Maharashtra');
      expect(map['pincode'], '400053');

      final restored = SelectedLocation.fromMap(map);
      expect(restored.latitude, location.latitude);
      expect(restored.longitude, location.longitude);
      expect(restored.address, location.address);
      expect(restored.placeId, location.placeId);
      expect(restored.city, 'Mumbai');
      expect(restored.state, 'Maharashtra');
      expect(restored.pincode, '400053');
    });

    test('copyWith overrides address fields without losing coordinates', () {
      const location = SelectedLocation(
        latitude: 18.5,
        longitude: 73.9,
        address: 'Old',
        placeId: 'node-42',
      );

      final updated = location.copyWith(address: 'New address', city: 'Pune');

      expect(updated.latitude, 18.5);
      expect(updated.longitude, 73.9);
      expect(updated.address, 'New address');
      expect(updated.city, 'Pune');
      expect(updated.placeId, 'node-42');
    });
  });
}