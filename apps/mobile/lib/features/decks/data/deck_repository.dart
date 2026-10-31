import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) => DeckRepository(ref.watch(appDatabaseProvider)),
);

/// Ringkasan deck untuk layar daftar: isi deck plus hitungan kartu.
class DeckOverview {
  const DeckOverview({
    required this.deck,
    required this.cardCount,
    required this.dueCount,
  });

  final Deck deck;
  final int cardCount;
  final int dueCount;
}

/// Semua deck aktif beserta jumlah kartu dan kartu jatuh tempo.
final deckOverviewProvider = StreamProvider.autoDispose<List<DeckOverview>>(
  (ref) => ref.watch(deckRepositoryProvider).watchOverview(),
);

/// Satu deck berdasarkan id; `null` bila tidak ada atau sudah dihapus.
final deckByIdProvider = StreamProvider.autoDispose.family<Deck?, String>(
  (ref, id) => ref.watch(deckRepositoryProvider).watchById(id),
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

  /// Deck plus card counts in one reactive query.
  ///
  /// A left join keeps decks without cards visible. Rows arrive ordered by
  /// `updatedAt`, so insertion order into the map is the display order.
  Stream<List<DeckOverview>> watchOverview() {
    final query =
        _db.select(_db.decks).join([
            leftOuterJoin(
              _db.cards,
              _db.cards.deckId.equalsExp(_db.decks.id) &
                  _db.cards.deletedAt.isNull(),
            ),
          ])
          ..where(_db.decks.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(_db.decks.updatedAt)]);

    return query.watch().map((rows) {
      final now = DateTime.now();
      final builders = <String, _DeckOverviewBuilder>{};

      for (final row in rows) {
        final deck = row.readTable(_db.decks);
        final card = row.readTableOrNull(_db.cards);
        final builder = builders.putIfAbsent(
          deck.id,
          () => _DeckOverviewBuilder(deck),
        );
        if (card != null) {
          builder.cardCount++;
          if (!card.dueAt.isAfter(now)) builder.dueCount++;
        }
      }

      return builders.values
          .map((builder) => builder.build())
          .toList(growable: false);
    });
  }

  Stream<Deck?> watchById(String id) {
    final query = _db.select(_db.decks)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<Deck?> findById(String id) {
    return (_db.select(
      _db.decks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> create({required String name, String? description}) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.decks)
        .insert(
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

  Future<void> update({
    required String id,
    required String name,
    String? description,
  }) async {
    await (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
      DecksCompanion(
        name: Value(name),
        description: Value(description),
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

class _DeckOverviewBuilder {
  _DeckOverviewBuilder(this.deck);

  final Deck deck;
  int cardCount = 0;
  int dueCount = 0;

  DeckOverview build() =>
      DeckOverview(deck: deck, cardCount: cardCount, dueCount: dueCount);
}
