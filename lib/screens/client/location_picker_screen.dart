import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../config/map_config.dart';
import '../../models/selected_location.dart';
import '../../services/geocoding_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/timer_debouncer.dart';
import '../../widgets/location_picker_map.dart';
import '../../widgets/search_bar.dart';

/// Uber/Swiggy-style location picker built on OpenStreetMap.
///
/// Returns a [SelectedLocation] via `Navigator.pop` when the user confirms.
/// The map remains fully usable even if GPS permission or geocoding fails.
class LocationPickerScreen extends StatefulWidget {
  /// Optional starting location (e.g. previously chosen for this request).
  final SelectedLocation? initialLocation;

  /// Camera position override (defaults to the app's demo location).
  final LatLng? initialCenter;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialCenter,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const Duration _searchDebounce = Duration(milliseconds: 400);
  static const Duration _reverseDebounce = Duration(milliseconds: 550);

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  final TimerDebouncer _searchDebouncer = TimerDebouncer(duration: _searchDebounce);
  final TimerDebouncer _reverseDebouncer = TimerDebouncer(duration: _reverseDebounce);

  SelectedLocation? _selected;
  bool _mapReady = false;

  // Reverse geocoding state
  bool _reversing = false;
  bool _reverseFailed = false;
  int _reverseSeq = 0;

  // Search state
  bool _searching = false;
  String? _searchError;
  List<SelectedLocation>? _searchResults;
  int _searchSeq = 0;

  LatLng get _initialCenter =>
      widget.initialCenter ??
      (widget.initialLocation != null
          ? widget.initialLocation!.latLng
          : MapTileConfig.defaultCenter);

  double get _initialZoom =>
      widget.initialLocation != null ? MapTileConfig.pickerZoom : MapTileConfig.defaultZoom;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _reverseDebouncer.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Reverse geocoding (map moves -> resolved address)
  // ---------------------------------------------------------------------------

  void _onCenterChanged(LatLng center) {
    _reverseDebouncer.run(() => _reverseGeocode(center));
  }

  Future<void> _reverseGeocode(LatLng center) async {
    final seq = ++_reverseSeq;
    if (mounted) {
      setState(() {
        _reversing = true;
        _reverseFailed = false;
      });
    }

    try {
      final location = await GeocodingService.reverseGeocode(center);
      if (!mounted || seq != _reverseSeq) return;
      setState(() {
        _selected = location ?? SelectedLocation.fromCoordinates(center);
        _reversing = false;
      });
    } catch (_) {
      if (!mounted || seq != _reverseSeq) return;
      setState(() {
        _selected = SelectedLocation.fromCoordinates(center);
        _reversing = false;
        _reverseFailed = true;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Search / forward geocoding
  // ---------------------------------------------------------------------------

  void _onSearchChanged(String text) {
    final query = text.trim();
    if (query.isEmpty) {
      _searchSeq++;
      _searchDebouncer.cancel();
      setState(() {
        _searching = false;
        _searchError = null;
        _searchResults = null;
      });
      return;
    }

    _searchDebouncer.run(() => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    final seq = ++_searchSeq;
    if (mounted) {
      setState(() {
        _searching = true;
        _searchError = null;
      });
    }

    try {
      final center =
          _mapReady ? _mapController.camera.center : _initialCenter;
      final results = await GeocodingService.searchPlaces(query, near: center);
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searching = false;
        _searchResults = results;
      });
    } catch (e) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searching = false;
        _searchResults = null;
        _searchError = e is GeocodingException
            ? e.message
            : "Couldn't search for that address. Please try again.";
      });
    }
  }

  void _onSearchResultSelected(SelectedLocation location) {
    FocusScope.of(context).unfocus();
    _searchSeq++;
    _searchDebouncer.cancel();
    setState(() {
      _searchResults = null;
      _searchError = null;
      _selected = location;
      _reverseFailed = false;
    });
    // Invalidate any in-flight reverse geocode; we already have a full place.
    _reverseSeq++;
    _mapController.move(location.latLng, MapTileConfig.pickerZoom);
  }

