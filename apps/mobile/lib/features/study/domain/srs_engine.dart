import 'dart:math' as math;

/// How well the user remembered a card.
enum RecallRating {
  /// "Lupa" — completely forgot. Card goes back into relearning.
  lupa,

  /// "Ragu" — recalled with difficulty. Interval grows slowly.
  ragu,

  /// "Ingat" — recalled easily. Interval grows by the ease factor.
  ingat,
}

/// The scheduling state produced after a review.
class ScheduleOutcome {
  const ScheduleOutcome({
    required this.dueAt,
    required this.intervalDays,
    required this.ease,
    required this.reps,
    required this.lapses,
  });

  final DateTime dueAt;
  final int intervalDays;
  final double ease;
  final int reps;
  final int lapses;

  @override
  String toString() =>
      'ScheduleOutcome(dueAt: $dueAt, intervalDays: $intervalDays, '
      'ease: $ease, reps: $reps, lapses: $lapses)';
}

/// Spaced repetition scheduler (SM-2 variant with three grades).
///
/// Pure functions only: no database, no clock, no side effects. This keeps the
/// most important logic in the app trivially testable.
abstract final class SrsEngine {
  /// Ease never drops below this, otherwise intervals collapse to 1 day forever.
  static const double minEase = 1.3;

  /// Upper bound keeps "ingat" from producing absurd intervals.
  static const double maxEase = 3.0;

  /// How long a forgotten card waits before it is shown again in the same session.
  static const Duration relearnDelay = Duration(minutes: 10);

  static const double _lupaPenalty = 0.20;
  static const double _raguPenalty = 0.15;
  static const double _ingatBonus = 0.10;
  static const double _raguGrowth = 1.2;

  /// Computes the next state for a card.
  ///
  /// [now] is injected instead of read from the clock so tests are deterministic.
  static ScheduleOutcome schedule({
    required RecallRating rating,
    required double ease,
    required int intervalDays,
    required int reps,
    required int lapses,
    required DateTime now,
  }) {
    switch (rating) {
      case RecallRating.lupa:
        return ScheduleOutcome(
          dueAt: now.add(relearnDelay),
          intervalDays: 0,
          ease: _clampEase(ease - _lupaPenalty),
          reps: 0,
          lapses: lapses + 1,
        );

      case RecallRating.ragu:
        final nextInterval = math.max(1, (intervalDays * _raguGrowth).round());
        return ScheduleOutcome(
          dueAt: now.add(Duration(days: nextInterval)),
          intervalDays: nextInterval,
          ease: _clampEase(ease - _raguPenalty),
          reps: reps + 1,
          lapses: lapses,
        );

      case RecallRating.ingat:
        final nextInterval = switch (reps) {
          0 => 1,
          1 => 6,
          _ => math.max(1, (intervalDays * _clampEase(ease)).round()),
        };
        return ScheduleOutcome(
          dueAt: now.add(Duration(days: nextInterval)),
          intervalDays: nextInterval,
          ease: _clampEase(ease + _ingatBonus),
          reps: reps + 1,
          lapses: lapses,
        );
    }
  }

  static double _clampEase(double ease) =>
      ease.clamp(minEase, maxEase).toDouble();
}
