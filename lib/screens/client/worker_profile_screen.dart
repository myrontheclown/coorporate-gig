import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_models.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';
import 'request_service_screen.dart';

class WorkerProfileScreen extends StatelessWidget {
  final Worker worker;
  const WorkerProfileScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final reviews = MockModels.reviewsFor(worker.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          IconButton(icon: Icon(Icons.share_outlined), onPressed: null),
          IconButton(icon: Icon(Icons.favorite_border), onPressed: null),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              children: [
                CircleAvatarImage(
                  initials: worker.avatarInitials,
                  color: worker.color,
                  size: 84,
                  online: worker.available,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      worker.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (worker.verified)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.verified,
                          color: AppColors.accentLight,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  worker.profession,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${worker.ratingLabel} (${worker.reviews} reviews)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        Text(
                          worker.locality,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const StatusBadge(
                  label: 'Background Verified',
                  color: Colors.white,
                  icon: Icons.shield_outlined,
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _Stat(value: worker.experience, label: 'Experience'),
                      _Stat(value: '${worker.reviews}', label: 'Reviews'),
                      _Stat(
                        value: '${worker.pricePerHour.toInt()}',
                        label: '₹/hour',
                      ),
                      _Stat(value: '100%', label: 'On-time'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('About'),
                const SizedBox(height: 8),
                Text(
                  worker.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Skills'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: worker.skills.map((s) {
                    return Chip(
                      label: Text(s),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Reviews & Ratings'),
                const SizedBox(height: 8),
                if (reviews.isEmpty)
                  const Text(
                    'No reviews yet',
                    style: TextStyle(color: AppColors.textMuted),
                  )
                else
                  ...reviews.map((r) => _ReviewCard(review: r)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹350',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '/hour',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AppState.activeWorker = worker;
                    AppState.currentService.value = worker.profession;
                    Nav.push(context, RequestServiceScreen(worker: worker));
                  },
                  child: const Text('Request Service'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, color: AppColors.textMuted, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.reviewer,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      color: i < review.rating
                          ? Colors.amber
                          : AppColors.divider,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              review.date,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
