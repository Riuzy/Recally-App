import { index, integer, real, sqliteTable, text } from 'drizzle-orm/sqlite-core';

/**
 * A deck is a named collection of cards. Rows are soft-deleted so the deletion
 * can be synced later; `dirty` marks local changes that still need pushing.
 */
export const decks = sqliteTable('decks', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  description: text('description'),
  createdAt: integer('created_at', { mode: 'timestamp_ms' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp_ms' }).notNull(),
  deletedAt: integer('deleted_at', { mode: 'timestamp_ms' }),
  dirty: integer('dirty', { mode: 'boolean' }).notNull().default(true),
});

/** A flashcard belonging to a deck. */
export const cards = sqliteTable(
  'cards',
  {
    id: text('id').primaryKey(),
    deckId: text('deck_id')
      .notNull()
      .references(() => decks.id, { onDelete: 'cascade' }),
    front: text('front').notNull(),
    back: text('back').notNull(),
    /** Next time this card is due for review. */
    dueAt: integer('due_at', { mode: 'timestamp_ms' }).notNull(),
    /** Whole days. 0 means the card is in relearning. */
    intervalDays: integer('interval_days').notNull().default(0),
    ease: real('ease').notNull().default(2.5),
    reps: integer('reps').notNull().default(0),
    lapses: integer('lapses').notNull().default(0),
    createdAt: integer('created_at', { mode: 'timestamp_ms' }).notNull(),
    updatedAt: integer('updated_at', { mode: 'timestamp_ms' }).notNull(),
    deletedAt: integer('deleted_at', { mode: 'timestamp_ms' }),
    dirty: integer('dirty', { mode: 'boolean' }).notNull().default(true),
  },
  (table) => [
    index('cards_deck_id_idx').on(table.deckId),
    index('cards_due_at_idx').on(table.dueAt),
  ],
);

/** One graded review. Append-only, so progress history stays trustworthy. */
export const reviews = sqliteTable(
  'reviews',
  {
    id: text('id').primaryKey(),
    cardId: text('card_id')
      .notNull()
      .references(() => cards.id, { onDelete: 'cascade' }),
    /** 0 = lupa, 1 = ragu, 2 = ingat. */
    rating: integer('rating').notNull(),
    reviewedAt: integer('reviewed_at', { mode: 'timestamp_ms' }).notNull(),
    prevIntervalDays: integer('prev_interval_days').notNull(),
    newIntervalDays: integer('new_interval_days').notNull(),
    dirty: integer('dirty', { mode: 'boolean' }).notNull().default(true),
  },
  (table) => [index('reviews_reviewed_at_idx').on(table.reviewedAt)],
);

/** Small key/value store for sync bookkeeping. */
export const syncStates = sqliteTable('sync_states', {
  key: text('key').primaryKey(),
  value: text('value').notNull(),
});

export type Deck = typeof decks.$inferSelect;
export type CardRow = typeof cards.$inferSelect;
export type Review = typeof reviews.$inferSelect;
export type NewDeck = typeof decks.$inferInsert;
export type NewCard = typeof cards.$inferInsert;
export type NewReview = typeof reviews.$inferInsert;

export const schema = { decks, cards, reviews, syncStates };
