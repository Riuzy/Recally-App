import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_bootstrap.dart';
import 'auth_repository.dart';

/// `false` berarti Firebase tidak bisa diinisialisasi (offline atau project
/// belum siap). Aplikasi tetap jalan dengan data lokal.
final firebaseAvailableProvider = Provider<bool>(
  (ref) => FirebaseBootstrap.isInitialized,
);

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) {
    throw StateError('Firebase belum siap; fitur cloud dinonaktifkan.');
  }
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);

/// Sesi login saat ini; `null` berarti mode lokal tanpa akun.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);
  return authState.valueOrNull ??
      ref.watch(authRepositoryProvider).currentUser;
});
