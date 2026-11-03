function dayKey(date: Date): number {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
}

function shiftDay(date: Date, days: number): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days);
}

/**
 * Counts consecutive days with at least one review.
 *
 * Today counts when reviewed today. When today has no review yet, yesterday's
 * streak is still alive because the day is not over.
 */
export function computeStreak(
  reviewedAt: Iterable<Date>,
  now: Date = new Date(),
): number {
  const days = new Set<number>();
  for (const value of reviewedAt) days.add(dayKey(value));
  if (days.size === 0) return 0;

  let cursor = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (!days.has(cursor.getTime())) {
    cursor = shiftDay(cursor, -1);
    if (!days.has(cursor.getTime())) return 0;
  }

  let streak = 0;
  while (days.has(cursor.getTime())) {
    streak += 1;
    cursor = shiftDay(cursor, -1);
  }
  return streak;
}
