import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_extension.dart';

/// Progress kapsul: track krem gelap, isi oranye solid.
///
/// Versi dengan label angka, dipakai untuk grafik aktivitas.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.label,
  });

  /// Nilai 0..1. Di luar rentang akan dijepit.
  final double value;
  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme.colors;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: colors.surface3)),
            FractionallySizedBox(
              widthFactor: clamped,
              child: ColoredBox(color: colors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
