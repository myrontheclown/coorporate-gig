import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A cohesive, professional settings/list item.
///
/// Rows are 56–64px tall with a subtle border between them, an icon,
/// title, optional subtitle/trailing value and a chevron.
class AppSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool showDivider;

  const AppSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.iconColor = AppColors.primary,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Material ensures the ListTile ink splash renders above the
        // card's DecoratedBox background.
        Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: subtitle == null
                ? null
                : Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null)
                  Text(
                    value!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 72, right: 16),
            color: AppColors.divider,
          ),
      ],
    );
  }
}

/// A grouped settings card: a single cohesive rounded container with
/// a subtle border and shadow, wrapping a column of [AppSettingsTile]s.
class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.cardList,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(
          children.length,
          (i) {
            final child = children[i];
            final showDivider = i != children.length - 1;
            if (child is AppSettingsTile) {
              return AppSettingsTile(
                icon: child.icon,
                title: child.title,
                subtitle: child.subtitle,
                value: child.value,
                iconColor: child.iconColor,
                onTap: child.onTap,
                showDivider: child.showDivider && showDivider,
              );
            }
            return child;
          },
        ),
      ),
    );
  }
}

/// Standard settings section heading.
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  const SettingsSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
