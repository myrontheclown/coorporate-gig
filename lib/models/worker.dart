import 'package:flutter/material.dart';

class Worker {
  final String id;
  final String name;
  final String profession;
  final String location;
  final String locality;
  final double rating;
  final int reviews;
  final int jobsCompleted;
  final double distanceKm;
  final double pricePerHour;
  final String avatarInitials;
  final Color color;
  final List<String> skills;
  final String experience;
  final String description;
  final String cooperative;
  final bool verified;
  final bool skillVerified;
  final bool available;
  final bool bestMatch;

  /// Optional geographic coordinates, populated when the worker profile
  /// carries them (used by map markers).
  final double? latitude;
  final double? longitude;

  const Worker({
    required this.id,
    required this.name,
    required this.profession,
    required this.location,
    required this.locality,
    required this.rating,
    required this.reviews,
    this.jobsCompleted = 0,
    this.distanceKm = 0,
    required this.pricePerHour,
    required this.avatarInitials,
    required this.color,
    required this.skills,
    required this.experience,
    required this.description,
    this.cooperative = '',
    this.verified = false,
    this.skillVerified = false,
    this.available = true,
    this.bestMatch = false,
    this.latitude,
    this.longitude,
  });

  String get ratingLabel => rating.toStringAsFixed(1);

  /// True when the worker can be placed on the map.
  bool get hasCoordinates => latitude != null && longitude != null;
}