import 'package:flutter_test/flutter_test.dart';
import 'package:recally/features/study/domain/srs_engine.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 8);

  group('SrsEngine - lupa', () {
    test('resets reps, increments lapses, and returns in 10 minutes', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.lupa,
        ease: 2.5,
        intervalDays: 12,
        reps: 3,
        lapses: 1,
        now: now,
      );

      expect(outcome.intervalDays, 0);
      expect(outcome.reps, 0);
      expect(outcome.lapses, 2);
      expect(outcome.ease, closeTo(2.3, 0.0001));
      expect(outcome.dueAt, now.add(const Duration(minutes: 10)));
    });

    test('never drops ease below the minimum', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.lupa,
        ease: SrsEngine.minEase,
        intervalDays: 1,
        reps: 1,
        lapses: 4,
        now: now,
      );

      expect(outcome.ease, SrsEngine.minEase);
    });
  });

  group('SrsEngine - ragu', () {
    test('grows the interval slowly and reduces ease', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.ragu,
        ease: 2.5,
        intervalDays: 10,
        reps: 4,
        lapses: 1,
        now: now,
      );

      expect(outcome.intervalDays, 12);
      expect(outcome.reps, 5);
      expect(outcome.lapses, 1);
      expect(outcome.ease, closeTo(2.35, 0.0001));
      expect(outcome.dueAt, now.add(const Duration(days: 12)));
    });

    test('never returns less than one day', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.ragu,
        ease: 2.5,
        intervalDays: 0,
        reps: 0,
        lapses: 0,
        now: now,
      );

      expect(outcome.intervalDays, 1);
    });
  });

  group('SrsEngine - ingat', () {
    test('first successful review schedules 1 day ahead', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.ingat,
        ease: 2.5,
        intervalDays: 0,
        reps: 0,
        lapses: 0,
        now: now,
      );

      expect(outcome.intervalDays, 1);
      expect(outcome.reps, 1);
      expect(outcome.ease, closeTo(2.6, 0.0001));
      expect(outcome.dueAt, now.add(const Duration(days: 1)));
    });

    test('second successful review schedules 6 days ahead', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.ingat,
        ease: 2.6,
        intervalDays: 1,
        reps: 1,
        lapses: 0,
        now: now,
      );

      expect(outcome.intervalDays, 6);
      expect(outcome.reps, 2);
    });

    test('later reviews multiply the interval by ease', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.ingat,
        ease: 2.5,
        intervalDays: 6,
        reps: 2,
        lapses: 0,
        now: now,
      );

      expect(outcome.intervalDays, 15);
      expect(outcome.reps, 3);
    });

    test('ease never exceeds the maximum', () {
      final outcome = SrsEngine.schedule(
        rating: RecallRating.ingat,
        ease: SrsEngine.maxEase,
        intervalDays: 30,
        reps: 5,
        lapses: 0,
        now: now,
      );

      expect(outcome.ease, SrsEngine.maxEase);
    });
  });

  group('SrsEngine - progression', () {
    test('a card reviewed as ingat three times keeps growing', () {
      var ease = 2.5;
      var interval = 0;
      var reps = 0;
      var lapses = 0;
      var at = now;
      final intervals = <int>[];

      for (var i = 0; i < 3; i++) {
        final outcome = SrsEngine.schedule(
          rating: RecallRating.ingat,
          ease: ease,
          intervalDays: interval,
          reps: reps,
          lapses: lapses,
          now: at,
        );
        intervals.add(outcome.intervalDays);
        ease = outcome.ease;
        interval = outcome.intervalDays;
        reps = outcome.reps;
        lapses = outcome.lapses;
        at = outcome.dueAt;
      }

      expect(intervals, [1, 6, 16]);
      expect(lapses, 0);
    });
  });
}
