import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../database/database_provider.dart';
import 'sync_service.dart';

/// `null` berarti sinkronisasi tidak tersedia (Supabase belum dikonfigurasi).
final syncServiceProvider = Provider<SyncService?>((ref) {
  if (!ref.watch(supabaseAvailableProvider)) return null;
  return SyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(supabaseClientProvider),
  );
});
