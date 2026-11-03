import { eq } from 'drizzle-orm';
import { beforeEach, describe, expect, it } from 'vitest';

import { cards, decks, reviews } from '../src/db/schema';
import type { AppDb } from '../src/db/types';
import {
  createDeck,
  findDeckById,
  getDeckById,
  getDeckOverview,
  softDeleteDeck,
  updateDeck,
} from '../src/features/decks/deckRepository';
import {
  applyReview,
  createCard,
  createManyCards,
  getCardsByDeck,
  getCardsByIds,
  getDueCards,
  getNextDueCard,
  softDeleteCard,
  updateCardContent,
} from '../src/features/study/cardRepository';
import {
  getCardProgress,
  getReviewActivity,
} from '../src/features/progress/progressRepository';
import { getReviewedToday, getStreak } from '../src/features/study/reviewRepository';
import { RecallRating } from '../src/features/study/srsEngine';
import { createTestDb } from './helpers/testDb';

let db: AppDb;

beforeEach(async () => {
  db = await createTestDb();
});

describe('deck repository', () => {
  it('creates, updates, and reads a deck', async () => {
    const id = await createDeck(db, { name: 'Biologi', description: 'Sel' });

    const created = await getDeckById(db, id);
    expect(created?.name).toBe('Biologi');
    expect(created?.description).toBe('Sel');
    expect(created?.dirty).toBe(true);

    await updateDeck(db, { id, name: 'Biologi Sel', description: null });

    const updated = await getDeckById(db, id);
    expect(updated?.name).toBe('Biologi Sel');
    expect(updated?.description).toBeNull();
  });

  it('counts cards and due cards per deck', async () => {
    const now = new Date('2026-06-10T12:00:00.000Z');
    const first = await createDeck(db, { name: 'Satu' });
    const second = await createDeck(db, { name: 'Dua' });

    await db.insert(cards).values([
      {
        id: 'due-1',
        deckId: first,
        front: 'A',
        back: 'B',
        dueAt: new Date(now.getTime() - 60_000),
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'future-1',
        deckId: first,
        front: 'C',
        back: 'D',
        dueAt: new Date(now.getTime() + 60_000),
        createdAt: now,
        updatedAt: now,
      },
    ]);

    const overview = await getDeckOverview(db, now);
    const firstOverview = overview.find((item) => item.deck.id === first);
    const secondOverview = overview.find((item) => item.deck.id === second);

    expect(firstOverview?.cardCount).toBe(2);
    expect(firstOverview?.dueCount).toBe(1);
    expect(secondOverview?.cardCount).toBe(0);
    expect(secondOverview?.dueCount).toBe(0);
  });

  it('soft-deletes the deck and its cards', async () => {
    const deckId = await createDeck(db, { name: 'Sementara' });
    await createCard(db, { deckId, front: 'F', back: 'B' });

    await softDeleteDeck(db, deckId);

    expect(await getDeckById(db, deckId)).toBeNull();
    expect(await getCardsByDeck(db, deckId)).toEqual([]);

    const stored = await findDeckById(db, deckId);
    expect(stored?.deletedAt).toBeInstanceOf(Date);
    expect(stored?.dirty).toBe(true);
  });
});

