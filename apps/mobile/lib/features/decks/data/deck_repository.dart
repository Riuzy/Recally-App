import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) => DeckRepository(ref.watch(appDatabaseProvider)),
);

class DeckRepository {
  DeckRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// All decks that are not soft-deleted, newest change first.
  Stream<List<Deck>> watchAll() {
    final query = _db.select(_db.decks)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch();
  }

  Future<Deck?> findById(String id) {
    return (_db.select(_db.decks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> create({required String name, String? description}) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_db.decks).insert(
          DecksCompanion.insert(
            id: id,
            name: name,
            description: Value(description),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> rename(String id, String name) async {
    await (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
      DecksCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      ),
    );
  }

  /// Soft-deletes the deck and its cards so the deletion can be synced later.
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
        DecksCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await (_db.update(_db.cards)..where((t) => t.deckId.equals(id))).write(
        CardsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
    });
  }
}
