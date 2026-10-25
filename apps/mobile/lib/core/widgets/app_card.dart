import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Kartu sesuai `docs/design/desain.md` §7.3.
///
/// Dark memakai border 1px plus inner highlight tipis; light memakai border
/// dan shadow sangat lembut. Jangan menumpuk kartu di dalam kartu.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(theme.radiusCard);
    final resolvedPadding = padding ?? EdgeInsets.all(theme.space5);

    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: radius,
      border: Border.all(color: colors.border),
      boxShadow: [isDark ? colors.innerHighlight : colors.shadowSurface],
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