describe('card repository', () => {
  it('creates cards due immediately, ordered oldest first', async () => {
    const deckId = await createDeck(db, { name: 'Deck' });
    const first = await createCard(db, { deckId, front: 'Satu', back: 'One' });
    const second = await createCard(db, {
      deckId,
      front: 'Dua',
      back: 'Two',
    });

    const rows = await getCardsByDeck(db, deckId);
    expect(rows.map((row) => row.id)).toEqual([first, second]);
    expect(rows.map((row) => row.front)).toEqual(['Satu', 'Dua']);

    const due = await getDueCards(db, new Date(Date.now() + 1_000));
    expect(due.map((row) => row.id)).toEqual([first, second]);
    expect(await getNextDueCard(db, new Date(Date.now() + 10_000))).toBeNull();
  });

  it('imports many cards and returns the created count', async () => {
    const deckId = await createDeck(db, { name: 'Impor' });

    const created = await createManyCards(db, {
      deckId,
      cards: [
        { front: 'pagi', back: 'morning' },
        { front: 'malam', back: 'night' },
      ],
    });

    expect(created).toBe(2);
    const rows = await getCardsByDeck(db, deckId);
    expect(rows).toHaveLength(2);
    expect(new Set(rows.map((row) => row.front))).toEqual(
      new Set(['pagi', 'malam']),
    );
  });

  it('returns zero when importing an empty list', async () => {
    const deckId = await createDeck(db, { name: 'Kosong' });
    expect(await createManyCards(db, { deckId, cards: [] })).toBe(0);
    expect(await getCardsByDeck(db, deckId)).toEqual([]);
  });

  it('updates content and soft-deletes a card', async () => {
    const deckId = await createDeck(db, { name: 'Deck' });
    const cardId = await createCard(db, { deckId, front: 'Lama', back: 'B' });

    await updateCardContent(db, { id: cardId, front: 'Baru', back: 'B2' });
    const [updated] = await getCardsByDeck(db, deckId);
    expect(updated?.front).toBe('Baru');
    expect(updated?.back).toBe('B2');

    await softDeleteCard(db, cardId);
    expect(await getCardsByDeck(db, deckId)).toEqual([]);
    expect(await getCardsByIds(db, [cardId])).toEqual([]);

    const [stored] = await db.select().from(cards).where(eq(cards.id, cardId));
    expect(stored?.deletedAt).toBeInstanceOf(Date);
  });

  it('applies a review and records history atomically', async () => {
    const deckId = await createDeck(db, { name: 'Deck' });
    const cardId = await createCard(db, { deckId, front: 'F', back: 'B' });
    const [card] = await getCardsByDeck(db, deckId);
    const at = new Date('2026-06-10T12:00:00.000Z');

    const outcome = await applyReview(db, {
      card: card!,
      rating: RecallRating.Ingat,
      at,
    });

    expect(outcome.intervalDays).toBe(1);
    expect(outcome.dueAt.getTime()).toBe(at.getTime() + 86_400_000);

    const [storedCard] = await getCardsByDeck(db, deckId);
    expect(storedCard?.intervalDays).toBe(1);
    expect(storedCard?.reps).toBe(1);
    expect(storedCard?.dueAt.getTime()).toBe(outcome.dueAt.getTime());

    const history = await db
      .select()
      .from(reviews)
      .where(eq(reviews.cardId, cardId));
    expect(history).toHaveLength(1);
    expect(history[0]?.rating).toBe(RecallRating.Ingat);
    expect(history[0]?.prevIntervalDays).toBe(0);
    expect(history[0]?.newIntervalDays).toBe(1);
  });

  it('computes streak and reviews today', async () => {
    const deckId = await createDeck(db, { name: 'Deck' });
    const cardId = await createCard(db, { deckId, front: 'F', back: 'B' });
    const now = new Date(2026, 5, 10, 12, 0);

    await db.insert(reviews).values([
      {
        id: 'r1',
        cardId,
        rating: RecallRating.Ingat,
        reviewedAt: new Date(2026, 5, 10, 8, 0),
        prevIntervalDays: 0,
        newIntervalDays: 1,
      },
      {
        id: 'r2',
        cardId,
        rating: RecallRating.Ragu,
        reviewedAt: new Date(2026, 5, 9, 8, 0),
        prevIntervalDays: 1,
        newIntervalDays: 2,
      },
      {
        id: 'r3',
        cardId,
        rating: RecallRating.Ingat,
        reviewedAt: new Date(2026, 5, 8, 8, 0),
        prevIntervalDays: 2,
        newIntervalDays: 5,
      },
    ]);

    expect(await getReviewedToday(db, now)).toBe(1);
    expect(await getStreak(db, now)).toBe(3);
  });
});

