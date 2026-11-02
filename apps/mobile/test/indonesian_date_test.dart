import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/format/indonesian_date.dart';

void main() {
  test('formatLongDate memakai nama hari dan bulan Indonesia', () {
    expect(formatLongDate(DateTime(2026, 11, 3)), 'Selasa, 3 November');
    expect(formatLongDate(DateTime(2026, 1, 1)), 'Kamis, 1 Januari');
  });

  test('formatDueLabel membedakan hari ini, besok, dan tanggal lain', () {
    final now = DateTime(2026, 11, 3, 10, 0);

    expect(
      formatDueLabel(DateTime(2026, 11, 3, 19, 30), now: now),
      'Hari ini, 19:30',
    );
    expect(
      formatDueLabel(DateTime(2026, 11, 4, 8, 5), now: now),
      'Besok, 08:05',
    );
    expect(
      formatDueLabel(DateTime(2026, 11, 12, 8, 15), now: now),
      '12 November, 08:15',
    );
  });

  test('formatDueLabel menangani pergantian bulan', () {
    final now = DateTime(2026, 12, 31, 22, 0);

    expect(
      formatDueLabel(DateTime(2027, 1, 1, 0, 30), now: now),
      'Besok, 00:30',
    );
  });
}
