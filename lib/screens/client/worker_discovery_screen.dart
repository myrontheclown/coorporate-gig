import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../config/map_config.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/worker.dart';
import '../../models/worker_profile.dart';
import '../../navigation/nav.dart';
import '../../services/client_location_service.dart';
import '../../services/worker_location_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/location_utils.dart';
import '../../widgets/map_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_chip.dart';
import '../../widgets/worker_card.dart';
import 'location_picker_screen.dart';
import 'notification_screen.dart';
import 'search_results_screen.dart';
import 'worker_profile_screen.dart';

class WorkerDiscoveryScreen extends StatefulWidget {
  const WorkerDiscoveryScreen({super.key});

  @override
  State<WorkerDiscoveryScreen> createState() => _WorkerDiscoveryScreenState();
}

class _WorkerDiscoveryScreenState extends State<WorkerDiscoveryScreen> {
  String _selectedService = 'All';
  Worker? _selectedMapWorker;
  List<WorkerProfile> _supabaseProfiles = [];
  List<Worker> _mapWorkers = [];
  Map<String, double>? _mapDistances;

  /// Client position resolved at startup: fresh GPS -> saved user_profile
  /// coordinates -> null (map falls back to the demo center). Only used for
  /// the map center, the client marker and distance labels — it never filters
  /// which workers are fetched.
  LatLng? _clientLocation;
  double? _clientAccuracy;
  bool _loadingMap = true;
  bool _mapLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
    _resolveClientLocation();
  }

  /// List workers keep real distances when the client location is known.
  /// Unknown distance is represented as 0 and hidden by [WorkerCard].
  List<Worker> get _supabaseWorkers {
    final customer = _clientLocation;
    return [
      for (final p in _supabaseProfiles)
        p.toWorker(
          distanceKm:
              customer != null && p.latitude != null && p.longitude != null
                  ? geoDistanceKm(
                      customer,
                      LatLng(p.latitude!, p.longitude!),
                    )
                  : 0,
        ),
    ];
  }

  Future<void> _loadWorkers() async {
    try {
      // Usable by every module: verified + available real workers from
      // public.worker_profile (names joined from public.user_profile).
      final load = await WorkerProfileService.loadWorkers(
        availabilityStatus: 'available',
        verificationStatus: 'verified',
      );
      if (mounted) {
        setState(() {
          _supabaseProfiles =
              load.workers.isNotEmpty ? load.workers : _supabaseProfiles;
        });
      }
    } catch (_) {
      // Fallback seamlessly
    }

    // Real map markers: verified + available workers with valid coordinates.
    // The customer location is only used for the map center and distance
    // labels here — it never filters which workers are fetched.
    try {
      final load = await WorkerLocationService.getMapWorkers();
      if (!mounted) return;
      setState(() {
        final markers = load.workers.map((p) => p.toWorker()).toList();
        _mapWorkers = markers;
        _mapDistances = _distancesFor(markers);
        _mapLoadFailed = load.failed;
        _loadingMap = false;
        if (kDebugMode) {
          final withCoords = markers.where((w) => w.hasCoordinates).length;
          print(
            '📍 [WorkerDiscovery] Markers created: ${markers.length} '
            '(with coordinates: $withCoords)',
          );
          for (final w in markers) {
            print(
              '   Marker: id=${w.id} name=${w.name} '
              'lat=${w.latitude} lng=${w.longitude}',
            );
          }
        }
      });
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          _mapWorkers = [];
          _mapDistances = null;
          _mapLoadFailed = true;
          _loadingMap = false;
        });
      }
      if (kDebugMode) {
        print('⚠️ [WorkerDiscovery] Map worker load failed: $e\n$stack');
      }
    }
  }

  Future<void> _resolveClientLocation() async {
    final fix = await ClientLocationService.resolveInitialLocation();
    if (!mounted) return;
    setState(() {
      _clientLocation = fix?.position;
      _clientAccuracy = fix?.accuracyMeters;
      _mapDistances = _distancesFor(_mapWorkers);
    });
    if (kDebugMode) {
      print(
        '📍 [WorkerDiscovery] Client location resolved: '
        '${fix?.position ?? 'none (using fallback center)'}',
      );
    }
  }

  Map<String, double>? _distancesFor(List<Worker> workers) {
    final customer = _clientLocation;
    if (customer == null) return null;
    return {
      for (final w in workers)
        if (w.hasCoordinates)
          w.id: geoDistanceKm(
            customer,
            LatLng(w.latitude!, w.longitude!),
          ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final allWorkers = _supabaseWorkers.isNotEmpty
        ? _supabaseWorkers
        : MockData.workersByRating;

    final filtered = _selectedService == 'All'
        ? allWorkers
        : allWorkers
            .where((w) => w.profession
                .toLowerCase()
                .contains(_selectedService.toLowerCase()))
            .toList();

    final nearby = filtered.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            _HomeHeader(
              onNotifications: () {
                Nav.push(context, const NotificationListScreen());
              },
              onLocationTap: _openLocationPicker,
            ),
            const SizedBox(height: 20),
            // Greeting
            ValueListenableBuilder(
              valueListenable: AppState.currentUserProfile,
              builder: (context, profile, _) {
                final name = profile?.fullName.isNotEmpty == true
                    ? profile!.fullName
                    : 'Rahul';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening, $name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find trusted professionals near you.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Search
            GigSearchBar(
              onTap: () => Nav.push(context, const SearchResultsScreen()),
              trailing: const Icon(
                Icons.tune,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            // Service chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MockData.services.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return ServiceChip(
                      label: 'All',
                      selected: _selectedService == 'All',
                      onTap: () => setState(() => _selectedService = 'All'),
                    );
                  }
                  final s = MockData.services[i - 1];
                  return ServiceChip(
                    label: s.name,
                    icon: _iconFor(s.icon),
                    selected: _selectedService == s.name,
                    onTap: () => setState(() => _selectedService = s.name),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Map section
            MapCard(
              workers: _mapWorkers,
              distancesById: _mapDistances,
              loading: _loadingMap,
              hasError: _mapLoadFailed,
              center: _clientLocation ??
                  AppState.selectedLocation.value?.latLng ??
                  MapTileConfig.defaultCenter,
              clientLocation: _clientLocation,
              clientAccuracyMeters: _clientAccuracy,
              selectedWorker: _selectedMapWorker,
              onMarkerTap: (w) => setState(() => _selectedMapWorker = w),
              onViewProfile: _selectedMapWorker == null
                  ? null
                  : () {
                      AppState.activeWorker = _selectedMapWorker;
                      Nav.push(
                        context,
                        WorkerProfileScreen(worker: _selectedMapWorker!),
                      );
                    },
            ),
            const SizedBox(height: 20),
            // Available near you
            SectionHeader(
              title: 'Available near you',
              actionLabel: 'See All',
              onAction: () => Nav.push(context, const SearchResultsScreen()),
            ),
            const SizedBox(height: 4),
            for (final w in nearby)
              WorkerCard(
                worker: w,
                onTap: () {
                  AppState.activeWorker = w;
                  Nav.push(context, WorkerProfileScreen(worker: w));
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'plumbing':
        return Icons.plumbing;
      case 'bolt':
        return Icons.bolt;
      case 'construction':
        return Icons.construction;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'format_paint':
        return Icons.format_paint;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'eco':
        return Icons.eco;
      case 'restaurant':
        return Icons.restaurant;
      case 'security':
        return Icons.security;
      default:
        return Icons.build;
    }
  }

  Future<void> _openLocationPicker() async {
    final location = await Nav.pushForResult(
      context,
      LocationPickerScreen(initialLocation: AppState.selectedLocation.value),
    );
    if (location != null && mounted) {
      setState(() => AppState.selectedLocation.value = location);
    }
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onLocationTap;
  const _HomeHeader({
    required this.onNotifications,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 2),
                ValueListenableBuilder(
                  valueListenable: AppState.selectedLocation,
                  builder: (context, selected, _) {
                    if (selected != null) {
                      final locText = selected.city != null &&
                              selected.city!.isNotEmpty
                          ? '${selected.city}${selected.locality != null && selected.locality!.isNotEmpty ? ", ${selected.locality}" : ""}'
                          : (selected.locality?.isNotEmpty == true
                              ? selected.locality!
                              : selected.address);
                      return Text(
                        locText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      );
                    }
                    return ValueListenableBuilder(
                      valueListenable: AppState.currentUserProfile,
                      builder: (context, profile, _) {
                        final loc = profile?.city.isNotEmpty == true
                            ? '${profile!.address.isNotEmpty ? "${profile.address}, " : ""}${profile.city}'
                            : 'Grant Road, Mumbai';
                        return Text(
                          loc,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          icon: const Badge(
            label: Text('2'),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}