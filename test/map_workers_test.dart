import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:coorporate_gig/models/worker.dart';
import 'package:coorporate_gig/models/worker_profile.dart';
import 'package:coorporate_gig/utils/location_utils.dart';

void main() {
  group('geoDistanceKm', () {
    test('returns zero for the same point', () {
      final point = const LatLng(18.9600, 72.8150);
      expect(geoDistanceKm(point, point), closeTo(0, 0.0001));
    });

    test('computes a real great-circle distance', () {
      // Mumbai -> Delhi is roughly 1140-1160 km by air.
      const mumbai = LatLng(19.0760, 72.8777);
      const delhi = LatLng(28.6139, 77.2090);
      expect(geoDistanceKm(mumbai, delhi), closeTo(1149, 20));
    });

    test('sanity: 0.01 degrees of latitude is about 1.11 km', () {
      const a = LatLng(18.9600, 72.8150);
      const b = LatLng(18.9700, 72.8150);
      expect(geoDistanceKm(a, b), closeTo(1.112, 0.05));
    });
  });

  group('Worker.hasCoordinates', () {
    test('is true only when both latitude and longitude are present', () {
      const withCoords = Worker(
        id: 'w1',
        name: 'A',
        profession: 'P',
        location: 'Mumbai',
        locality: 'Grant Road',
        rating: 4.5,
        reviews: 10,
        pricePerHour: 300,
        avatarInitials: 'A',
        color: Colors.blue,
        skills: ['General'],
        experience: '5 years',
        description: 'D',
        latitude: 18.96,
        longitude: 72.815,
      );
      const noCoords = Worker(
        id: 'w2',
        name: 'B',
        profession: 'P',
        location: 'Mumbai',
        locality: 'Grant Road',
        rating: 4.5,
        reviews: 10,
        pricePerHour: 300,
        avatarInitials: 'B',
        color: Colors.blue,
        skills: ['General'],
        experience: '3 years',
        description: 'D',
      );

      expect(withCoords.hasCoordinates, isTrue);
      expect(noCoords.hasCoordinates, isFalse);
    });
  });

  group('WorkerProfile map integration', () {
    test('parses joined user and cooperative profiles from Supabase JSON', () {
      final profile = WorkerProfile.fromJson({
        'id': 'wp-1',
        'user_id': 'u-1',
        'cooperative_id': 'c-1',
        'worker_code': 'MUM-001',
        'experience_years': 8,
        'address': '14 Marine Lines',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400020',
        'latitude': 18.9640,
        'longitude': 72.8220,
        'verification_status': 'verified',
        'availability_status': 'available',
        'user_profile': {
          'id': 'u-1',
          'full_name': 'Sunita Sharma',
          'profile_image': 'sunita.jpg',
        },
        'cooperative_profile': {
          'id': 'c-1',
          'name': 'Mumbai Workers Cooperative',
          'logo_url': 'coop.png',
        },
      });

      expect(profile.latitude, 18.9640);
      expect(profile.longitude, 72.8220);
      expect(profile.verificationStatus, 'verified');
      expect(profile.availabilityStatus, 'available');
      expect(profile.userProfile?.fullName, 'Sunita Sharma');
      expect(profile.userProfile?.profileImage, 'sunita.jpg');
      expect(profile.cooperativeProfile?.name, 'Mumbai Workers Cooperative');
      expect(profile.cooperativeProfile?.logoUrl, 'coop.png');
    });

    test('toWorker carries coordinates and real profile fields', () {
      final profile = WorkerProfile.fromJson({
        'id': 'wp-1',
        'user_id': 'u-1',
        'worker_code': 'MUM-001',
        'experience_years': 8,
        'address': '14 Marine Lines',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400020',
        'latitude': 18.9640,
        'longitude': 72.8120,
        'verification_status': 'verified',
        'availability_status': 'available',
        'user_profile': {
          'id': 'u-1',
          'full_name': 'Sunita Sharma',
          'profile_image': 'sunita.jpg',
        },
        'cooperative_profile': {
          'id': 'c-1',
          'name': 'Mumbai Workers Cooperative',
          'logo_url': 'coop.png',
        },
      });

      final worker = profile.toWorker();
      expect(worker.latitude, 18.9640);
      expect(worker.longitude, 72.8120);
      expect(worker.hasCoordinates, isTrue);
      expect(worker.name, 'Sunita Sharma');
      expect(worker.cooperative, 'Mumbai Workers Cooperative');
      expect(worker.verified, isTrue);
      expect(worker.available, isTrue);
      expect(worker.experience, '8 years');
      expect(worker.location, 'Mumbai');
    });

    test('workers missing coordinates are excluded from map via hasCoordinates', () {
      final profile = WorkerProfile.fromJson({
        'id': 'wp-2',
        'user_id': 'u-2',
        'verification_status': 'verified',
        'availability_status': 'available',
        'latitude': null,
        'longitude': null,
      });
      expect(profile.toWorker().hasCoordinates, isFalse);
    });

    test('toWorker accepts an explicit distanceKm override', () {
      final profile = WorkerProfile.fromJson({
        'id': 'wp-3',
        'user_id': 'u-3',
        'verification_status': 'verified',
        'availability_status': 'available',
        'latitude': 18.9640,
        'longitude': 72.8120,
      });

      final real = profile.toWorker(distanceKm: 42.7);
      expect(real.distanceKm, 42.7);

      final unknown = profile.toWorker(distanceKm: 0);
      expect(unknown.distanceKm, 0);

      final defaulted = profile.toWorker();
      expect(defaulted.distanceKm, 1.5);
    });
  });

  group('Goa marker pipeline (production coordinates)', () {
    const goaWorkers = [
      (15.6018, 73.8132),
      (15.6068, 73.7939),
      (15.5948, 73.8171),
      (15.6002, 73.8125),
    ];

    test('fromJson preserves exact precision and toWorker keeps coordinates', () {
      for (var i = 0; i < goaWorkers.length; i++) {
        final (lat, lng) = goaWorkers[i];
        final profile = WorkerProfile.fromJson({
          'id': 'goa-$i',
          'user_id': 'u-$i',
          'verification_status': 'verified',
          'availability_status': 'available',
          'latitude': lat,
          'longitude': lng,
        });
        expect(profile.latitude, lat);
        expect(profile.longitude, lng);

        final worker = profile.toWorker();
        expect(worker.hasCoordinates, isTrue);
        expect(worker.latitude, lat);
        expect(worker.longitude, lng);
      }
    });

    test('missing user_profile name never drops a coordinate-valid worker', () {
      // worker_profile carries NO full_name. If the user_profile lookup fails
      // (or returns nothing), the worker must STILL become a map marker using
      // worker_profile.latitude/longitude, with a safe fallback label.
      const profile = WorkerProfile(
        id: 'goa-no-name',
        userId: 'some-user-id',
        workerCode: 'GOA-009',
        experienceYears: 3,
        verificationStatus: 'verified',
        availabilityStatus: 'available',
        latitude: 15.6018,
        longitude: 73.8132,
        userProfile: null,
      );

      final worker = profile.toWorker();
      expect(worker.hasCoordinates, isTrue);
      expect(worker.latitude, 15.6018);
      expect(worker.longitude, 73.8132);
      expect(worker.name, 'Worker GOA-009');
    });

    test('all four Goa workers survive the map marker filter', () {
      final markers = [
        for (var i = 0; i < goaWorkers.length; i++)
          WorkerProfile.fromJson({
            'id': 'goa-$i',
            'user_id': 'u-$i',
            'verification_status': 'verified',
            'availability_status': 'available',
            'latitude': goaWorkers[i].$1,
            'longitude': goaWorkers[i].$2,
          }).toWorker(),
      ].where((w) => w.hasCoordinates).toList();

      // Mirrors MapCard._buildMarkers: every marker uses the real coordinates.
      expect(markers.length, 4);
      expect(markers.map((w) => (w.latitude!, w.longitude!)),
          containsAll(goaWorkers));
    });
  });
}
