import 'package:flutter/material.dart';

import 'app_theme_extension.dart';
import 'app_typography.dart';

/// Tema RECALLY: krem, navy, dan oranye. Hanya satu tema (terang).
class AppTheme {
  static ThemeData light() {
    const ext = AppThemeExtension.light;
    final c = ext.colors;
    final base = ThemeData.light(useMaterial3: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.family,
      scaffoldBackgroundColor: c.canvas,
      colorScheme: ColorScheme.light(
        primary: c.accent,
        onPrimary: c.ink, // teks di atas oranye selalu navy
        secondary: c.ink,
        onSecondary: c.surface,
        surface: c.surface,
        onSurface: c.ink,
        error: c.danger,
        onError: Colors.white,
      ),
      extensions: [ext],
      textTheme: base.textTheme.apply(
        fontFamily: AppTypography.family,
        bodyColor: c.ink,
        displayColor: c.ink,
      ),
      // InkRipple menghindari shader ink_sparkle yang tidak tersedia saat test.
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.canvas,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.h3.copyWith(color: c.ink),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        hintStyle: AppTypography.body.copyWith(color: c.muted),
        labelStyle: AppTypography.label.copyWith(color: c.inkSoft),
        errorStyle: AppTypography.caption.copyWith(color: c.danger),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accentSoft,
        selectionHandleColor: c.accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: c.accent,
          foregroundColor: c.ink,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ext.radiusPill),
          ),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentStrong,
          minimumSize: const Size(44, 44),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ext.radiusCard),
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          side: BorderSide(color: c.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return AppTypography.label.copyWith(
            color: active ? c.ink : c.muted,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? c.accentStrong : c.muted,
            size: 22,
          );
        }),
      ),
    );
  }
}
