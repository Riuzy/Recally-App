import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Local-first database. This is the source of truth for the app; Supabase is
/// only an optional sync target.
@DriftDatabase(tables: [Decks, Cards, Reviews, SyncStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Used by tests, e.g. `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
