import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilihan tema (Ikuti sistem / Terang / Gelap) yang bertahan antar sesi.
///
/// Penyimpanan gagal (mis. plugin belum siap di test) tidak boleh membuat
/// aplikasi crash: pilihan tetap berlaku sampai aplikasi ditutup.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  static const String _storageKey = 'theme_mode';

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, mode.name);
    } catch (_) {
      // Abaikan: preferensi tetap berlaku di sesi ini.
    }
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored == null) return;
      for (final mode in ThemeMode.values) {
        if (mode.name == stored) {
          state = mode;
          return;
        }
      }
    } catch (_) {
      // Abaikan: pakai ThemeMode.system.
    }
  }
}

extension ThemeModeLabel on ThemeMode {
  String get label => switch (this) {
    ThemeMode.system => 'Ikuti sistem',
    ThemeMode.light => 'Terang',
    ThemeMode.dark => 'Gelap',
  };
}
