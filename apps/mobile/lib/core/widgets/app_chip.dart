import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Chip kapsul premium. Aktif: oranye lembut, teks navy bold.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    final bgColor = selected ? colors.accentSoft : colors.surface;
    final borderColor = selected ? colors.accent : colors.border;
    final textColor = colors.ink;
    final iconColor = selected ? colors.accentStrong : colors.muted;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: theme.motionFast,
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(
            horizontal: theme.space4,
            vertical: theme.space1,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(theme.radiusChip),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor),
                SizedBox(width: theme.space2),
              ],
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: textColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: theme.space2),
                Icon(trailingIcon, size: 16, color: iconColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
