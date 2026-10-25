import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

/// Sinkronisasi dipanggil tanpa sesi login.
class NotSignedInException implements Exception {
  const NotSignedInException();

  @override
  String toString() => 'NotSignedInException: login dulu untuk sinkronisasi.';
}

class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.pulled,
    required this.at,
  });

  final int pushed;
  final int pulled;
  final DateTime at;

  bool get isEmpty => pushed == 0 && pulled == 0;

  @override
  String toString() => 'SyncReport(pushed: $pushed, pulled: $pulled, at: $at)';
}

/// Sinkronisasi Drift ⇄ Supabase/Postgres.
///
/// Aturan main:
/// - Drift selalu sumber kebenaran lokal; cloud hanya cermin.
/// - Push hanya baris `dirty = true`, satu arah per tabel.
/// - Pull memakai `updated_at` sebagai kursor, dengan konflik diselesaikan
///   last-write-wins.
/// - Hapus selalu soft delete (`deleted_at`) supaya penghapusan ikut tersalin.
class SyncService {
  SyncService(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  /// Toleransi kursor untuk mengantisipasi resolusi waktu penyimpanan Drift.
  static const Duration _cursorOverlap = Duration(seconds: 2);

  Future<SyncReport> sync() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const NotSignedInException();

    var pushed = 0;
    pushed += await _pushDecks(userId);
    pushed += await _pushCards(userId);
    pushed += await _pushReviews(userId);

    var pulled = 0;
    pulled += await _pullDecks(userId);
    pulled += await _pullCards(userId);
    pulled += await _pullReviews(userId);

    return SyncReport(pushed: pushed, pulled: pulled, at: DateTime.now());
  }

  // ---------------------------------------------------------------- push ---

  Future<int> _pushDecks(String userId) async {
    final rows = await (_db.select(
      _db.decks,
    )..where((t) => t.dirty.equals(true))).get();
    if (rows.isEmpty) return 0;

    await _client
        .from('decks')
        .upsert(rows.map((d) => _deckJson(userId, d)).toList());

    await _db.batch((batch) {
      for (final row in rows) {
        batch.update(
          _db.decks,
          const DecksCompanion(dirty: Value(false)),
          where: (t) => t.id.equals(row.id) & t.updatedAt.equals(row.updatedAt),
        );
      }
    });
    return rows.length;
  }

  Future<int> _pushCards(String userId) async {
    final rows = await (_db.select(
      _db.cards,
    )..where((t) => t.dirty.equals(true))).get();
    if (rows.isEmpty) return 0;

    await _client
        .from('cards')
        .upsert(rows.map((c) => _cardJson(userId, c)).toList());

    await _db.batch((batch) {
      for (final row in rows) {
        batch.update(
          _db.cards,
          const CardsCompanion(dirty: Value(false)),
          where: (t) => t.id.equals(row.id) & t.updatedAt.equals(row.updatedAt),
        );
      }
    });
    return rows.length;
  }

  Future<int> _pushReviews(String userId) async {
    final rows = await (_db.select(
      _db.reviews,
    )..where((t) => t.dirty.equals(true))).get();
    if (rows.isEmpty) return 0;

    await _client
        .from('reviews')
        .upsert(
          rows.map((r) => _reviewJson(userId, r)).toList(),
          ignoreDuplicates: true,
        );

    await _db.batch((batch) {
      for (final row in rows) {
        batch.update(
          _db.reviews,
          const ReviewsCompanion(dirty: Value(false)),
          where: (t) => t.id.equals(row.id),
        );
      }
    });
    return rows.length;
  }

  // ---------------------------------------------------------------- pull ---

