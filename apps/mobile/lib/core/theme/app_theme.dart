import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static ThemeData light() {
    const ext = AppThemeExtension.light;
    final c = ext.colors;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.canvas,
      colorScheme: ColorScheme.light(
        primary: c.accent,
        onPrimary: Colors.white,
        surface: c.surface,
        onSurface: c.ink,
        error: c.danger,
        onError: Colors.white,
      ),
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.ink,
          height: 24 / 18,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          borderSide: BorderSide(color: c.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.danger),
        ),
        hintStyle: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: c.muted,
        ),
        labelStyle: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.inkSoft,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ext.radiusControl),
          ),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
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
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: c.glass,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active ? c.accent : c.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(color: active ? c.accent : c.muted, size: 24);
        }),
      ),
    );
  }

  static ThemeData dark() {
    const ext = AppThemeExtension.dark;
    final c = ext.colors;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.canvas,
      colorScheme: ColorScheme.dark(
        primary: c.accent,
        onPrimary: Colors.white,
        surface: c.surface,
        onSurface: c.ink,
        error: c.danger,
        onError: Colors.white,
      ),
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.ink,
          height: 24 / 18,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          borderSide: BorderSide(color: c.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ext.radiusControl),
          borderSide: BorderSide(color: c.danger),
        ),
        hintStyle: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: c.muted,
        ),
        labelStyle: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.inkSoft,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ext.radiusControl),
          ),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
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
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: c.glass,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active ? c.accent : c.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(color: active ? c.accent : c.muted, size: 24);
        }),
      ),
    );
  }
}
