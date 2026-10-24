/// Nilai konfigurasi Firebase yang tidak dihasilkan `firebase_options.dart`.
class FirebaseConfig {
  const FirebaseConfig._();

  /// Web OAuth client ID ("server client ID") dari `google-services.json`
  /// dengan `client_type: 3`.
  ///
  /// Nilai ini baru ada setelah **Google** diaktifkan sebagai sign-in provider
  /// di Firebase Console, lalu `google-services.json` diambil ulang. Lihat
  /// `docs/setup/firebase.md` bagian 6.
  ///
  /// Selama masih kosong, Google Sign-In tidak bisa menghasilkan ID token dan
  /// `AuthRepository.signInWithGoogle` akan melempar
  /// `GoogleSignInTokenException`.
  static const String googleServerClientId = '';
}
