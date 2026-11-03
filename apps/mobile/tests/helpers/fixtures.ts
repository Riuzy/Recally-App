import type { CardRow, Deck } from '../../src/db/schema';

export function makeCard(overrides: Partial<CardRow> = {}): CardRow {
  const now = new Date('2026-01-01T09:00:00.000Z');
  return {
    id: 'card-1',
    deckId: 'deck-1',
    front: 'Depan',
    back: 'Belakang',
    dueAt: now,
    intervalDays: 0,
    ease: 2.5,
    reps: 0,
    lapses: 0,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    dirty: true,
    ...overrides,
  };
}

export function makeDeck(overrides: Partial<Deck> = {}): Deck {
  const now = new Date('2026-01-01T09:00:00.000Z');
  return {
    id: 'deck-1',
    name: 'Deck',
    description: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    dirty: true,
    ...overrides,
  };
}
