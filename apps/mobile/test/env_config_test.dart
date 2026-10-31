import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/supabase/supabase_config.dart';

/// Pemeriksaan opsional: memastikan `env.json` benar-benar terbaca.
///
///   flutter test --dart-define-from-file=env.json `
///     --dart-define=CHECK_SUPABASE_ENV=true test/env_config_test.dart
///
/// Tanpa flag tersebut tes ini tidak memeriksa apa pun, supaya suite biasa
/// tetap hijau di mesin tanpa kredensial.
void main() {
  const check = bool.fromEnvironment('CHECK_SUPABASE_ENV');

  test('konfigurasi Supabase terbaca dari env.json', () {
    if (!check) return;

    expect(SupabaseConfig.url, startsWith('https://'));
    expect(SupabaseConfig.anonKey, isNotEmpty);
    expect(SupabaseConfig.isConfigured, isTrue);
  });
}
