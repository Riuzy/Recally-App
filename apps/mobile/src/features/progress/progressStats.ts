import type { RecallRating } from '../study/srsEngine';

/**
 * Interval (days) considered "mastered". Cards scheduled three weeks out no
 * longer count as daily study load.
 */
export const MASTERED_INTERVAL_DAYS = 21;

export type ProgressPeriod = 'week' | 'month';

export interface PeriodSpec {
  days: number;
  label: string;
  comparisonLabel: string;
}

export const PROGRESS_PERIODS: Record<ProgressPeriod, PeriodSpec> = {
  week: { days: 7, label: 'Minggu ini', comparisonLabel: 'minggu sebelumnya' },
  month: { days: 30, label: '30 hari', comparisonLabel: '30 hari sebelumnya' },
};

export interface DeckProgress {
  deckId: string;
  name: string;
  total: number;
  mastered: number;
  due: number;
  mastery: number;
}

export interface CardProgress {
  total: number;
  due: number;
  mastered: number;
  learning: number;
  fresh: number;
  mastery: number;
  /** Sorted by card count, descending. */
  decks: DeckProgress[];
}

export interface DayActivity {
  day: Date;
  reviews: number;
}

export interface DayReviewSummary {
  day: Date;
  reviews: number;
  ingat: number;
}

export interface ReviewActivity {
  period: ProgressPeriod;
  days: DayActivity[];
  total: number;
  ingat: number;
  ragu: number;
  lupa: number;
  previousTotal: number;
  previousIngat: number;
  streak: number;
  recentDays: DayReviewSummary[];
  hasAnyReview: boolean;
  /** Ingat share of all reviews in the period; null when there are none. */
  retention: number | null;
  previousRetention: number | null;
  /** Difference in share (0.06 means +6 points); null when incomparable. */
  retentionDelta: number | null;
}

export function createCardProgress(input: {
  total: number;
  due: number;
  mastered: number;
  learning: number;
  fresh: number;
  decks: Omit<DeckProgress, 'mastery'>[];
}): CardProgress {
  return {
    ...input,
    mastery: input.total === 0 ? 0 : input.mastered / input.total,
    decks: input.decks
      .map((deck) => ({
        ...deck,
        mastery: deck.total === 0 ? 0 : deck.mastered / deck.total,
      }))
      .sort((a, b) =>
        b.total !== a.total ? b.total - a.total : a.name.localeCompare(b.name),
      ),
  };
}

export function createReviewActivity(input: {
  period: ProgressPeriod;
  days: DayActivity[];
  counts: Record<RecallRating, number>;
  previousTotal: number;
  previousIngat: number;
  streak: number;
  recentDays: DayReviewSummary[];
  hasAnyReview: boolean;
}): ReviewActivity {
  const { counts } = input;
  const total = counts[0] + counts[1] + counts[2];
  const retention = total === 0 ? null : counts[2] / total;
  const previousRetention =
    input.previousTotal === 0 ? null : input.previousIngat / input.previousTotal;

  return {
    period: input.period,
    days: input.days,
    total,
    ingat: counts[2],
    ragu: counts[1],
    lupa: counts[0],
    previousTotal: input.previousTotal,
    previousIngat: input.previousIngat,
    streak: input.streak,
    recentDays: input.recentDays,
    hasAnyReview: input.hasAnyReview,
    retention,
    previousRetention,
    retentionDelta:
      retention === null || previousRetention === null
        ? null
        : retention - previousRetention,
  };
}
