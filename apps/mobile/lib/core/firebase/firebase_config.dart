/// Nilai konfigurasi Firebase yang tidak dihasilkan `firebase_options.dart`.
class FirebaseConfig {
  const FirebaseConfig._();

  /// Web OAuth client ID ("server client ID") dari `google-services.json`
  /// dengan `client_type: 3`.
  ///
  /// Nilai ini dipakai `GoogleSignIn.initialize(serverClientId: ...)` supaya
  /// Google mengembalikan ID token yang audiensnya diterima Firebase Auth.
  /// Diambil dari project `recally-app-f1f3f` setelah provider Google
  /// diaktifkan. Lihat `docs/setup/firebase.md`.
  static const String googleServerClientId =
      '1001950032387-j3rpdvvjrshs7ps1ohot3jlb92q47c0a.apps.googleusercontent.com';
}
