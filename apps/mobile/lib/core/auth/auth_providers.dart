import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_bootstrap.dart';
import 'auth_repository.dart';

/// `false` berarti Supabase tidak dikonfigurasi atau gagal init. Aplikasi
/// tetap jalan penuh dengan data lokal.
final supabaseAvailableProvider = Provider<bool>(
  (ref) => SupabaseBootstrap.isInitialized,
);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!ref.watch(supabaseAvailableProvider)) {
    throw StateError('Supabase belum siap; fitur cloud dinonaktifkan.');
  }
  return SupabaseBootstrap.client;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

/// Sesi login saat ini; `null` berarti mode lokal tanpa akun.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session?.user ??
      ref.watch(authRepositoryProvider).currentUser;
});
