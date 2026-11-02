import 'package:flutter_test/flutter_test.dart';
import 'package:recally/features/study/domain/streak.dart';

void main() {
  final now = DateTime(2026, 11, 3, 20, 30);

  test('kosong berarti belum ada rentetan', () {
    expect(computeStreak([], now: now), 0);
  });

  test('hari ini dan kemarin berurutan', () {
    final streak = computeStreak([
      now,
      DateTime(2026, 11, 2, 9),
      DateTime(2026, 11, 1, 22),
    ], now: now);

    expect(streak, 3);
  });

  test('kemarin saja masih dihitung karena hari belum berakhir', () {
    final streak = computeStreak([DateTime(2026, 11, 2, 8)], now: now);

    expect(streak, 1);
  });

  test('dua hari lalu tanpa kemarin memutus rentetan', () {
    final streak = computeStreak([
      DateTime(2026, 11, 1, 8),
      DateTime(2026, 10, 31, 8),
    ], now: now);

    expect(streak, 0);
  });

  test('beberapa ulasan di hari yang sama dihitung sekali', () {
    final streak = computeStreak([
      now,
      DateTime(2026, 11, 3, 6),
      DateTime(2026, 11, 2, 6),
    ], now: now);

    expect(streak, 2);
  });

  test('rentetan berhenti pada hari yang bolong', () {
    final streak = computeStreak([
      now,
      DateTime(2026, 11, 2, 9),
      DateTime(2026, 10, 31, 9),
    ], now: now);

    expect(streak, 2);
  });

  test('hari ini saja', () {
    expect(computeStreak([DateTime(2026, 11, 3, 0, 1)], now: now), 1);
  });
}
