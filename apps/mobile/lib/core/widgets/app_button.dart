import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text, danger }

/// Tombol premium krem–navy–oranye. Teks pada oranye selalu navy.
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
    final isEnabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(theme.radiusPill);

    Color backgroundColor;
    Color foregroundColor;
    BoxShadow? boxShadow;
    Border? border;

    if (!isEnabled) {
      foregroundColor = colors.muted;
      backgroundColor = colors.surface3;
      border = null;
      boxShadow = null;
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          foregroundColor = colors.ink;
          backgroundColor = colors.accent;
          border = null;
          boxShadow = null;
        case AppButtonVariant.secondary:
          foregroundColor = colors.ink;
          backgroundColor = colors.surface;
          border = Border.all(color: colors.border, width: 1);
          boxShadow = BoxShadow(
            color: colors.border.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          );
        case AppButtonVariant.text:
          foregroundColor = colors.accentStrong;
          backgroundColor = Colors.transparent;
          border = null;
          boxShadow = null;
        case AppButtonVariant.danger:
          foregroundColor = colors.surface;
          backgroundColor = colors.danger;
          border = null;
          boxShadow = null;
      }
    }

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
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: foregroundColor),
        if (isLoading || icon != null) SizedBox(width: theme.space2),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ),
      ],
    );

    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: radius,
      border: border,
      boxShadow: boxShadow != null ? [boxShadow] : null,
    );

    final child = SizedBox(
      height: variant == AppButtonVariant.text ? 44 : 52,
      width: expand ? double.infinity : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: variant == AppButtonVariant.text ? 12 : 20,
        ),
        child: content,
      ),
    );

    if (variant == AppButtonVariant.text) {
      return Semantics(
        button: true,
        enabled: isEnabled,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: child,
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: isEnabled ? onPressed : null, child: child),
        ),
      ),
    );
  }
}
