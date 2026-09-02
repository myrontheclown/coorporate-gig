import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Compact star rating display.
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? count;
  final double starSize;
  final double textSize;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.count,
    this.starSize = 14,
    this.textSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: AppColors.rating, size: 14),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: textSize,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}