  Future<int> _pullDecks(String userId) async {
    final since = await _readCursor('decks');
    final data = await _client
        .from('decks')
        .select()
        .eq('user_id', userId)
        .gte('updated_at', _iso(since.subtract(_cursorOverlap)))
        .order('updated_at');

    var changed = 0;
    var newest = since;

    for (final json in data) {
      final updatedAt = _date(json['updated_at']);
      final id = json['id'] as String;
      final local = await (_db.select(
        _db.decks,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (local == null || updatedAt.isAfter(local.updatedAt)) {
        await _db
            .into(_db.decks)
            .insertOnConflictUpdate(
              DecksCompanion.insert(
                id: id,
                name: json['name'] as String,
                createdAt: _date(json['created_at']),
                updatedAt: updatedAt,
                description: Value(json['description'] as String?),
                deletedAt: Value(_dateOrNull(json['deleted_at'])),
                dirty: const Value(false),
              ),
            );
        changed++;
      }
      if (updatedAt.isAfter(newest)) newest = updatedAt;
    }

    await _writeCursor('decks', newest);
    return changed;
  }

  Future<int> _pullCards(String userId) async {
    final since = await _readCursor('cards');
    final data = await _client
        .from('cards')
        .select()
        .eq('user_id', userId)
        .gte('updated_at', _iso(since.subtract(_cursorOverlap)))
        .order('updated_at');

    var changed = 0;
    var newest = since;

    for (final json in data) {
      final updatedAt = _date(json['updated_at']);
      final id = json['id'] as String;
      final local = await (_db.select(
        _db.cards,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (local == null || updatedAt.isAfter(local.updatedAt)) {
        await _db
            .into(_db.cards)
            .insertOnConflictUpdate(
              CardsCompanion.insert(
                id: id,
                deckId: json['deck_id'] as String,
                front: json['front'] as String,
                back: json['back'] as String,
                dueAt: _date(json['due_at']),
                createdAt: _date(json['created_at']),
                updatedAt: updatedAt,
                intervalDays: Value((json['interval_days'] as num).toInt()),
                ease: Value((json['ease'] as num).toDouble()),
                reps: Value((json['reps'] as num).toInt()),
                lapses: Value((json['lapses'] as num).toInt()),
                deletedAt: Value(_dateOrNull(json['deleted_at'])),
                dirty: const Value(false),
              ),
            );
        changed++;
      }
      if (updatedAt.isAfter(newest)) newest = updatedAt;
    }

    await _writeCursor('cards', newest);
    return changed;
  }

  Future<int> _pullReviews(String userId) async {
    final since = await _readCursor('reviews');
    final data = await _client
        .from('reviews')
        .select()
        .eq('user_id', userId)
        .gte('reviewed_at', _iso(since.subtract(_cursorOverlap)))
        .order('reviewed_at');

    var inserted = 0;
    var newest = since;

    for (final json in data) {
      final reviewedAt = _date(json['reviewed_at']);
      final id = json['id'] as String;
      final existing = await (_db.select(
        _db.reviews,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (existing == null) {
        await _db
            .into(_db.reviews)
            .insert(
              ReviewsCompanion.insert(
                id: id,
                cardId: json['card_id'] as String,
                rating: (json['rating'] as num).toInt(),
                reviewedAt: reviewedAt,
                prevIntervalDays: (json['prev_interval_days'] as num).toInt(),
                newIntervalDays: (json['new_interval_days'] as num).toInt(),
                dirty: const Value(false),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        inserted++;
      }
      if (reviewedAt.isAfter(newest)) newest = reviewedAt;
    }

    await _writeCursor('reviews', newest);
    return inserted;
  }

  // -------------------------------------------------------------- helpers ---

  Future<DateTime> _readCursor(String table) async {
    final row = await (_db.select(
      _db.syncStates,
    )..where((t) => t.key.equals('last_pulled_$table'))).getSingleOrNull();
    if (row == null) return DateTime.utc(1970);
    return DateTime.tryParse(row.value)?.toUtc() ?? DateTime.utc(1970);
  }

  Future<void> _writeCursor(String table, DateTime value) async {
    await _db
        .into(_db.syncStates)
        .insertOnConflictUpdate(
          SyncStatesCompanion.insert(
            key: 'last_pulled_$table',
            value: value.toUtc().toIso8601String(),
          ),
        );
  }

  static String _iso(DateTime value) => value.toUtc().toIso8601String();

  static DateTime _date(Object? value) =>
      DateTime.parse(value as String).toLocal();

  static DateTime? _dateOrNull(Object? value) =>
      value == null ? null : _date(value);

  static Map<String, dynamic> _deckJson(String userId, Deck deck) => {
    'id': deck.id,
    'user_id': userId,
    'name': deck.name,
    'description': deck.description,
    'created_at': _iso(deck.createdAt),
    'updated_at': _iso(deck.updatedAt),
    'deleted_at': deck.deletedAt == null ? null : _iso(deck.deletedAt!),
  };

  static Map<String, dynamic> _cardJson(String userId, CardRow card) => {
    'id': card.id,
    'deck_id': card.deckId,
    'user_id': userId,
    'front': card.front,
    'back': card.back,
    'due_at': _iso(card.dueAt),
    'interval_days': card.intervalDays,
    'ease': card.ease,
    'reps': card.reps,
    'lapses': card.lapses,
    'created_at': _iso(card.createdAt),
    'updated_at': _iso(card.updatedAt),
    'deleted_at': card.deletedAt == null ? null : _iso(card.deletedAt!),
  };

  static Map<String, dynamic> _reviewJson(String userId, Review review) => {
    'id': review.id,
    'card_id': review.cardId,
    'user_id': userId,
    'rating': review.rating,
    'reviewed_at': _iso(review.reviewedAt),
    'prev_interval_days': review.prevIntervalDays,
    'new_interval_days': review.newIntervalDays,
  };
}
