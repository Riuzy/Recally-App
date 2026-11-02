import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/core/database/database_provider.dart';
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

  testWidgets('mengisi data contoh dari Pengaturan', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Pengaturan').last);
    await settle(tester);

    expect(find.text('Isi data contoh'), findsOneWidget);

    await tester.tap(find.text('Isi data contoh'));
    await settle(tester, frames: 4);

    expect(find.text('Isi data contoh?'), findsOneWidget);

    await tester.tap(find.text('Isi data'));
    await settle(tester, frames: 10);

    expect(
      find.text('Data contoh siap. Buka tab Deck, Hari Ini, atau Progres.'),
      findsOneWidget,
    );
    expect(await db.select(db.decks).get(), hasLength(1));
    expect(await db.select(db.cards).get(), hasLength(12));

    await closeApp(tester);
  });
}
