import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Kartu premium: putih, garis tipis 12px, spacing aman.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final radius = BorderRadius.circular(theme.radiusCard);
    final resolvedPadding = padding ?? EdgeInsets.all(theme.space5);

    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: radius,
      border: Border.all(color: colors.border, width: 1),
    );

    if (onTap == null) {
      return Container(
        decoration: decoration,
        padding: resolvedPadding,
        child: child,
      );
    }

    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}
