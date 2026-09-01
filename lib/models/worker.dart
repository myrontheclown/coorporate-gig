import 'package:flutter/material.dart';

class Worker {
  final String id;
  final String name;
  final String profession;
  final String location;
  final String locality;
  final double rating;
  final int reviews;
  final double pricePerHour;
  final String avatarInitials;
  final Color color;
  final List<String> skills;
  final String experience;
  final String description;
  final bool verified;
  final bool available;

  const Worker({
    required this.id,
    required this.name,
    required this.profession,
    required this.location,
    required this.locality,
    required this.rating,
    required this.reviews,
    required this.pricePerHour,
    required this.avatarInitials,
    required this.color,
    required this.skills,
    required this.experience,
    required this.description,
    this.verified = false,
    this.available = true,
  });

  String get ratingLabel => rating.toStringAsFixed(1);
}
