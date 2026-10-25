import 'package:flutter/material.dart';

/// Skala tipografi dari `docs/design/desain.md` §5.2.
///
/// SF Pro tidak tersedia di Android; Flutter otomatis jatuh ke font sistem.
/// Hierarki, ukuran, dan weight tetap sama di semua platform.
class AppTypography {
  const AppTypography._();

  static const String displayFamily = 'SF Pro Display';
  static const String textFamily = 'SF Pro Text';

  static const TextStyle display = TextStyle(
    fontFamily: displayFamily,
    fontSize: 36,
    height: 40 / 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.08, // -0.03em
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.9, // -0.03em
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: textFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: textFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontFamily: textFamily,
    fontSize: 15,
    height: 23 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: textFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: textFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: textFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2, // 0.12em
  );
}
