import { and, eq, isNull } from 'drizzle-orm';

import type { AppDb } from '../../db/types';
import { cards, decks, reviews } from '../../db/schema';
import type { RecallRating } from '../study/srsEngine';
import { computeStreak } from '../study/streak';
import type {
  CardProgress,
  DayActivity,
  DayReviewSummary,
  ProgressPeriod,
  ReviewActivity,
} from './progressStats';
import {
  createCardProgress,
  createReviewActivity,
  MASTERED_INTERVAL_DAYS,
  PROGRESS_PERIODS,
} from './progressStats';

function dayKey(date: Date): number {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
}

function shiftDay(date: Date, days: number): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days);
}

export async function getCardProgress(
  db: AppDb,
  now: Date = new Date(),
): Promise<CardProgress> {
  const rows = await db
    .select({ card: cards, deck: decks })
    .from(cards)
    .innerJoin(decks, eq(decks.id, cards.deckId))
    .where(and(isNull(cards.deletedAt), isNull(decks.deletedAt)));

  interface Builder {
    deckId: string;
    name: string;
    total: number;
    mastered: number;
    learning: number;
    fresh: number;
    due: number;
  }

  const builders = new Map<string, Builder>();
  for (const row of rows) {
    const builder =
      builders.get(row.deck.id) ??
      {
        deckId: row.deck.id,
        name: row.deck.name,
        total: 0,
        mastered: 0,
        learning: 0,
        fresh: 0,
        due: 0,
      };

    builder.total += 1;
    if (row.card.dueAt.getTime() <= now.getTime()) builder.due += 1;

    if (row.card.intervalDays >= MASTERED_INTERVAL_DAYS) {
      builder.mastered += 1;
    } else if (row.card.reps === 0 && row.card.lapses === 0) {
      builder.fresh += 1;
    } else {
      builder.learning += 1;
    }

    builders.set(row.deck.id, builder);
  }

  const totals = { total: 0, due: 0, mastered: 0, learning: 0, fresh: 0 };
  const deckProgress = [];
  for (const builder of builders.values()) {
    totals.total += builder.total;
    totals.due += builder.due;
    totals.mastered += builder.mastered;
    totals.learning += builder.learning;
    totals.fresh += builder.fresh;
    deckProgress.push({
      deckId: builder.deckId,
      name: builder.name,
      total: builder.total,
      mastered: builder.mastered,
      due: builder.due,
    });
  }

  return createCardProgress({ ...totals, decks: deckProgress });
}

export async function getReviewActivity(
  db: AppDb,
  period: ProgressPeriod,
  now: Date = new Date(),
): Promise<ReviewActivity> {
  const rows = await db
    .select({ reviewedAt: reviews.reviewedAt, rating: reviews.rating })
    .from(reviews);

  const spec = PROGRESS_PERIODS[period];
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const currentStart = shiftDay(today, -(spec.days - 1));
  const previousStart = shiftDay(currentStart, -spec.days);

  const dayCounts = new Map<number, number>();
  const summaries = new Map<number, { day: Date; reviews: number; ingat: number }>();
  const timestamps: Date[] = [];
  const counts: Record<RecallRating, number> = { 0: 0, 1: 0, 2: 0 };

  let previousTotal = 0;
  let previousIngat = 0;

  for (const row of rows) {
    const rating = row.rating;
    if (rating < 0 || rating > 2) continue;
    const reviewedAt = row.reviewedAt;
    const key = dayKey(reviewedAt);

    timestamps.push(reviewedAt);
    const summary =
      summaries.get(key) ??
      { day: new Date(key), reviews: 0, ingat: 0 };
    summary.reviews += 1;
    if (rating === 2) summary.ingat += 1;
    summaries.set(key, summary);

    const isCurrent =
      reviewedAt.getTime() >= currentStart.getTime() &&
      reviewedAt.getTime() <= today.getTime() + 86_400_000 - 1;

    if (isCurrent) {
      dayCounts.set(key, (dayCounts.get(key) ?? 0) + 1);
      counts[rating as RecallRating] += 1;
    } else if (
      reviewedAt.getTime() >= previousStart.getTime() &&
      reviewedAt.getTime() < currentStart.getTime()
    ) {
      previousTotal += 1;
      if (rating === 2) previousIngat += 1;
    }
  }

  const days: DayActivity[] = [];
  for (let index = 0; index < spec.days; index += 1) {
    const day = shiftDay(currentStart, index);
    days.push({ day, reviews: dayCounts.get(day.getTime()) ?? 0 });
  }

  const recentDays: DayReviewSummary[] = [...summaries.values()]
    .map((summary) => ({ ...summary }))
    .sort((a, b) => b.day.getTime() - a.day.getTime())
    .slice(0, 3);

  return createReviewActivity({
    period,
    days,
    counts,
    previousTotal,
    previousIngat,
    streak: computeStreak(timestamps, now),
    recentDays,
    hasAnyReview: rows.length > 0,
  });
}
