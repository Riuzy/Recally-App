import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/core/database/database_provider.dart';
import 'package:recally/features/decks/data/deck_repository.dart';
import 'package:recally/features/study/data/card_repository.dart';
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

  Future<String> seedDueCard() async {
    final deckId = await DeckRepository(db).create(name: 'Biologi Sel');
    return CardRepository(db).create(
      deckId: deckId,
      front: 'Apa fungsi mitokondria?',
      back: 'Menghasilkan energi melalui respirasi sel.',
      dueAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  testWidgets('menjalankan sesi tulis jawaban sampai ringkasan', (
    tester,
  ) async {
    await seedDueCard();

    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text('kartu siap diulang'), findsOneWidget);
    expect(find.text('Mulai sesi'), findsOneWidget);

    await tester.tap(find.text('Mulai sesi'));
    await settle(tester, frames: 12);

    expect(find.text('Kartu 1 dari 1'), findsOneWidget);
    expect(find.text('Apa fungsi mitokondria?'), findsOneWidget);
    expect(find.text('Biologi Sel'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Menghasilkan energi');
    await tester.pump(const Duration(milliseconds: 80));

    await tester.tap(find.text('Periksa jawaban'));
    await settle(tester, frames: 4);

    expect(find.text('Jawabanmu'), findsOneWidget);
    expect(find.text('Menghasilkan energi'), findsOneWidget);
    expect(find.text('Jawaban benar'), findsOneWidget);
    expect(
      find.text('Menghasilkan energi melalui respirasi sel.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ingat'));
    await settle(tester, frames: 12);

    expect(find.text('Sesi selesai.'), findsOneWidget);
    expect(find.text('Kembali ke Hari Ini'), findsOneWidget);
    expect(find.text('Jadwal berikutnya'), findsOneWidget);

    await tester.tap(find.text('Kembali ke Hari Ini'));
    await settle(tester, frames: 12);

    expect(
      find.text('Belum ada kartu jatuh tempo. Tambahkan kartu di deck.'),
      findsOneWidget,
    );

    await closeApp(tester);
  });

  testWidgets('kartu lupa bisa diulang dari ringkasan', (tester) async {
    await seedDueCard();

    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Mulai sesi'));
    await settle(tester, frames: 12);

    await tester.enterText(find.byType(TextField), 'Tidak tahu');
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('Periksa jawaban'));
    await settle(tester, frames: 4);

    await tester.tap(find.text('Lupa'));
    await settle(tester, frames: 12);

    expect(find.text('Sesi selesai.'), findsOneWidget);
    expect(find.text('Ulangi kartu yang lupa'), findsOneWidget);

    await tester.ensureVisible(find.text('Ulangi kartu yang lupa'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('Ulangi kartu yang lupa'));
    await settle(tester, frames: 12);

    expect(find.text('Kartu 1 dari 1'), findsOneWidget);
    expect(find.text('Apa fungsi mitokondria?'), findsOneWidget);

    await closeApp(tester);
  });
}
