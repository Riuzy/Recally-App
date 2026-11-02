import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.colors,
    required this.radiusCard,
    required this.radiusControl,
    required this.radiusChip,
    required this.radiusPill,
    required this.radiusSheet,
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.space8,
    required this.space10,
    required this.space12,
    required this.motionFast,
    required this.motionScreen,
    required this.motionSlow,
  });

  final AppColors colors;

  /// Kartu 12px.
  final double radiusCard;

  /// Input dan kontrol 12px.
  final double radiusControl;

  /// Chip tetap kapsul agar tidak bersaing dengan tombol utama.
  final double radiusChip;

  /// Tombol utama dan sekunder berbentuk kapsul.
  final double radiusPill;

  /// Bottom sheet.
  final double radiusSheet;

  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;
  final double space6;
  final double space8;
  final double space10;
  final double space12;

  final Duration motionFast;
  final Duration motionScreen;
  final Duration motionSlow;

  static const light = AppThemeExtension(
    colors: AppColors.light,
    radiusCard: 12,
    radiusControl: 12,
    radiusChip: 999,
    radiusPill: 999,
    radiusSheet: 24,
    space1: 4,
    space2: 8,
    space3: 12,
    space4: 16,
    space5: 20,
    space6: 24,
    space8: 32,
    space10: 40,
    space12: 48,
    motionFast: Duration(milliseconds: 180),
    motionScreen: Duration(milliseconds: 200),
    motionSlow: Duration(milliseconds: 240),
  );

  @override
  AppThemeExtension copyWith({
    AppColors? colors,
    double? radiusCard,
    double? radiusControl,
    double? radiusChip,
    double? radiusPill,
    double? radiusSheet,
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? space8,
    double? space10,
    double? space12,
    Duration? motionFast,
    Duration? motionScreen,
    Duration? motionSlow,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusControl: radiusControl ?? this.radiusControl,
      radiusChip: radiusChip ?? this.radiusChip,
      radiusPill: radiusPill ?? this.radiusPill,
      radiusSheet: radiusSheet ?? this.radiusSheet,
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      space8: space8 ?? this.space8,
      space10: space10 ?? this.space10,
      space12: space12 ?? this.space12,
      motionFast: motionFast ?? this.motionFast,
      motionScreen: motionScreen ?? this.motionScreen,
      motionSlow: motionSlow ?? this.motionSlow,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      colors: t < 0.5 ? colors : other.colors,
      radiusCard: radiusCard,
      radiusControl: radiusControl,
      radiusChip: radiusChip,
      radiusPill: radiusPill,
      radiusSheet: radiusSheet,
      space1: space1,
      space2: space2,
      space3: space3,
      space4: space4,
      space5: space5,
      space6: space6,
      space8: space8,
      space10: space10,
      space12: space12,
      motionFast: motionFast,
      motionScreen: motionScreen,
      motionSlow: motionSlow,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
  AppColors get colors => appTheme.colors;
}
