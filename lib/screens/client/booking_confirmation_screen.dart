import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import 'otp_verification_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Worker worker;
  const BookingConfirmationScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final total = worker.pricePerHour * 3;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatarImage(
                      initials: worker.avatarInitials,
                      color: worker.color,
                      size: 52,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${worker.profession} • ${worker.ratingLabel}★',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.edit_calendar,
                      label: 'Date',
                      value: '02 September 2026',
                    ),
                    const SizedBox(height: 20),
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Time Slot',
                      value: '10:00 AM - 1:00 PM',
                    ),
                    const SizedBox(height: 20),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: AppState.selectedLocation.value?.address ??
                          'Flat 402, Royal Residency, Grant Road, Mumbai',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Rate (₹${worker.pricePerHour.toInt()}/hr)',
                      value: '₹${total.toInt()}',
                    ),
                    const SizedBox(height: 8),
                    const _PriceRow(
                      label: 'Service Fee (5%)',
                      value: '₹150',
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: 'Total Payable',
                      value: '₹${(total + 150).toInt()}',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Nav.pop(context),
              child: const Text('Edit Details'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                AppState.currentBookingStatus.value = 'confirmed';
                Nav.push(context, OtpVerificationScreen(worker: worker));
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
