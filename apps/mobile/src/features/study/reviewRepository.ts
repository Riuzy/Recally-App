import { eq } from 'drizzle-orm';

import type { AppDb } from '../../db/types';
import { reviews } from '../../db/schema';
import { computeStreak } from './streak';

export async function getStreak(
  db: AppDb,
  now: Date = new Date(),
): Promise<number> {
  const rows = await db.select({ reviewedAt: reviews.reviewedAt }).from(reviews);
  return computeStreak(
    rows.map((row) => row.reviewedAt),
    now,
  );
}

export async function getReviewedToday(
  db: AppDb,
  now: Date = new Date(),
): Promise<number> {
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const end = new Date(start.getTime() + 86_400_000);
  const rows = await db.select({ reviewedAt: reviews.reviewedAt }).from(reviews);
  return rows.filter((row) => {
    const time = row.reviewedAt.getTime();
    return time >= start.getTime() && time < end.getTime();
  }).length;
}

export async function deleteReview(db: AppDb, id: string): Promise<void> {
  await db.delete(reviews).where(eq(reviews.id, id));
}
