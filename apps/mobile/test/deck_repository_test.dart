import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/features/decks/data/deck_repository.dart';
import 'package:recally/features/study/data/card_repository.dart';

void main() {
  late AppDatabase db;
  late DeckRepository decks;
  late CardRepository cards;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    decks = DeckRepository(db);
    cards = CardRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('overview menghitung kartu dan kartu jatuh tempo', () async {
    final deckId = await decks.create(name: 'JLPT N4');
    final now = DateTime.now();

    await cards.create(
      deckId: deckId,
      front: 'pagi',
      back: 'morning',
      dueAt: now.subtract(const Duration(days: 1)),
    );
    await cards.create(
      deckId: deckId,
      front: 'malam',
      back: 'night',
      dueAt: now.add(const Duration(days: 3)),
    );

    final overview = await decks.watchOverview().first;

    expect(overview, hasLength(1));
    expect(overview.single.deck.name, 'JLPT N4');
    expect(overview.single.cardCount, 2);
    expect(overview.single.dueCount, 1);
  });

  test('deck tanpa kartu tetap muncul di overview', () async {
    await decks.create(name: 'Kosong');

    final overview = await decks.watchOverview().first;

    expect(overview, hasLength(1));
    expect(overview.single.cardCount, 0);
    expect(overview.single.dueCount, 0);
  });

  test('hapus deck menyembunyikan deck dan kartunya (soft delete)', () async {
    final deckId = await decks.create(name: 'Sementara');
    await cards.create(deckId: deckId, front: 'a', back: 'b');

    await decks.softDelete(deckId);

    expect(await decks.watchOverview().first, isEmpty);
    expect(await cards.watchByDeck(deckId).first, isEmpty);

    final rows = await db.select(db.cards).get();
    expect(rows.single.deletedAt, isNotNull);
    expect(rows.single.dirty, isTrue);
  });

  test('createMany memasukkan semua kartu dalam satu batch', () async {
    final deckId = await decks.create(name: 'Batch');

    final created = await cards.createMany(
      deckId: deckId,
      cards: [(front: 'a', back: 'b'), (front: 'c', back: 'd')],
    );

    expect(created, 2);
    expect(await cards.watchByDeck(deckId).first, hasLength(2));
  });

  test('update menyimpan nama dan deskripsi baru', () async {
    final deckId = await decks.create(name: 'Lama');

    await decks.update(id: deckId, name: 'Baru', description: 'Catatan');

    final deck = await decks.findById(deckId);
    expect(deck!.name, 'Baru');
    expect(deck.description, 'Catatan');
    expect(deck.dirty, isTrue);
  });
}
