import { and, asc, desc, eq, isNull } from 'drizzle-orm';

import type { AppDb } from '../../db/types';
import { cards, decks } from '../../db/schema';
import type { Deck } from '../../db/schema';
import { notifyDataChanged } from '../../db/events';
import { withTransaction } from '../../db/transaction';
import { createId } from '../../lib/id';

export interface DeckOverview {
  deck: Deck;
  cardCount: number;
  dueCount: number;
}

/** Every active deck, newest change first. */
export async function getDecks(db: AppDb): Promise<Deck[]> {
  return db
    .select()
    .from(decks)
    .where(isNull(decks.deletedAt))
    .orderBy(desc(decks.updatedAt));
}

/**
 * Decks plus card counts in one query. A left join keeps empty decks visible;
 * grouping in JS preserves the updatedAt ordering.
 */
export async function getDeckOverview(
  db: AppDb,
  now: Date = new Date(),
): Promise<DeckOverview[]> {
  const rows = await db
    .select({ deck: decks, card: cards })
    .from(decks)
    .leftJoin(
      cards,
      and(eq(cards.deckId, decks.id), isNull(cards.deletedAt)),
    )
    .where(isNull(decks.deletedAt))
    .orderBy(desc(decks.updatedAt));

  const builders = new Map<string, DeckOverview>();
  for (const row of rows) {
    const current =
      builders.get(row.deck.id) ??
      {
        deck: row.deck,
        cardCount: 0,
        dueCount: 0,
      };
    if (row.card) {
      current.cardCount += 1;
      if (row.card.dueAt.getTime() <= now.getTime()) current.dueCount += 1;
    }
    builders.set(row.deck.id, current);
  }

  return [...builders.values()];
}

export async function getDeckById(
  db: AppDb,
  id: string,
): Promise<Deck | null> {
  const rows = await db
    .select()
    .from(decks)
    .where(and(eq(decks.id, id), isNull(decks.deletedAt)))
    .limit(1);
  return rows[0] ?? null;
}

export async function findDeckById(
  db: AppDb,
  id: string,
): Promise<Deck | null> {
  const rows = await db.select().from(decks).where(eq(decks.id, id)).limit(1);
  return rows[0] ?? null;
}

export async function createDeck(
  db: AppDb,
  input: { name: string; description?: string | null },
): Promise<string> {
  const now = new Date();
  const id = createId();
  await db.insert(decks).values({
    id,
    name: input.name,
    description: input.description ?? null,
    createdAt: now,
    updatedAt: now,
    dirty: true,
  });
  notifyDataChanged();
  return id;
}

export async function updateDeck(
  db: AppDb,
  input: { id: string; name: string; description?: string | null },
): Promise<void> {
  await db
    .update(decks)
    .set({
      name: input.name,
      description: input.description ?? null,
      updatedAt: new Date(),
      dirty: true,
    })
    .where(eq(decks.id, input.id));
  notifyDataChanged();
}

/** Soft-deletes the deck and its cards so the deletion can be synced later. */
export async function softDeleteDeck(db: AppDb, id: string): Promise<void> {
  const now = new Date();
  await withTransaction(db, async () => {
    await db
      .update(decks)
      .set({ deletedAt: now, updatedAt: now, dirty: true })
      .where(eq(decks.id, id));
    await db
      .update(cards)
      .set({ deletedAt: now, updatedAt: now, dirty: true })
      .where(eq(cards.deckId, id));
  });
  notifyDataChanged();
}

/** Cards of one active deck, oldest first. */
export async function getCardsByDeck(
  db: AppDb,
  deckId: string,
): Promise<import('../../db/schema').CardRow[]> {
  return db
    .select()
    .from(cards)
    .where(and(eq(cards.deckId, deckId), isNull(cards.deletedAt)))
    .orderBy(asc(cards.createdAt));
}
