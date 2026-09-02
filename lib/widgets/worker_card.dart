import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../theme/app_theme.dart';
import 'circle_avatar.dart';

/// Trust-focused worker card per DESIGN.md.
///
/// Shows photo, name, profession, rating, experience, jobs completed,
/// distance, cooperative affiliation and verification status.
class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback? onTap;

  const WorkerCard({
    super.key,
    required this.worker,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.success,
                                      size: 12,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'VERIFIED',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
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
                            WorkerRating(worker: worker),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                worker.distanceKm > 0
                                    ? '${worker.experience} exp • ${worker.distanceKm.toStringAsFixed(1)} km'
                                    : '${worker.experience} exp',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Meta line: jobs completed + cooperative
              Row(
                children: [
                  Icon(
                    Icons.work_history,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${worker.jobsCompleted} jobs done',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (worker.cooperative.isNotEmpty) ...[
                    const Icon(
                      Icons.account_balance,
                      size: 14,
                      color: AppColors.cooperative,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        worker.cooperative,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.cooperative,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // Badges
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (worker.bestMatch)
                    const _CardBadge(
                      label: 'BEST MATCH',
                      color: AppColors.primary,
                    ),
                  if (worker.available)
                    const _CardBadge(
                      label: 'AVAILABLE',
                      color: AppColors.success,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkerRating extends StatelessWidget {
  final Worker worker;
  const WorkerRating({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: AppColors.rating, size: 14),
        const SizedBox(width: 3),
        Text(
          worker.ratingLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '(${worker.reviews})',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _CardBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CardBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}