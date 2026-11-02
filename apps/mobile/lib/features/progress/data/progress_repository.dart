import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../study/domain/srs_engine.dart';
import '../../study/domain/streak.dart';
import '../domain/progress_stats.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(appDatabaseProvider)),
);

/// Statistik kartu dan deck; ikut berubah saat kartu ditambah, dinilai, atau
/// dihapus.
final cardProgressProvider = StreamProvider.autoDispose<CardProgress>(
  (ref) => ref.watch(progressRepositoryProvider).watchCardProgress(),
);

/// Retensi, grafik aktivitas, streak, dan riwayat untuk periode terpilih.
final reviewActivityProvider = StreamProvider.autoDispose
    .family<ReviewActivity, ProgressPeriod>(
      (ref, period) =>
          ref.watch(progressRepositoryProvider).watchReviewActivity(period),
    );

class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  Stream<CardProgress> watchCardProgress({DateTime? now}) {
    final query = _db.select(_db.cards).join([
      innerJoin(_db.decks, _db.decks.id.equalsExp(_db.cards.deckId)),
    ])..where(_db.cards.deletedAt.isNull() & _db.decks.deletedAt.isNull());

    return query.watch().map((rows) {
      final at = now ?? DateTime.now();
      final builders = <String, _DeckProgressBuilder>{};

      for (final row in rows) {
        final card = row.readTable(_db.cards);
        final deck = row.readTable(_db.decks);
        builders
            .putIfAbsent(deck.id, () => _DeckProgressBuilder(deck))
            .add(card, at);
      }

      var total = 0;
      var due = 0;
      var mastered = 0;
      var learning = 0;
      var fresh = 0;
      for (final builder in builders.values) {
        total += builder.total;
        due += builder.due;
        mastered += builder.mastered;
        learning += builder.learning;
        fresh += builder.fresh;
      }

      final decks = builders.values.map((builder) => builder.build()).toList()
        ..sort((a, b) {
          final byTotal = b.total.compareTo(a.total);
          return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
        });

      return CardProgress(
        total: total,
        due: due,
        mastered: mastered,
        learning: learning,
        fresh: fresh,
        decks: List.unmodifiable(decks),
      );
    });
  }

  Stream<ReviewActivity> watchReviewActivity(
    ProgressPeriod period, {
    DateTime? now,
  }) {
    final query = _db.selectOnly(_db.reviews)
      ..addColumns([_db.reviews.reviewedAt, _db.reviews.rating]);

    return query.watch().map((rows) {
      final at = now ?? DateTime.now();
      final today = DateTime(at.year, at.month, at.day);
      final currentStart = DateTime(
        today.year,
        today.month,
        today.day - (period.days - 1),
      );
      final previousStart = DateTime(
        currentStart.year,
        currentStart.month,
        currentStart.day - period.days,
      );

      final dayCounts = <DateTime, int>{};
      final summaries = <DateTime, _DaySummaryBuilder>{};
      final timestamps = <DateTime>[];

      var total = 0;
      var ingat = 0;
      var ragu = 0;
      var lupa = 0;
      var previousTotal = 0;
      var previousIngat = 0;

      for (final row in rows) {
        final reviewedAt = row.read(_db.reviews.reviewedAt);
        final ratingValue = row.read(_db.reviews.rating);
        if (reviewedAt == null || ratingValue == null) continue;
        if (ratingValue < 0 || ratingValue >= RecallRating.values.length) {
          continue;
        }
        final rating = RecallRating.values[ratingValue];
        final day = DateTime(reviewedAt.year, reviewedAt.month, reviewedAt.day);

        timestamps.add(reviewedAt);
        summaries.putIfAbsent(day, _DaySummaryBuilder.new).add(rating);

        final isCurrent = !day.isBefore(currentStart) && !day.isAfter(today);
        if (isCurrent) {
          dayCounts.update(day, (value) => value + 1, ifAbsent: () => 1);
          total++;
          switch (rating) {
            case RecallRating.ingat:
              ingat++;
            case RecallRating.ragu:
              ragu++;
            case RecallRating.lupa:
              lupa++;
          }
        } else if (!day.isBefore(previousStart) && day.isBefore(currentStart)) {
          previousTotal++;
          if (rating == RecallRating.ingat) previousIngat++;
        }
      }

      final days = <DayActivity>[
        for (var index = 0; index < period.days; index++)
          DayActivity(
            day: DateTime(
              currentStart.year,
              currentStart.month,
              currentStart.day + index,
            ),
            reviews:
                dayCounts[DateTime(
                  currentStart.year,
                  currentStart.month,
                  currentStart.day + index,
                )] ??
                0,
          ),
      ];

      final recentDays =
          summaries.entries
              .map((entry) => entry.value.build(entry.key))
              .toList()
            ..sort((a, b) => b.day.compareTo(a.day));

      return ReviewActivity(
        period: period,
        days: List.unmodifiable(days),
        total: total,
        ingat: ingat,
        ragu: ragu,
        lupa: lupa,
        previousTotal: previousTotal,
        previousIngat: previousIngat,
        streak: computeStreak(timestamps, now: at),
        recentDays: List.unmodifiable(recentDays.take(3)),
        hasAnyReview: rows.isNotEmpty,
      );
    });
  }
}

class _DeckProgressBuilder {
  _DeckProgressBuilder(this._deck);

  final Deck _deck;
  int total = 0;
  int mastered = 0;
  int learning = 0;
  int fresh = 0;
  int due = 0;

  void add(CardRow card, DateTime now) {
    total++;
    if (!card.dueAt.isAfter(now)) due++;

    if (card.intervalDays >= masteredIntervalDays) {
      mastered++;
    } else if (card.reps == 0 && card.lapses == 0) {
      fresh++;
    } else {
      learning++;
    }
  }

  DeckProgress build() => DeckProgress(
    deckId: _deck.id,
    name: _deck.name,
    total: total,
    mastered: mastered,
    due: due,
  );
}

class _DaySummaryBuilder {
  int reviews = 0;
  int ingat = 0;

  void add(RecallRating rating) {
    reviews++;
    if (rating == RecallRating.ingat) ingat++;
  }

  DayReviewSummary build(DateTime day) =>
      DayReviewSummary(day: day, reviews: reviews, ingat: ingat);
}
