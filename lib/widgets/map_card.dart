import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/map_config.dart';
import '../models/worker.dart';
import '../theme/app_theme.dart';
import 'circle_avatar.dart';

/// OpenStreetMap discovery card with worker markers.
///
/// Keeps the previous visual contract (rounded container, zoom/center
/// controls, worker dots, selected-worker card) while rendering real map
/// tiles. Only workers with valid coordinates are placed on the map — workers
/// without coordinates are excluded, never scattered.
class MapCard extends StatefulWidget {
  final List<Worker> workers;
  final Worker? selectedWorker;
  final VoidCallback? onViewProfile;
  final ValueChanged<Worker>? onMarkerTap;

  /// Real great-circle distances (km) keyed by worker id, shown on the
  /// selected-worker card. Only populated when the customer location exists.
  final Map<String, double>? distancesById;

  /// When true a subtle "finding workers" pill is shown while data loads.
  final bool loading;

  /// True when the worker query failed (e.g. RLS/network); shown distinctly
  /// from a genuine "no workers" empty state.
  final bool hasError;

  /// The client's current position, drawn as a distinct marker. When set, the
  /// My Location button also returns here instead of the card center.
  final LatLng? clientLocation;

  /// Horizontal accuracy of [clientLocation] in meters, if known; renders a
  /// subtle accuracy circle around the client marker.
  final double? clientAccuracyMeters;

  /// Optional card center override; defaults to the app demo location.
  final LatLng? center;

  const MapCard({
    super.key,
    required this.workers,
    this.selectedWorker,
    this.onViewProfile,
    this.onMarkerTap,
    this.distancesById,
    this.loading = false,
    this.hasError = false,
    this.clientLocation,
    this.clientAccuracyMeters,
    this.center,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  static const double _height = 220;

  late final MapController _mapController;
  late LatLng _center;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = widget.center ?? MapTileConfig.defaultCenter;
  }

  @override
  void didUpdateWidget(covariant MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requested = widget.center ?? MapTileConfig.defaultCenter;
    final moved =
        requested.latitude != _center.latitude ||
        requested.longitude != _center.longitude;
    if (widget.center != oldWidget.center && moved && _mapReady) {
      // Recenter only when the client explicitly chose a new location.
      _center = requested;
      _mapController.move(requested, MapTileConfig.cardZoom);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Approximate ground distance in meters per screen pixel at the current
  /// camera (used to size the client accuracy circle).
  double _pixelsForMeters(double meters) {
    final camera = _mapController.camera;
    const metersPerPixelAtZoom0 = 156543.03392;
    final latRad = camera.center.latitude * math.pi / 180.0;
    final scale = math.cos(latRad) * math.pow(2.0, camera.zoom);
    if (scale <= 0) return 120.0;
    final metersPerPixel = metersPerPixelAtZoom0 / scale;
    return (meters / metersPerPixel).clamp(24.0, 1200.0).toDouble();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    final client = widget.clientLocation;
    if (client != null) {
      final accuracy = widget.clientAccuracyMeters;
      if (accuracy != null && accuracy > 0) {
        final size =
            _mapReady ? _pixelsForMeters(accuracy) : 120.0;
        markers.add(
          Marker(
            point: client,
            width: size,
            height: size,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x26FF6F61),
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0x4DFF6F61), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      markers.add(
        Marker(
          point: client,
          width: 30,
          height: 30,
          child: const _ClientMarker(),
        ),
      );
    }

    final eligible = widget.workers.where((w) => w.hasCoordinates).toList();
    markers.addAll([
      for (final worker in eligible)
        Marker(
          point: LatLng(worker.latitude!, worker.longitude!),
          width: 36,
          height: 36,
          child: _MapMarker(
            worker: worker,
            selected: worker.id == widget.selectedWorker?.id,
            onTap: () => widget.onMarkerTap?.call(worker),
          ),
        ),
    ]);
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: MapTileConfig.cardZoom,
                minZoom: MapTileConfig.minZoom,
                maxZoom: MapTileConfig.maxZoom,
                onMapReady: () {
                  if (mounted) setState(() => _mapReady = true);
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                MapTileConfig.buildTileLayer(),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () => _zoomBy(1),
                ),
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => _zoomBy(-1),
                ),
                const SizedBox(height: 6),
                _MapButton(icon: Icons.my_location, onTap: _recenter),
              ],
            ),
          ),
          const Positioned(
            left: 8,
            bottom: 8,
            child: _CardAttribution(),
          ),
          // Loading / empty feedback stays subtle so the map stays usable.
          if (widget.loading)
            const Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _StatusPill(
                icon: Icons.hourglass_top,
                label: 'Finding workers…',
              ),
            )
          else if (widget.hasError)
            const Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _StatusPill(
                icon: Icons.cloud_off_outlined,
                label: 'Couldn\'t load workers',
              ),
            )
          else if (widget.workers.isEmpty)
            const Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _StatusPill(
                icon: Icons.person_off_outlined,
                label: 'No available workers nearby',
              ),
            ),
          // Selected worker floating card
          if (widget.selectedWorker != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _SelectedWorkerCard(
                worker: widget.selectedWorker!,
                distanceKm: widget.distancesById?[widget.selectedWorker!.id],
                onViewProfile: widget.onViewProfile,
              ),
            ),
        ],
      ),
    );
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    final camera = _mapController.camera;
    final next = (camera.zoom + delta).clamp(
      MapTileConfig.minZoom,
      MapTileConfig.maxZoom,
    );
    _mapController.move(camera.center, next);
  }

  void _recenter() {
    if (!_mapReady) return;
    final target = widget.clientLocation ?? _center;
    _mapController.move(target, MapTileConfig.cardZoom);
  }
}

/// Distinct client-side marker (white ring + primary dot) so the user's own
/// position never looks like a worker.
class _ClientMarker extends StatelessWidget {
  const _ClientMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 3),
        boxShadow: const [AppShadows.card],
      ),
      child: const Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: SizedBox(width: 10, height: 10),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final Worker worker;
  final bool selected;
  final VoidCallback? onTap;

  const _MapMarker({
    required this.worker,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : worker.color.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Color(0x44000000), blurRadius: 4),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          worker.avatarInitials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _CardAttribution extends StatelessWidget {
  const _CardAttribution();

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

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedWorkerCard extends StatelessWidget {
  final Worker worker;

  /// Real computed distance in km; null when the customer location is unknown.
  final double? distanceKm;
  final VoidCallback? onViewProfile;
  const _SelectedWorkerCard({
    required this.worker,
    this.distanceKm,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (worker.available) 'Available',
      worker.experience,
      if (worker.location.isNotEmpty) worker.location,
      if (worker.cooperative.isNotEmpty) worker.cooperative,
      if (distanceKm != null) '${distanceKm!.toStringAsFixed(1)} km away',
    ];

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatarImage(
              initials: worker.avatarInitials,
              color: worker.color,
              size: 40,
              online: worker.available,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    details.join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onViewProfile,
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
}