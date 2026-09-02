import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/map_config.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

/// Interactive OpenStreetMap used by the location picker.
///
/// Owns the map, the floating current-location button and the center pin.
/// Emits camera center changes via [onCenterChanged] (debounced upstream) and
/// never throws when location permissions are unavailable.
class LocationPickerMap extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final bool enableRotation;

  /// Optional external controller so the parent can move the camera.
  final MapController? mapController;

  /// Called whenever the map center changes (gesture driven).
  final ValueChanged<LatLng> onCenterChanged;
  final VoidCallback? onMapReady;

  /// Called when the current-location button fails (permission denied,
  /// services disabled, etc.). The map stays fully usable.
  final ValueChanged<LocationAccessStatus>? onLocateFailed;

  const LocationPickerMap({
    super.key,
    required this.initialCenter,
    this.initialZoom = MapTileConfig.pickerZoom,
    this.enableRotation = true,
    this.mapController,
    required this.onCenterChanged,
    this.onMapReady,
    this.onLocateFailed,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  static const Color _mapBackground = Color(0xFFE8EDF2);

  late final MapController _mapController;
  bool _mapReady = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  @override
  void dispose() {
    if (widget.mapController == null) {
      _mapController.dispose();
    }
    super.dispose();
  }

  void _onMapReady() {
    if (mounted) {
      setState(() => _mapReady = true);
    }
    widget.onMapReady?.call();
  }

  Future<void> _locate() async {
    if (_locating) return;
    setState(() => _locating = true);

    final result = await LocationService.getCurrentPosition();

    if (!mounted) return;
    setState(() => _locating = false);

    if (result.ok) {
      final currentZoom =
          _mapReady && _mapController.camera.zoom >= widget.initialZoom
              ? _mapController.camera.zoom
              : widget.initialZoom;
      _mapController.move(result.position!, currentZoom);
    } else {
      widget.onLocateFailed?.call(result.status);
    }
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    widget.onCenterChanged(camera.center);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _mapBackground,
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: widget.initialZoom,
                minZoom: MapTileConfig.minZoom,
                maxZoom: MapTileConfig.maxZoom,
                onMapReady: _onMapReady,
                onPositionChanged: _onPositionChanged,
                interactionOptions: InteractionOptions(
                  flags: widget.enableRotation
                      ? InteractiveFlag.all
                      : InteractiveFlag.all &
                          ~InteractiveFlag.rotate,
                ),
              ),
              children: [MapTileConfig.buildTileLayer()],
            ),
          ),
          if (!_mapReady)
            const Positioned.fill(
              child: ColoredBox(
                color: _mapBackground,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const Positioned(
            left: 8,
            bottom: 8,
            child: IgnorePointer(
              child: _AttributionLabel(),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(child: _CenterPin()),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _LocateButton(
              loading: _locating,
              onPressed: _locating ? null : _locate,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anchor dot exactly at the map center.
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [AppShadows.card],
            ),
          ),
          // Pin raised above the center so its tip hovers on the map.
          Transform.translate(
            offset: const Offset(0, -34),
            child: const Icon(
              Icons.location_on,
              size: 44,
              color: AppColors.primary,
              shadows: [
                Shadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocateButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const _LocateButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.my_location, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _AttributionLabel extends StatelessWidget {
  const _AttributionLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        MapTileConfig.attribution,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
      ),
    );
  }
}