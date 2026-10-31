import 'package:flutter_test/flutter_test.dart';
import 'package:recally/features/decks/domain/card_import.dart';

void main() {
  group('parseCardLines', () {
    test('membaca baris valid dan melewati baris kosong', () {
      final result = parseCardLines('pagi;morning\n\nmalam;night');

      expect(result.cards, hasLength(2));
      expect(result.cards.first.front, 'pagi');
      expect(result.cards.first.back, 'morning');
      expect(result.cards.last.front, 'malam');
      expect(result.cards.last.back, 'night');
      expect(result.hasInvalid, isFalse);
    });

    test('titik koma setelah pemisah pertama ikut ke sisi belakang', () {
      final result = parseCardLines('a;b;c');

      expect(result.cards.single.front, 'a');
      expect(result.cards.single.back, 'b;c');
    });

    test('melaporkan baris tanpa pemisah atau dengan sisi kosong', () {
      final result = parseCardLines(
        'ok;fine\ntanpa pemisah\n;kekosong\nkosong;',
      );

      expect(result.cards, hasLength(1));
      expect(result.invalidLines, [2, 3, 4]);
    });

    test('input kosong bukan error', () {
      final result = parseCardLines('   \n\n');

      expect(result.cards, isEmpty);
      expect(result.hasInvalid, isFalse);
    });
  });
}
