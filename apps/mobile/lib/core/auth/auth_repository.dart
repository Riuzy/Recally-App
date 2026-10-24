import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase/firebase_config.dart';

/// Google mengembalikan akun tanpa ID token, biasanya karena web OAuth client
/// ID belum diisi di [FirebaseConfig.googleServerClientId] atau SHA-1 app
/// belum terdaftar di Firebase Console.
class GoogleSignInTokenException implements Exception {
  const GoogleSignInTokenException();

  @override
  String toString() =>
      'GoogleSignInTokenException: Google tidak mengembalikan ID token. '
      'Periksa FirebaseConfig.googleServerClientId dan SHA-1 app.';
}

/// Pembungkus tipis Firebase Auth + Google Sign-In.
///
/// Login bersifat opsional: semua method di sini hanya dipanggil dari layar
/// Sinkronisasi/Akun, tidak pernah menghalangi pemakaian lokal.
class AuthRepository {
  AuthRepository(this._auth, {GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  bool _googleInitialized = false;

  /// Perubahan sesi login. Bernilai `null` saat pengguna belum/tidak login.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Menampilkan pemilih akun Google lalu menukar ID token dengan sesi
  /// Firebase. Melempar [GoogleSignInException] kalau pengguna membatalkan.
  Future<User?> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    final String? idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const GoogleSignInTokenException();
    }

    final UserCredential result = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return result.user;
  }

  /// Mengakhiri sesi cloud. Data lokal (Drift) tidak disentuh.
  Future<void> signOut() async {
    await _ensureGoogleInitialized();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    const String serverClientId = FirebaseConfig.googleServerClientId;
    await _googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _googleInitialized = true;
  }
}
