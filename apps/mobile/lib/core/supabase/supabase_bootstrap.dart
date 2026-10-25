import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Inisialisasi Supabase sekali saat aplikasi mulai.
///
/// Recally adalah aplikasi local-first: kegagalan di sini (belum dikonfigurasi
/// atau offline) tidak boleh menghalangi pemakaian aplikasi.
class SupabaseBootstrap {
  const SupabaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<bool> initialize() async {
    if (_initialized) return true;

    if (!SupabaseConfig.isConfigured) {
      debugPrint(
        'Supabase belum dikonfigurasi. Jalankan dengan '
        '--dart-define-from-file=env.json untuk mengaktifkan akun & sinkronisasi.',
      );
      return false;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // Nama parameter baru untuk anon key (legacy) / publishable key (baru).
        publishableKey: SupabaseConfig.anonKey,
      );
      _initialized = true;
    } catch (error) {
      debugPrint('Supabase tidak tersedia: $error');
    }

    return _initialized;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
