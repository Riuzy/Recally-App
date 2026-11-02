import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/core/database/database_provider.dart';
import 'package:recally/features/decks/data/deck_repository.dart';
import 'package:recally/features/study/data/card_repository.dart';
import 'package:recally/features/study/domain/srs_engine.dart';
import 'package:recally/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  Widget app() => ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: const RecallyApp(),
  );

  Future<void> settle(WidgetTester tester, {int frames = 8}) async {
    for (var index = 0; index < frames; index++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await db.close();
  }

  Future<void> useTallViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('tab Progres menampilkan retensi, aktivitas, dan riwayat', (
    tester,
  ) async {
    await useTallViewport(tester);

    final deckId = await DeckRepository(db).create(name: 'Biologi Sel');
    await CardRepository(db).create(
      deckId: deckId,
      front: 'Apa fungsi mitokondria?',
      back: 'Menghasilkan energi melalui respirasi sel.',
    );
    final card = await db.select(db.cards).getSingle();
    await CardRepository(
      db,
    ).applyReview(card: card, rating: RecallRating.ingat);

    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Progres').last);
    await settle(tester, frames: 12);

    expect(find.text('retensi'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Kartu dikuasai'), findsOneWidget);
    expect(find.text('Per deck'), findsOneWidget);
    expect(find.text('Biologi Sel'), findsOneWidget);
    expect(find.text('Riwayat belajar'), findsOneWidget);
    expect(find.text('Hari ini'), findsOneWidget);

    await tester.tap(find.text('Minggu ini'));
    await settle(tester, frames: 4);

    expect(find.text('30 hari'), findsOneWidget);

    await tester.tap(find.text('30 hari'));
    await settle(tester, frames: 12);

    expect(find.text('30 hari'), findsOneWidget);
    expect(find.text('retensi'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('tanpa riwayat menampilkan ajakan mulai sesi', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Progres').last);
    await settle(tester, frames: 12);

    expect(find.text('Mulai sesi pertamamu'), findsOneWidget);
    expect(find.text('Mulai sesi'), findsWidgets);

    await closeApp(tester);
  });
}
