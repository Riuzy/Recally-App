import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Progress sesuai `docs/design/desain.md` §7.5: track 4px, tanpa shimmer.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.height = 4});

  /// Nilai 0..1. Di luar rentang akan dijepit.
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme.colors;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: colors.surface3)),
            FractionallySizedBox(
              widthFactor: clamped,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.accentStrong, colors.accent2],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