describe('progress repository', () => {
  const now = new Date(2026, 5, 10, 12, 0);

  async function seedCards(): Promise<string> {
    const deckId = await createDeck(db, { name: 'Biologi' });
    await db.insert(cards).values([
      {
        id: 'c-fresh',
        deckId,
        front: 'Baru',
        back: 'B',
        dueAt: now,
        intervalDays: 0,
        reps: 0,
        lapses: 0,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'c-learning',
        deckId,
        front: 'Belajar',
        back: 'B',
        dueAt: now,
        intervalDays: 3,
        reps: 2,
        lapses: 1,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'c-mastered',
        deckId,
        front: 'Dikuasai',
        back: 'B',
        dueAt: new Date(now.getTime() + 30 * 86_400_000),
        intervalDays: 30,
        reps: 4,
        lapses: 0,
        createdAt: now,
        updatedAt: now,
      },
    ]);
    return deckId;
  }

  it('classifies fresh, learning, and mastered cards', async () => {
    const deckId = await seedCards();

    const progress = await getCardProgress(db, now);

    expect(progress.total).toBe(3);
    expect(progress.due).toBe(2);
    expect(progress.fresh).toBe(1);
    expect(progress.learning).toBe(1);
    expect(progress.mastered).toBe(1);
    expect(progress.mastery).toBeCloseTo(1 / 3);
    expect(progress.decks).toHaveLength(1);
    expect(progress.decks[0]?.deckId).toBe(deckId);
    expect(progress.decks[0]?.mastered).toBe(1);
  });

  it('ignores soft-deleted cards and decks', async () => {
    const deckId = await seedCards();
    await softDeleteCard(db, 'c-mastered');
    const other = await createDeck(db, { name: 'Terhapus' });
    await createCard(db, { deckId: other, front: 'X', back: 'Y' });
    await softDeleteDeck(db, other);

    const progress = await getCardProgress(db, now);
    expect(progress.total).toBe(2);
    expect(progress.mastered).toBe(0);
    expect(progress.decks).toHaveLength(1);
    expect(progress.decks[0]?.deckId).toBe(deckId);
  });

  it('aggregates weekly activity, retention, and streak', async () => {
    const deckId = await seedCards();
    const insert = (id: string, cardId: string, rating: number, day: number) =>
      db.insert(reviews).values({
        id,
        cardId,
        rating,
        reviewedAt: new Date(2026, 5, day, 18, 0),
        prevIntervalDays: 0,
        newIntervalDays: 1,
      });

    await insert('r1', 'c-fresh', RecallRating.Ingat, 10);
    await insert('r2', 'c-fresh', RecallRating.Ingat, 10);
    await insert('r3', 'c-fresh', RecallRating.Ragu, 9);
    await insert('r4', 'c-fresh', RecallRating.Lupa, 9);
    await insert('r5', 'c-fresh', RecallRating.Ingat, 5);
    await insert('r6', 'c-fresh', RecallRating.Ingat, 2);

    const activity = await getReviewActivity(db, 'week', now);

    expect(deckId).toBeTruthy();
    expect(activity.period).toBe('week');
    expect(activity.days).toHaveLength(7);
    expect(activity.total).toBe(5);
    expect(activity.ingat).toBe(3);
    expect(activity.ragu).toBe(1);
    expect(activity.lupa).toBe(1);
    expect(activity.retention).toBeCloseTo(0.6);
    expect(activity.previousTotal).toBe(1);
    expect(activity.previousRetention).toBe(1);
    expect(activity.retentionDelta).toBeCloseTo(-0.4);
    expect(activity.streak).toBe(2);
    expect(activity.recentDays.map((day) => day.reviews)).toEqual([2, 2, 1]);
    expect(activity.hasAnyReview).toBe(true);
    expect(activity.days.at(-1)?.reviews).toBe(2);
  });

  it('reports no data when no reviews exist', async () => {
    await seedCards();
    const activity = await getReviewActivity(db, 'month', now);

    expect(activity.days).toHaveLength(30);
    expect(activity.total).toBe(0);
    expect(activity.retention).toBeNull();
    expect(activity.hasAnyReview).toBe(false);
    expect(activity.streak).toBe(0);
  });
});

describe('demo-sized dataset', () => {
  it('keeps deck listing stable when a deck has no cards', async () => {
    const deckId = await createDeck(db, { name: 'Kosong' });
    const overview = await getDeckOverview(db);
    expect(overview).toEqual([
      {
        deck: expect.objectContaining({ id: deckId, name: 'Kosong' }),
        cardCount: 0,
        dueCount: 0,
      },
    ]);
    expect(await db.select().from(decks)).toHaveLength(1);
  });
});
