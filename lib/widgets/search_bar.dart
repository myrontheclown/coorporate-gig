import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded, light search bar used across screens.
class GigSearchBar extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? trailing;

  const GigSearchBar({
    super.key,
    this.hint = 'Search workers, skills or services',
    this.controller,
    this.onChanged,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: controller == null
                  ? Text(
                      hint,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}