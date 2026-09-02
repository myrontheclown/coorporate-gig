import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Single source of truth for map tiles and the app's default demo location.
///
/// Swap [urlTemplate] (or build a different [TileLayer]) here when moving to
/// another tile provider. No API keys are hardcoded.
class MapTileConfig {
  /// OpenStreetMap standard raster tile endpoint. No key required.
  static const String urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Used as the application identifier in tile requests (tile usage policy).
  static const String userAgentPackageName = 'com.example.coorporate_gig';

  /// Required attribution for OpenStreetMap tiles.
  static const String attribution = '© OpenStreetMap contributors';

  static const double maxZoom = 19;
  static const double minZoom = 3;

  /// Default demo center used until a real user location is available
  /// (Grant Road, Mumbai — the app's existing demo location).
  static const double defaultLatitude = 18.9600;
  static const double defaultLongitude = 72.8150;
  static const LatLng defaultCenter =
      LatLng(defaultLatitude, defaultLongitude);

  static const double defaultZoom = 15.0;
  static const double pickerZoom = 16.0;
  static const double cardZoom = 13.5;

  /// Shared tile layer backed by the configured provider.
  static TileLayer buildTileLayer() {
    return TileLayer(
      urlTemplate: urlTemplate,
      userAgentPackageName: userAgentPackageName,
      maxZoom: maxZoom,
    );
  }
}