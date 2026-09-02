import 'package:latlong2/latlong.dart';

/// Great-circle distance between two coordinates in kilometres.
///
/// Uses the high-precision (Vincenty) calculator from latlong2 — the same
/// dependency that backs the map itself — with rounding disabled so small
/// neighbourhood distances keep their decimal precision.
const Distance _distance = Distance(roundResult: false);

double geoDistanceKm(LatLng from, LatLng to) {
  return _distance.as(LengthUnit.Kilometer, from, to);
}