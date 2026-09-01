import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small verified trust badge (Aadhaar, Skill, Cooperative).
class VerificationBadge extends StatelessWidget {
  final String label;
  final bool emphasized;

  const VerificationBadge({
    super.key,
    required this.label,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = emphasized ? AppColors.primary : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}