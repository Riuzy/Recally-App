import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/core/dev/demo_seed.dart';
import 'package:recally/features/decks/data/deck_repository.dart';
import 'package:recally/features/progress/data/progress_repository.dart';
import 'package:recally/features/progress/domain/progress_stats.dart';
import 'package:recally/features/study/data/card_repository.dart';

void main() {
  late AppDatabase db;
  late DemoSeed seed;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    seed = DemoSeed(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('membuat satu deck contoh berisi kartu dan riwayat', () async {
    final created = await seed.seedIfMissing();

    expect(created, isTrue);

    final decks = await db.select(db.decks).get();
    expect(decks, hasLength(1));
    expect(decks.single.name, DemoSeed.deckName);

    final cards = await db.select(db.cards).get();
    expect(cards, hasLength(12));
    expect(await CardRepository(db).countDue(), 4);

    final reviews = await db.select(db.reviews).get();
    expect(reviews, hasLength(14));

    // Data contoh tidak boleh ikut tersinkron ke Supabase.
    expect(decks.every((row) => row.dirty == false), isTrue);
    expect(cards.every((row) => row.dirty == false), isTrue);
    expect(reviews.every((row) => row.dirty == false), isTrue);
  });

  test('tidak menggandakan data saat dipanggil ulang', () async {
    expect(await seed.seedIfMissing(), isTrue);
    expect(await seed.seedIfMissing(), isFalse);

    expect(await db.select(db.decks).get(), hasLength(1));
    expect(await db.select(db.cards).get(), hasLength(12));
    expect(await db.select(db.reviews).get(), hasLength(14));
  });

  test('tetap bisa menambah data contoh saat deck lain sudah ada', () async {
    await DeckRepository(db).create(name: 'Deck milik pengguna');

    expect(await seed.seedIfMissing(), isTrue);

    final decks = await db.select(db.decks).get();
    expect(decks, hasLength(2));
    expect(decks.map((deck) => deck.name), contains(DemoSeed.deckName));
  });

  test('data contoh mengisi Progres dengan angka nyata', () async {
    await seed.seedIfMissing();
    final now = DateTime.now();

    final activity = await ProgressRepository(
      db,
    ).watchReviewActivity(ProgressPeriod.week, now: now).first;

    expect(activity.total, 12);
    expect(activity.ingat, 9);
    expect(activity.retention, closeTo(0.75, 0.001));
    expect(activity.previousTotal, 2);
    expect(activity.previousRetention, 0.5);
    expect(activity.retentionDelta, closeTo(0.25, 0.001));
    expect(activity.streak, 5);
    expect(activity.recentDays.first.reviews, 3);
    expect(activity.recentDays.first.ingat, 2);

    final cardStats = await ProgressRepository(
      db,
    ).watchCardProgress(now: now).first;

    expect(cardStats.total, 12);
    expect(cardStats.mastered, 2);
    expect(cardStats.fresh, 2);
    expect(cardStats.learning, 8);
    expect(cardStats.due, 4);
  });
}
