import 'package:flutter/material.dart';
import '../models/worker.dart';
import 'mock_data.dart';

class MockModels {
  static List<Booking> bookings = [
    Booking(
      id: 'b1',
      workerName: 'Ramesh Kumar',
      profession: 'Plumber',
      status: 'completed',
      date: DateTime(2026, 8, 28),
      timeSlot: '10:00 AM - 1:00 PM',
      address: 'Flat 402, Royal Residency, Grant Road, Mumbai',
      amount: 1050,
      paymentStatus: 'paid',
      avatarInitials: 'RK',
      color: const Color(0xFF0284C7),
    ),
    Booking(
      id: 'b2',
      workerName: 'Sunita Devi',
      profession: 'Housekeeping',
      status: 'completed',
      date: DateTime(2026, 8, 25),
      timeSlot: '9:00 AM - 12:00 PM',
      address: 'Flat 402, Royal Residency, Grant Road, Mumbai',
      amount: 750,
      paymentStatus: 'paid',
      avatarInitials: 'SD',
      color: const Color(0xFF16A34A),
    ),
    Booking(
      id: 'b3',
      workerName: 'Arjun Verma',
      profession: 'Electrician',
      status: 'active',
      date: DateTime(2026, 9, 1),
      timeSlot: '2:00 PM - 4:00 PM',
      address: 'Flat 402, Royal Residency, Grant Road, Mumbai',
      amount: 800,
      paymentStatus: 'pending',
      avatarInitials: 'AV',
      color: const Color(0xFFF59E0B),
    ),
    Booking(
      id: 'b4',
      workerName: 'Mohammed Ali',
      profession: 'Carpenter',
      status: 'pending',
      date: DateTime(2026, 9, 3),
      timeSlot: '11:00 AM - 3:00 PM',
      address: 'Flat 402, Royal Residency, Grant Road, Mumbai',
      amount: 1520,
      paymentStatus: 'pending',
      avatarInitials: 'MA',
      color: const Color(0xFF8B5E3C),
    ),
    Booking(
      id: 'b5',
      workerName: 'Lakshmi Bai',
      profession: 'Home Chef',
      status: 'confirmed',
      date: DateTime(2026, 9, 5),
      timeSlot: '6:00 PM - 9:00 PM',
      address: 'Flat 402, Royal Residency, Grant Road, Mumbai',
      amount: 1500,
      paymentStatus: 'pending',
      avatarInitials: 'LB',
      color: const Color(0xFFD97706),
    ),
  ];

  static List<Booking> get activeBookings =>
      bookings.where((b) => b.status == 'active').toList();

  static List<Booking> get upcomingBookings =>
      bookings
          .where((b) => b.status == 'confirmed' || b.status == 'pending')
          .toList();

  static List<Booking> get completedBookings =>
      bookings.where((b) => b.status == 'completed').toList();

  static List<Worker> get previouslyHiredWorkers {
    final hiredIds = completedBookings.map((b) => b.workerName).toSet();
    return MockData.workers
        .where((w) => hiredIds.contains(w.name))
        .toList();
  }

  static final Map<String, List<Review>> reviewsByWorker = {
    'w1': [
      const Review(
        reviewer: 'Priya M.',
        rating: 5,
        text: 'Excellent plumber! Fixed my leaky bathroom sink quickly and neatly.',
        date: '2 weeks ago',
      ),
      const Review(
        reviewer: 'Amit K.',
        rating: 5,
        text: 'Very professional and punctual. Highly recommended.',
        date: '1 month ago',
      ),
      const Review(
        reviewer: 'Neha S.',
        rating: 4,
        text: 'Good work, arrived 15 minutes late but did a thorough job.',
        date: '2 months ago',
      ),
    ],
    'w3': [
      const Review(
        reviewer: 'Rohan G.',
        rating: 5,
        text: 'Fixed all the electrical issues in my flat. Great troubleshooting.',
        date: '1 week ago',
      ),
      const Review(
        reviewer: 'Sneha P.',
        rating: 4,
        text: 'Knowledgeable and safe. Reasonably priced.',
        date: '3 weeks ago',
      ),
    ],
  };

  static List<Review> reviewsFor(String workerId) {
    return reviewsByWorker[workerId] ?? [];
  }
}

class Booking {
  final String id;
  final String workerName;
  final String profession;
  final String status;
  final DateTime date;
  final String timeSlot;
  final String address;
  final double amount;
  final String paymentStatus;
  final String avatarInitials;
  final Color color;

  const Booking({
    required this.id,
    required this.workerName,
    required this.profession,
    required this.status,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.amount,
    required this.paymentStatus,
    required this.avatarInitials,
    required this.color,
  });

  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String get statusLabel =>
      status[0].toUpperCase() + status.substring(1);
}

class Review {
  final String reviewer;
  final int rating;
  final String text;
  final String date;

  const Review({
    required this.reviewer,
    required this.rating,
    required this.text,
    required this.date,
  });
}

class UserRequest {
  final String id;
  final String service;
  final String status;
  final String date;
  final String description;
  final String workerName;

  const UserRequest({
    required this.id,
    required this.service,
    required this.status,
    required this.date,
    required this.description,
    required this.workerName,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.read = false,
  });
}
