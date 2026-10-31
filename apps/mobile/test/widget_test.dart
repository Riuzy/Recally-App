import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recally/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Recally app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RecallyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RecallyApp), findsOneWidget);
    expect(find.text('Hari ini'), findsWidgets);
  });

  testWidgets('bottom navigation switches to the Deck tab', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RecallyApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deck').last);
    await tester.pumpAndSettle();

    expect(find.text('Belum ada deck'), findsOneWidget);
  });
}
