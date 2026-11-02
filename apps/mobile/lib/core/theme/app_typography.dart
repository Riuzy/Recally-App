import 'package:flutter/material.dart';

/// Skala tipografi dari `docs/design/desain.md`.
///
/// Satu keluarga font: Inter. Judul 20 tebal, subjudul 16 semibold, isi 14,
/// label 11. Hierarki dibangun dari ukuran dan weight, bukan warna.
class AppTypography {
  const AppTypography._();

  static const String family = 'Inter';

  /// Angka besar dan satu titik fokus per layar.
  static const TextStyle display = TextStyle(
    fontFamily: family,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
}
