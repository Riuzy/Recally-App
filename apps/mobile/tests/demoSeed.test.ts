import { beforeEach, describe, expect, it } from 'vitest';

import { cards, decks, reviews } from '../src/db/schema';
import type { AppDb } from '../src/db/types';
import {
  DEMO_DECK_ID,
  DEMO_DECK_NAME,
  seedDemoData,
} from '../src/features/dev/demoSeed';
import { createDeck, getDeckOverview } from '../src/features/decks/deckRepository';
import { getCardProgress } from '../src/features/progress/progressRepository';
import { getReviewActivity } from '../src/features/progress/progressRepository';
import { getStreak } from '../src/features/study/reviewRepository';
import { createTestDb } from './helpers/testDb';

const now = new Date(2026, 5, 10, 15, 0);
let db: AppDb;

beforeEach(async () => {
  db = await createTestDb();
});

describe('seedDemoData', () => {
  it('creates the demo deck, twelve cards, and two weeks of reviews', async () => {
    const created = await seedDemoData(db, now);

    expect(created).toBe(true);
    expect(await db.select().from(decks)).toHaveLength(1);
    expect(await db.select().from(cards)).toHaveLength(12);
    expect(await db.select().from(reviews)).toHaveLength(14);

    const [deck] = await db.select().from(decks);
    expect(deck?.id).toBe(DEMO_DECK_ID);
    expect(deck?.name).toBe(DEMO_DECK_NAME);
    expect(deck?.dirty).toBe(false);
  });

  it('is idempotent and never duplicates rows', async () => {
    expect(await seedDemoData(db, now)).toBe(true);
    expect(await seedDemoData(db, now)).toBe(false);
    expect(await db.select().from(cards)).toHaveLength(12);
    expect(await db.select().from(reviews)).toHaveLength(14);
  });

  it('leaves user decks untouched', async () => {
    const userId = await createDeck(db, { name: 'Deck pribadi' });
    await seedDemoData(db, now);

    const overview = await getDeckOverview(db, now);
    expect(overview.map((item) => item.deck.id)).toContain(userId);
    expect(overview).toHaveLength(2);

    const userDeck = overview.find((item) => item.deck.id === userId);
    expect(userDeck?.cardCount).toBe(0);
    expect(userDeck?.deck.dirty).toBe(true);
  });

  it('marks demo rows clean for a future sync', async () => {
    await seedDemoData(db, now);

    const demoCards = await db.select().from(cards);
    const demoReviews = await db.select().from(reviews);

    expect(demoCards.every((card) => card.dirty === false)).toBe(true);
    expect(demoReviews.every((review) => review.dirty === false)).toBe(true);
  });

  it('produces the intended local dashboard numbers', async () => {
    await seedDemoData(db, now);

    const overview = await getDeckOverview(db, now);
    expect(overview[0]?.cardCount).toBe(12);
    expect(overview[0]?.dueCount).toBe(4);

    const progress = await getCardProgress(db, now);
    expect(progress.total).toBe(12);
    expect(progress.mastered).toBe(2);
    expect(progress.fresh).toBe(2);
    expect(progress.learning).toBe(8);
    expect(progress.due).toBe(4);

    expect(await getStreak(db, now)).toBe(5);
  });

  it('fills the weekly progress chart with a comparable previous week', async () => {
    await seedDemoData(db, now);

    const week = await getReviewActivity(db, 'week', now);
    expect(week.total).toBe(12);
    expect(week.ingat).toBe(9);
    expect(week.ragu).toBe(2);
    expect(week.lupa).toBe(1);
    expect(week.retention).toBeCloseTo(0.75);
    expect(week.previousTotal).toBe(2);
    expect(week.previousRetention).toBeCloseTo(0.5);
    expect(week.retentionDelta).toBeCloseTo(0.25);
    expect(week.days).toHaveLength(7);
    expect(week.days.reduce((sum, day) => sum + day.reviews, 0)).toBe(12);
    expect(week.hasAnyReview).toBe(true);
  });
});
