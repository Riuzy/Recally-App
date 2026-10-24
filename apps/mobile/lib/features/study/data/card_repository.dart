import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/srs_engine.dart';

final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => CardRepository(ref.watch(appDatabaseProvider)),
);

class CardRepository {
  CardRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Cards that are due for review, earliest first.
  Stream<List<CardRow>> watchDue({DateTime? at}) {
    final now = at ?? DateTime.now();
    final query = _db.select(_db.cards)
      ..where(
        (t) => t.deletedAt.isNull() & t.dueAt.isSmallerOrEqualValue(now),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]);
    return query.watch();
  }

  Stream<List<CardRow>> watchByDeck(String deckId) {
    final query = _db.select(_db.cards)
      ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch();
  }

  Future<int> countDue({DateTime? at}) async {
    final now = at ?? DateTime.now();
    final count = _db.cards.id.count();
    final query = _db.selectOnly(_db.cards)
      ..addColumns([count])
      ..where(
        _db.cards.deletedAt.isNull() &
            _db.cards.dueAt.isSmallerOrEqualValue(now),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<String> create({
    required String deckId,
    required String front,
    required String back,
    DateTime? dueAt,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_db.cards).insert(
          CardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            dueAt: dueAt ?? now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateContent({
    required String id,
    required String front,
    required String back,
  }) async {
    await (_db.update(_db.cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(
        front: Value(front),
        back: Value(back),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  /// Applies a grade to [card]: updates the schedule and records the review in
  /// one transaction, so the history can never disagree with the card state.
  Future<ScheduleOutcome> applyReview({
    required CardRow card,
    required RecallRating rating,
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    final outcome = SrsEngine.schedule(
      rating: rating,
      ease: card.ease,
      intervalDays: card.intervalDays,
      reps: card.reps,
      lapses: card.lapses,
      now: now,
    );

    await _db.transaction(() async {
      await (_db.update(_db.cards)..where((t) => t.id.equals(card.id))).write(
        CardsCompanion(
          dueAt: Value(outcome.dueAt),
          intervalDays: Value(outcome.intervalDays),
          ease: Value(outcome.ease),
          reps: Value(outcome.reps),
          lapses: Value(outcome.lapses),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await _db.into(_db.reviews).insert(
            ReviewsCompanion.insert(
              id: _uuid.v4(),
              cardId: card.id,
              rating: rating.index,
              reviewedAt: now,
              prevIntervalDays: card.intervalDays,
              newIntervalDays: outcome.intervalDays,
            ),
          );
    });

    return outcome;
  }
}
