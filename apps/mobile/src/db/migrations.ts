/**
 * Schema v1. The app ships with one local-first schema; the raw statements are
 * kept here so they can run on expo-sqlite (native + web) and in tests.
 */
export const SCHEMA_VERSION = 1;

export const INIT_SQL = `
CREATE TABLE IF NOT EXISTS decks (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  dirty INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS cards (
  id TEXT PRIMARY KEY NOT NULL,
  deck_id TEXT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  due_at INTEGER NOT NULL,
  interval_days INTEGER NOT NULL DEFAULT 0,
  ease REAL NOT NULL DEFAULT 2.5,
  reps INTEGER NOT NULL DEFAULT 0,
  lapses INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  dirty INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS cards_deck_id_idx ON cards (deck_id);
CREATE INDEX IF NOT EXISTS cards_due_at_idx ON cards (due_at);

CREATE TABLE IF NOT EXISTS reviews (
  id TEXT PRIMARY KEY NOT NULL,
  card_id TEXT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL,
  reviewed_at INTEGER NOT NULL,
  prev_interval_days INTEGER NOT NULL,
  new_interval_days INTEGER NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS reviews_reviewed_at_idx ON reviews (reviewed_at);

CREATE TABLE IF NOT EXISTS sync_states (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
);
`;
