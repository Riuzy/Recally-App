import { drizzle } from 'drizzle-orm/expo-sqlite';
import { SQLiteProvider, useSQLiteContext } from 'expo-sqlite';
import type { SQLiteDatabase } from 'expo-sqlite';
import {
  createContext,
  useContext,
  useMemo,
  type PropsWithChildren,
} from 'react';

import { INIT_SQL, SCHEMA_VERSION } from './migrations';
import { schema } from './schema';
import type { AppDb } from './types';

const DbContext = createContext<AppDb | null>(null);

async function migrate(database: SQLiteDatabase): Promise<void> {
  await database.execAsync('PRAGMA foreign_keys = ON');

  const row = await database.getFirstAsync<{ user_version: number }>(
    'PRAGMA user_version',
  );
  const currentVersion = row?.user_version ?? 0;

  if (currentVersion < SCHEMA_VERSION) {
    await database.execAsync(INIT_SQL);
    await database.execAsync(`PRAGMA user_version = ${SCHEMA_VERSION}`);
  }
}

function DbBridge({ children }: PropsWithChildren): React.JSX.Element {
  const sqlite = useSQLiteContext();
  const db = useMemo(() => drizzle(sqlite, { schema }), [sqlite]);

  return <DbContext.Provider value={db}>{children}</DbContext.Provider>;
}

/** Opens the local database and applies the schema before children mount. */
export function DatabaseProvider({
  children,
}: PropsWithChildren): React.JSX.Element {
  return (
    <SQLiteProvider databaseName="recally.db" onInit={migrate}>
      <DbBridge>{children}</DbBridge>
    </SQLiteProvider>
  );
}

export function useDb(): AppDb {
  const db = useContext(DbContext);
  if (!db) throw new Error('useDb must be used inside DatabaseProvider');
  return db;
}
