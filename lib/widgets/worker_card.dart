import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../theme/app_theme.dart';
import 'circle_avatar.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback? onTap;
  final bool showDistance;

  const WorkerCard({
    super.key,
    required this.worker,
    this.onTap,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatarImage(
                initials: worker.avatarInitials,
                color: worker.color,
                size: 56,
                online: worker.available,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worker.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (worker.verified)
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      worker.profession,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          worker.ratingLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' (${worker.reviews})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.textMuted,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                worker.locality,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '₹${worker.pricePerHour.toInt()}/hr',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          worker.available ? 'Available' : 'Busy',
                          style: TextStyle(
                            fontSize: 11,
                            color: worker.available
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
