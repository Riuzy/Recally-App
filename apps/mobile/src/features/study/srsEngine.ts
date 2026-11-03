/** How well the user remembered a card. */
export const RecallRating = {
  Lupa: 0,
  Ragu: 1,
  Ingat: 2,
} as const;

// The const and type intentionally share a name so callers get both.
// eslint-disable-next-line @typescript-eslint/no-redeclare
export type RecallRating =
  (typeof RecallRating)[keyof typeof RecallRating];

export const RECALL_RATINGS: readonly RecallRating[] = [
  RecallRating.Lupa,
  RecallRating.Ragu,
  RecallRating.Ingat,
];

export function ratingLabel(rating: RecallRating): string {
  switch (rating) {
    case RecallRating.Lupa:
      return 'Lupa';
    case RecallRating.Ragu:
      return 'Ragu';
    case RecallRating.Ingat:
      return 'Ingat';
  }
}

export interface ScheduleOutcome {
  dueAt: Date;
  intervalDays: number;
  ease: number;
  reps: number;
  lapses: number;
}

const MIN_EASE = 1.3;
const MAX_EASE = 3.0;
const RELEARN_MINUTES = 10;
const LUPA_PENALTY = 0.2;
const RAGU_PENALTY = 0.15;
const INGAT_BONUS = 0.1;
const RAGU_GROWTH = 1.2;

function clampEase(ease: number): number {
  return Math.min(MAX_EASE, Math.max(MIN_EASE, ease));
}

/**
 * Spaced repetition scheduler (SM-2 variant with three grades).
 * Pure: the caller injects `now`, so tests stay deterministic.
 */
export function schedule({
  rating,
  ease,
  intervalDays,
  reps,
  lapses,
  now,
}: {
  rating: RecallRating;
  ease: number;
  intervalDays: number;
  reps: number;
  lapses: number;
  now: Date;
}): ScheduleOutcome {
  switch (rating) {
    case RecallRating.Lupa:
      return {
        dueAt: new Date(now.getTime() + RELEARN_MINUTES * 60_000),
        intervalDays: 0,
        ease: clampEase(ease - LUPA_PENALTY),
        reps: 0,
        lapses: lapses + 1,
      };

    case RecallRating.Ragu: {
      const nextInterval = Math.max(1, Math.round(intervalDays * RAGU_GROWTH));
      return {
        dueAt: new Date(now.getTime() + nextInterval * 86_400_000),
        intervalDays: nextInterval,
        ease: clampEase(ease - RAGU_PENALTY),
        reps: reps + 1,
        lapses,
      };
    }

    case RecallRating.Ingat: {
      const nextInterval =
        reps === 0
          ? 1
          : reps === 1
            ? 6
            : Math.max(1, Math.round(intervalDays * clampEase(ease)));
      return {
        dueAt: new Date(now.getTime() + nextInterval * 86_400_000),
        intervalDays: nextInterval,
        ease: clampEase(ease + INGAT_BONUS),
        reps: reps + 1,
        lapses,
      };
    }
  }
}
