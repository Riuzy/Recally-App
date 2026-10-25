import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_config.dart';

/// Google tidak mengembalikan ID token, biasanya karena SHA-1 app belum
/// terdaftar atau `GOOGLE_WEB_CLIENT_ID` belum diisi.
class GoogleSignInTokenException implements Exception {
  const GoogleSignInTokenException();

  @override
  String toString() =>
      'GoogleSignInTokenException: Google tidak mengembalikan ID token. '
      'Periksa GOOGLE_WEB_CLIENT_ID dan SHA-1 app.';
}

/// `GOOGLE_WEB_CLIENT_ID` belum diisi saat build.
class MissingGoogleClientIdException implements Exception {
  const MissingGoogleClientIdException();

  @override
  String toString() =>
      'MissingGoogleClientIdException: isi GOOGLE_WEB_CLIENT_ID lewat '
      '--dart-define-from-file=env.json.';
}

/// Pembungkus Supabase Auth (+ Google Sign-In native di Android).
///
/// Login bersifat opsional: semua method di sini hanya dipanggil dari layar
/// Sinkronisasi/Akun, tidak pernah menghalangi pemakaian lokal.
class AuthRepository {
  AuthRepository(this._client, {GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  bool _googleInitialized = false;

  /// Perubahan sesi login; `null` berarti belum/tidak login.
  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  /// Menampilkan pemilih akun Google, lalu menukar ID token ke sesi Supabase.
  Future<void> signInWithGoogle() async {
    if (SupabaseConfig.googleWebClientId.isEmpty) {
      throw const MissingGoogleClientIdException();
    }

    await _ensureGoogleInitialized();

    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    final String? idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const GoogleSignInTokenException();
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  /// Mengakhiri sesi cloud. Data lokal (Drift) tidak disentuh.
  Future<void> signOut() async {
    await _client.auth.signOut();
    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(
      serverClientId: SupabaseConfig.googleWebClientId,
    );
    _googleInitialized = true;
  }
}
