import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:coorporate_gig/services/client_location_service.dart';

void main() {
  group('ClientLocationService.shouldPersist', () {
    final base = DateTime(2026, 9, 2, 12, 0, 0);
    const here = LatLng(18.9600, 72.8150);

    test('persists when nothing has been synced yet', () {
      expect(
        ClientLocationService.shouldPersist(
          lastPosition: null,
          lastTime: null,
          current: here,
          now: base,
        ),
        isTrue,
      );
    });

    test('persists when the interval elapsed even without movement', () {
      expect(
        ClientLocationService.shouldPersist(
          lastPosition: here,
          lastTime: base.subtract(const Duration(minutes: 11)),
          current: here,
          now: base,
        ),
        isTrue,
      );
    });

    test('does not persist for tiny movement within the interval', () {
      // 20 m away << 150 m threshold, well inside the 10-minute window.
      const nearby = LatLng(18.96017, 72.8150);
      expect(
        ClientLocationService.shouldPersist(
          lastPosition: here,
          lastTime: base.subtract(const Duration(minutes: 2)),
          current: nearby,
          now: base,
        ),
        isFalse,
      );
    });

    test('persists for meaningful movement within the interval', () {
      // ~2.22 km away >= 150 m threshold, even though only 2 minutes elapsed.
      const farAway = LatLng(18.9800, 72.8150);
      expect(
        ClientLocationService.shouldPersist(
          lastPosition: here,
          lastTime: base.subtract(const Duration(minutes: 2)),
          current: farAway,
          now: base,
        ),
        isTrue,
      );
    });

    test('does not suppress a large movement right after a sync', () {
      const farAway = LatLng(19.0, 72.9);
      expect(
        ClientLocationService.shouldPersist(
          lastPosition: here,
          lastTime: base.subtract(const Duration(seconds: 30)),
          current: farAway,
          now: base,
        ),
        isTrue,
      );
    });
  });
}