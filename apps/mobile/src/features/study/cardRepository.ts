import { and, asc, eq, gt, inArray, isNull, lte } from 'drizzle-orm';

import type { AppDb } from '../../db/types';
import type { CardRow } from '../../db/schema';
import { cards, reviews } from '../../db/schema';
import { notifyDataChanged } from '../../db/events';
import { withTransaction } from '../../db/transaction';
import { createId } from '../../lib/id';
import type { ScheduleOutcome } from '../study/srsEngine';
import { RecallRating, schedule } from '../study/srsEngine';

/** Cards due for review, earliest first. */
export async function getDueCards(
  db: AppDb,
  at: Date = new Date(),
): Promise<CardRow[]> {
  return db
    .select()
    .from(cards)
    .where(and(isNull(cards.deletedAt), lte(cards.dueAt, at)))
    .orderBy(asc(cards.dueAt));
}

/** Cards of one active deck, oldest first. */
export async function getCardsByDeck(
  db: AppDb,
  deckId: string,
): Promise<CardRow[]> {
  return db
    .select()
    .from(cards)
    .where(and(eq(cards.deckId, deckId), isNull(cards.deletedAt)))
    .orderBy(asc(cards.createdAt));
}

/** Next active card due after `after`. */
export async function getNextDueCard(
  db: AppDb,
  after: Date = new Date(),
): Promise<CardRow | null> {
  const rows = await db
    .select()
    .from(cards)
    .where(and(isNull(cards.deletedAt), gt(cards.dueAt, after)))
    .orderBy(asc(cards.dueAt))
    .limit(1);
  return rows[0] ?? null;
}

export async function countDueCards(
  db: AppDb,
  at: Date = new Date(),
): Promise<number> {
  const rows = await getDueCards(db, at);
  return rows.length;
}

/** Specific active cards, used by "repeat the cards you forgot". */
export async function getCardsByIds(
  db: AppDb,
  ids: string[],
): Promise<CardRow[]> {
  if (ids.length === 0) return [];
  return db
    .select()
    .from(cards)
    .where(and(inArray(cards.id, ids), isNull(cards.deletedAt)))
    .orderBy(asc(cards.createdAt));
}

export async function createCard(
  db: AppDb,
  input: {
    deckId: string;
    front: string;
    back: string;
    dueAt?: Date;
  },
): Promise<string> {
  const now = new Date();
  const id = createId();
  await db.insert(cards).values({
    id,
    deckId: input.deckId,
    front: input.front,
    back: input.back,
    dueAt: input.dueAt ?? now,
    createdAt: now,
    updatedAt: now,
    dirty: true,
  });
  notifyDataChanged();
  return id;
}

/** Inserts many cards in one batch; used by the paste-many flow. */
export async function createManyCards(
  db: AppDb,
  input: {
    deckId: string;
    cards: { front: string; back: string }[];
    dueAt?: Date;
  },
): Promise<number> {
  if (input.cards.length === 0) return 0;

  const now = new Date();
  const due = input.dueAt ?? now;

  await withTransaction(db, async () => {
    for (const card of input.cards) {
      await db.insert(cards).values({
        id: createId(),
        deckId: input.deckId,
        front: card.front,
        back: card.back,
        dueAt: due,
        createdAt: now,
        updatedAt: now,
        dirty: true,
      });
    }
  });
  notifyDataChanged();
  return input.cards.length;
}

export async function updateCardContent(
  db: AppDb,
  input: { id: string; front: string; back: string },
): Promise<void> {
  await db
    .update(cards)
    .set({
      front: input.front,
      back: input.back,
      updatedAt: new Date(),
      dirty: true,
    })
    .where(eq(cards.id, input.id));
  notifyDataChanged();
}

export async function softDeleteCard(db: AppDb, id: string): Promise<void> {
  const now = new Date();
  await db
    .update(cards)
    .set({ deletedAt: now, updatedAt: now, dirty: true })
    .where(eq(cards.id, id));
  notifyDataChanged();
}

/**
 * Applies a grade to `card`: updates the schedule and records the review in one
 * transaction, so history can never disagree with card state.
 */
export async function applyReview(
  db: AppDb,
  input: { card: CardRow; rating: RecallRating; at?: Date },
): Promise<ScheduleOutcome> {
  const now = input.at ?? new Date();
  const outcome = schedule({
    rating: input.rating,
    ease: input.card.ease,
    intervalDays: input.card.intervalDays,
    reps: input.card.reps,
    lapses: input.card.lapses,
    now,
  });

  await withTransaction(db, async () => {
    await db
      .update(cards)
      .set({
        dueAt: outcome.dueAt,
        intervalDays: outcome.intervalDays,
        ease: outcome.ease,
        reps: outcome.reps,
        lapses: outcome.lapses,
        updatedAt: now,
        dirty: true,
      })
      .where(eq(cards.id, input.card.id));

    await db.insert(reviews).values({
      id: createId(),
      cardId: input.card.id,
      rating: input.rating,
      reviewedAt: now,
      prevIntervalDays: input.card.intervalDays,
      newIntervalDays: outcome.intervalDays,
      dirty: true,
    });
  });

  notifyDataChanged();
  return outcome;
}
