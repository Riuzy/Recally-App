import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Chip sesuai `docs/design/desain.md` §7.4 — radius 10, bukan pill.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final foreground = selected ? colors.accent : colors.inkSoft;

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
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? colors.accentSoft : colors.surface2,
            borderRadius: BorderRadius.circular(theme.radiusChip),
            border: Border.all(color: selected ? colors.accent : colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                SizedBox(width: theme.space1 + 2),
              ],
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
