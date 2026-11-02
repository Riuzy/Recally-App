import 'package:flutter/material.dart';

/// Token warna RECALLY versi krem–navy–oranye.
///
/// Palet ini hanya punya satu tema (terang). Oranye adalah warna tindakan;
/// teks di atas oranye selalu navy agar kontras tetap aman.
class AppColors {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.border,
    required this.borderStrong,
    required this.overlay,
    required this.glass,
    required this.accent,
    required this.accentStrong,
    required this.accent2,
    required this.accentPressed,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.gradientPrimary,
    required this.glowAccent,
    required this.innerHighlight,
    required this.shadowSurface,
  });

  final Color canvas;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color border;
  final Color borderStrong;
  final Color overlay;
  final Color glass;
  final Color accent;
  final Color accentStrong;
  final Color accent2;
  final Color accentPressed;
  final Color accentSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Gradient gradientPrimary;
  final BoxShadow glowAccent;
  final BoxShadow innerHighlight;
  final BoxShadow shadowSurface;

  static const light = AppColors(
    canvas: Color(0xFFF4F1EC), // krem
    surface: Color(0xFFFFFFFF), // putih kartu
    surface2: Color(0xFFFAF7F2), // krem sangat muda
    surface3: Color(0xFFEDE7DE), // track dan state nonaktif
    ink: Color(0xFF1B2A41), // navy
    inkSoft: Color(0xFF3F4E61),
    muted: Color(0xFF5C6B7A), // abu-abu biru
    border: Color(0xFFC9CED6),
    borderStrong: Color(0xFFAEB6C2),
    overlay: Color(0x6B1B2A41), // rgba(27,42,65,0.42)
    glass: Color(0xF7FFFDF9),
    accent: Color(0xFFE07A1F), // oranye
    accentStrong: Color(0xFFB85A10), // oranye gelap untuk teks/ikon kecil
    accent2: Color(0xFFE07A1F),
    accentPressed: Color(0xFFC96A16),
    accentSoft: Color(0xFFFBE9D7),
    success: Color(0xFF2F6B4A), // teks hijau tua
    successSoft: Color(0xFFC8EBD7), // latar "Ingat"
    warning: Color(0xFF7A5A00), // teks kuning tua
    warningSoft: Color(0xFFFCE8A6), // latar "Ragu"
    danger: Color(0xFFB3261E), // galat dan aksi hapus
    dangerSoft: Color(0xFFF4C7C3), // latar "Lupa"
    info: Color(0xFF4B6078),
    infoSoft: Color(0xFFE8EDF2),
    gradientPrimary: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE07A1F), Color(0xFFE07A1F)],
    ),
    glowAccent: BoxShadow(color: Colors.transparent),
    innerHighlight: BoxShadow(color: Colors.transparent),
    shadowSurface: BoxShadow(color: Colors.transparent),
  );
}
