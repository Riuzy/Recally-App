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

  /// `pumpAndSettle` tidak dipakai karena kursor `TextField` membuat frame
  /// terus dijadwalkan selama widget masih terpasang.
  Future<void> settle(WidgetTester tester, {int frames = 6}) async {
    for (var index = 0; index < frames; index++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Melepas widget lalu menutup database **di dalam test body**.
  ///
  /// Drift memakai `Timer.run` untuk cache stream; menutup database dari
  /// `tearDown` akan menunggu timer yang hanya berjalan di fake-async test.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await db.close();
  }

  testWidgets('Recally app smoke test', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.byType(RecallyApp), findsOneWidget);
    expect(find.text('Hari ini'), findsWidgets);

    await closeApp(tester);
  });

  testWidgets('bottom navigation switches to the Deck tab', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Deck').last);
    await settle(tester);

    expect(find.text('Belum ada deck'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('membuat deck baru dari tab Deck', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Deck').last);
    await settle(tester);

    await tester.tap(find.byTooltip('Deck baru'));
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, 'Bahasa Jepang');
    await tester.pump(const Duration(milliseconds: 50));

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Buat deck'));
    await settle(tester, frames: 12);

    expect(find.text('Bahasa Jepang'), findsWidgets);
    expect(find.text('Tambah kartu'), findsOneWidget);
    expect(find.text('Belum ada kartu'), findsOneWidget);

    await closeApp(tester);
  });
}
