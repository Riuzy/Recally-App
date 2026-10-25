/// Konfigurasi Supabase, dibaca dari `--dart-define` (lihat `env.example.json`).
///
/// Semua nilai default kosong supaya aplikasi tetap bisa dibangun dan dipakai
/// tanpa akun. Mode lokal murni adalah keadaan yang sah, bukan error.
class SupabaseConfig {
  const SupabaseConfig._();

  /// URL project, mis. `https://abcdefgh.supabase.co`.
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// Anon key (publishable). Aman dibundel; keamanan dijaga RLS.
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Web client ID Google, dipakai `signInWithIdToken`.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
