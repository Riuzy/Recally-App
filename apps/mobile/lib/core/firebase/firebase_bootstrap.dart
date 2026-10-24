import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Inisialisasi Firebase sekali saat aplikasi mulai.
///
/// Recally adalah aplikasi local-first: kegagalan di sini (perangkat offline,
/// project Firebase belum dikonfigurasi) tidak boleh menghalangi pemakaian
/// aplikasi. Layar yang memang butuh cloud mengecek [isInitialized] lebih
/// dulu dan menampilkan pesan sendiri.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool _initialized = false;

  /// `true` kalau [initialize] berhasil.
  static bool get isInitialized => _initialized;

  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    } on FirebaseException catch (error) {
      debugPrint('Firebase tidak tersedia: ${error.code} — ${error.message}');
    } catch (error) {
      debugPrint('Firebase tidak tersedia: $error');
    }

    return _initialized;
  }
}
