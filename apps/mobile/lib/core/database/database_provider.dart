import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single database instance for the app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
