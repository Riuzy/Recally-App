import 'package:flutter/material.dart';

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
    canvas: Color(0xFFF7F8FB),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F3F8),
    surface3: Color(0xFFE7EAF2),
    ink: Color(0xFF0E1220),
    inkSoft: Color(0xFF4A5165),
    muted: Color(0xFF7A8296),
    border: Color(0xFFDDE2EC),
    borderStrong: Color(0xFFC3CAD9),
    overlay: Color(0x660E1220), // rgba(14,18,32,0.40)
    glass: Color(0xC7FFFFFF), // rgba(255,255,255,0.78)
    accent: Color(0xFF2F5BD6),
    accentStrong: Color(0xFF2A50C2),
    accent2: Color(0xFF1E9FD4),
    accentPressed: Color(0xFF2444A6),
    accentSoft: Color(0xFFE4EAFC),
    success: Color(0xFF0F8A5F),
    successSoft: Color(0xFFE2F6EC),
    warning: Color(0xFF9A6503),
    warningSoft: Color(0xFFFBF0DA),
    danger: Color(0xFFC93A57),
    dangerSoft: Color(0xFFFCE8EC),
    info: Color(0xFF1E7FA8),
    infoSoft: Color(0xFFE3F2FA),
    gradientPrimary: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2A50C2), Color(0xFF1E7FD8)],
    ),
    glowAccent: BoxShadow(
      color: Color(0x382F5BD6), // rgba(47,91,214,0.22)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    innerHighlight: BoxShadow(
      color: Color(0x99FFFFFF), // rgba(255,255,255,0.60)
      blurRadius: 0,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
    shadowSurface: BoxShadow(
      color: Color(0x0F0E1220), // rgba(14,18,32,0.06)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  );

  static const dark = AppColors(
    canvas: Color(0xFF090A0F),
    surface: Color(0xFF111319),
    surface2: Color(0xFF171A23),
    surface3: Color(0xFF1D2130),
    ink: Color(0xFFF5F7FC),
    inkSoft: Color(0xFFA7AEBD),
    muted: Color(0xFF737B8C),
    border: Color(0xFF262B38),
    borderStrong: Color(0xFF343B4D),
    overlay: Color(0xB8000000), // rgba(0,0,0,0.72)
    glass: Color(0xB8111319), // rgba(17,19,25,0.72)
    accent: Color(0xFF5B8CFF),
    accentStrong: Color(0xFF3F6FE0),
    accent2: Color(0xFF4DD4FF),
    accentPressed: Color(0xFF2F5BD6),
    accentSoft: Color(0xFF17213A),
    success: Color(0xFF3DDC97),
    successSoft: Color(0xFF0F2A22),
    warning: Color(0xFFF5B544),
    warningSoft: Color(0xFF2A2111),
    danger: Color(0xFFFF5C7A),
    dangerSoft: Color(0xFF2A1218),
    info: Color(0xFF7DD3FC),
    infoSoft: Color(0xFF13202A),
    gradientPrimary: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3F6FE0), Color(0xFF2F7FD8)],
    ),
    glowAccent: BoxShadow(
      color: Color(0x475B8CFF), // rgba(91,140,255,0.28)
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
    innerHighlight: BoxShadow(
      color: Color(0x0AFFFFFF), // rgba(255,255,255,0.04)
      blurRadius: 0,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
    shadowSurface: BoxShadow(color: Colors.transparent),
  );
}