  // ---------------------------------------------------------------------------
  // Current location / permission failures
  // ---------------------------------------------------------------------------

  void _onLocateFailed(LocationAccessStatus status) {
    if (!mounted) return;
    final message = LocationService.describeFailure(status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: status == LocationAccessStatus.permanentlyDenied
            ? SnackBarAction(
                label: 'Settings',
                textColor: AppColors.primaryLight,
                onPressed: () => LocationService.openAppSettings(),
              )
            : null,
      ),
    );
  }

  void _confirm() {
    final location = _selected ??
        SelectedLocation.fromCoordinates(
          _mapReady
              ? _mapController.camera.center
              : _initialCenter,
        );
    Navigator.pop(context, location);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GigSearchBar(
                hint: 'Search for an address or place',
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),
            if (_searchResults != null ||
                _searchError != null ||
                _searching)
              _SearchResultsPanel(
                searching: _searching,
                error: _searchError,
                results: _searchResults,
                onSelected: _onSearchResultSelected,
              ),
            Expanded(
              child: LocationPickerMap(
                initialCenter: _initialCenter,
                initialZoom: _initialZoom,
                mapController: _mapController,
                onCenterChanged: _onCenterChanged,
                onMapReady: () {
                  if (mounted) setState(() => _mapReady = true);
                  _mapReadyCheck();
                },
                onLocateFailed: _onLocateFailed,
              ),
            ),
            _SelectedLocationCard(
              selected: _selected,
              reversing: _reversing,
              reverseFailed: _reverseFailed,
              onConfirm: _mapReady ? _confirm : null,
            ),
          ],
        ),
      ),
    );
  }

  void _mapReadyCheck() {
    if (_selected == null) {
      _reverseGeocode(_initialCenter);
    }
  }
}

class _SearchResultsPanel extends StatelessWidget {
  final bool searching;
  final String? error;
  final List<SelectedLocation>? results;
  final ValueChanged<SelectedLocation> onSelected;

  const _SearchResultsPanel({
    required this.searching,
    required this.error,
    required this.results,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 260),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.elevatedList,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (searching) {
      return const _SearchMessageRow(
        icon: Icons.search,
        title: 'Searching places…',
        loading: true,
      );
    }

    if (error != null) {
      return _SearchMessageRow(
        icon: Icons.cloud_off_outlined,
        title: error!,
      );
    }

    final list = results ?? const [];
    if (list.isEmpty) {
      return const _SearchMessageRow(
        icon: Icons.search_off,
        title: 'No places found. Try a different search.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: list.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Divider(height: 1),
      ),
      itemBuilder: (context, index) {
        final place = list[index];
        final title = place.displayName ?? place.address;
        return ListTile(
          dense: true,
          leading: const Icon(
            Icons.place_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
          onTap: () => onSelected(place),
        );
      },
    );
  }
}

class _SearchMessageRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool loading;

  const _SearchMessageRow({
    required this.icon,
    required this.title,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Icon(icon, color: AppColors.textMuted, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary,
          ),
        ],
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  final SelectedLocation? selected;
  final bool reversing;
  final bool reverseFailed;
  final VoidCallback? onConfirm;

  const _SelectedLocationCard({
    required this.selected,
    required this.reversing,
    required this.reverseFailed,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [AppShadows.upward],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _addressBlock()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Confirm Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressBlock() {
    if (reversing) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Resolving address…', style: AppTextStyles.secondary),
        ],
      );
    }

    final loc = selected;
    if (loc == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Move the map to pick a location, or tap the pin to locate yourself.',
          style: AppTextStyles.body,
        ),
      );
    }

    final city = loc.city ?? loc.locality;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.cardTitle,
        ),
        const SizedBox(height: 2),
        Text(
          city != null && city.isNotEmpty
              ? city
              : '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
          style: AppTextStyles.muted,
        ),
        if (reverseFailed) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 13, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Couldn't load the address. Check your connection.",
                  style: AppTextStyles.muted,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}