import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text, danger }

/// Tombol sesuai `docs/design/desain.md` §7.1.
///
/// Primary memakai gradient dan hanya boleh satu per layar. Text button
/// dipakai untuk aksi ringan seperti "Lihat jawaban" atau "Lewati".
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    final Color foreground;
    final BoxDecoration decoration;
    var shadows = const <BoxShadow>[];

    if (!isEnabled) {
      foreground = colors.muted;
      decoration = BoxDecoration(
        color: colors.surface3,
        borderRadius: BorderRadius.circular(theme.radiusControl),
      );
    } else {
      foreground = switch (variant) {
        AppButtonVariant.primary => Colors.white,
        AppButtonVariant.secondary => colors.ink,
        AppButtonVariant.text => colors.accent,
        AppButtonVariant.danger => isDark ? Colors.white : colors.surface,
      };

      switch (variant) {
        case AppButtonVariant.primary:
          decoration = BoxDecoration(
            gradient: colors.gradientPrimary,
            borderRadius: BorderRadius.circular(theme.radiusControl),
          );
          shadows = [colors.glowAccent];
        case AppButtonVariant.secondary:
          decoration = BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(theme.radiusControl),
            border: Border.all(color: colors.border),
          );
          shadows = [colors.shadowSurface];
        case AppButtonVariant.text:
          decoration = const BoxDecoration(color: Colors.transparent);
        case AppButtonVariant.danger:
          decoration = BoxDecoration(
            color: colors.danger,
            borderRadius: BorderRadius.circular(theme.radiusControl),
          );
      }
    }

    final radius = BorderRadius.circular(theme.radiusControl);
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: foreground),
        if (isLoading || icon != null) SizedBox(width: theme.space2),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: Container(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: decoration,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              child: SizedBox(
                height: variant == AppButtonVariant.text ? 44 : 52,
                width: expand ? double.infinity : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: variant == AppButtonVariant.text ? 8 : 20,
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
