import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/features/progress/data/progress_repository.dart';
import 'package:recally/features/progress/domain/progress_stats.dart';
import 'package:recally/features/study/domain/srs_engine.dart';

void main() {
  late AppDatabase db;
  late ProgressRepository progress;

  final now = DateTime(2026, 11, 3, 10, 0);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    progress = ProgressRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedDeck(String id, String name) async {
    final createdAt = DateTime(2026, 10, 1);
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
  }

  Future<void> seedCard({
    required String id,
    required String deckId,
    int intervalDays = 0,
    int reps = 0,
    int lapses = 0,
    DateTime? dueAt,
  }) async {
    await db
        .into(db.cards)
        .insert(
          CardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: 'pertanyaan',
            back: 'jawaban',
            dueAt: dueAt ?? now,
            intervalDays: Value(intervalDays),
            reps: Value(reps),
            lapses: Value(lapses),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedReview({
    required String id,
    required String cardId,
    required RecallRating rating,
    required DateTime at,
  }) async {
    await db
        .into(db.reviews)
        .insert(
          ReviewsCompanion.insert(
            id: id,
            cardId: cardId,
            rating: rating.index,
            reviewedAt: at,
            prevIntervalDays: 0,
            newIntervalDays: 1,
          ),
        );
  }

  test('kartu dihitung baru, sedang dipelajari, dan dikuasai', () async {
    await seedDeck('d1', 'Biologi');
    await seedDeck('d2', 'Fisika');
    await seedCard(
      id: 'a',
      deckId: 'd1',
      dueAt: now.subtract(const Duration(minutes: 1)),
    );
    await seedCard(
      id: 'b',
      deckId: 'd1',
      intervalDays: 5,
      reps: 2,
      dueAt: now.add(const Duration(days: 3)),
    );
    await seedCard(
      id: 'c',
      deckId: 'd2',
      intervalDays: 30,
      reps: 5,
      dueAt: now.add(const Duration(days: 10)),
    );
    await seedCard(
      id: 'd',
      deckId: 'd2',
      lapses: 1,
      dueAt: now.add(const Duration(minutes: 9)),
    );

    final stats = await progress.watchCardProgress(now: now).first;

    expect(stats.total, 4);
    expect(stats.due, 1);
    expect(stats.mastered, 1);
    expect(stats.learning, 2);
    expect(stats.fresh, 1);
    expect(stats.decks, hasLength(2));
    expect(stats.decks.first.name, 'Biologi');
    expect(stats.decks.first.total, 2);
    expect(stats.decks.first.mastered, 0);
    expect(stats.mastery, 0.25);
  });

  test('deck dan kartu yang dihapus tidak ikut dihitung', () async {
    await seedDeck('d1', 'Aktif');
    await seedDeck('d2', 'Terhapus');
    await seedCard(id: 'a', deckId: 'd1');
    await seedCard(id: 'b', deckId: 'd2');

    await (db.update(db.decks)..where((t) => t.id.equals('d2'))).write(
      DecksCompanion(deletedAt: Value(now)),
    );
    await (db.update(db.cards)..where((t) => t.id.equals('b'))).write(
      CardsCompanion(deletedAt: Value(now)),
    );

    final stats = await progress.watchCardProgress(now: now).first;

    expect(stats.total, 1);
    expect(stats.decks, hasLength(1));
    expect(stats.decks.single.name, 'Aktif');
  });

  test('aktivitas minggu ini, retensi, pembanding, dan streak', () async {
    await seedDeck('d1', 'Biologi');
    await seedCard(id: 'a', deckId: 'd1');

    await seedReview(
      id: 'r1',
      cardId: 'a',
      rating: RecallRating.ingat,
      at: now,
    );
    await seedReview(
      id: 'r2',
      cardId: 'a',
      rating: RecallRating.ingat,
      at: DateTime(2026, 11, 2, 9),
    );
    await seedReview(
      id: 'r3',
      cardId: 'a',
      rating: RecallRating.lupa,
      at: DateTime(2026, 11, 2, 20),
    );
    await seedReview(
      id: 'r4',
      cardId: 'a',
      rating: RecallRating.lupa,
      at: DateTime(2026, 10, 27),
    );
    await seedReview(
      id: 'r5',
      cardId: 'a',
      rating: RecallRating.ingat,
      at: DateTime(2026, 10, 15),
    );

    final activity = await progress
        .watchReviewActivity(ProgressPeriod.week, now: now)
        .first;

    expect(activity.days, hasLength(7));
    expect(activity.days.last.day, DateTime(2026, 11, 3));
    expect(activity.days.last.reviews, 1);
    expect(activity.days[5].day, DateTime(2026, 11, 2));
    expect(activity.days[5].reviews, 2);
    expect(activity.total, 3);
    expect(activity.ingat, 2);
    expect(activity.ragu, 0);
    expect(activity.lupa, 1);
    expect(activity.retention, closeTo(2 / 3, 0.0001));
    expect(activity.previousTotal, 1);
    expect(activity.previousIngat, 0);
    expect(activity.previousRetention, 0);
    expect(activity.retentionDelta, closeTo(2 / 3, 0.0001));
    expect(activity.streak, 2);
    expect(activity.recentDays, hasLength(3));
    expect(activity.recentDays.first.day, DateTime(2026, 11, 3));
    expect(activity.recentDays.first.reviews, 1);
    expect(activity.recentDays.first.ingat, 1);
    expect(activity.hasAnyReview, isTrue);
  });

  test('periode 30 hari mencakup ulasan lebih lama', () async {
    await seedDeck('d1', 'Biologi');
    await seedCard(id: 'a', deckId: 'd1');
    await seedReview(
      id: 'r1',
      cardId: 'a',
      rating: RecallRating.ingat,
      at: DateTime(2026, 10, 15),
    );

    final activity = await progress
        .watchReviewActivity(ProgressPeriod.month, now: now)
        .first;

    expect(activity.days, hasLength(30));
    expect(activity.total, 1);
    expect(activity.retention, 1);
    expect(activity.previousTotal, 0);
    expect(activity.retentionDelta, isNull);
  });

  test('tanpa ulasan retensi null dan riwayat kosong', () async {
    final activity = await progress
        .watchReviewActivity(ProgressPeriod.week, now: now)
        .first;

    expect(activity.hasAnyReview, isFalse);
    expect(activity.total, 0);
    expect(activity.retention, isNull);
    expect(activity.retentionDelta, isNull);
    expect(activity.days, hasLength(7));
    expect(activity.days.every((day) => day.reviews == 0), isTrue);
    expect(activity.recentDays, isEmpty);
  });
}
