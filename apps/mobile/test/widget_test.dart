// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:recally/main.dart';

void main() {
  testWidgets('Recally app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RecallyApp());
    expect(find.byType(RecallyApp), findsOneWidget);
  });
}
