import path from 'node:path';

import { drizzle } from 'drizzle-orm/sql-js';
import initSqlJs from 'sql.js';

import { INIT_SQL } from '../../src/db/migrations';
import { schema } from '../../src/db/schema';
import type { AppDb } from '../../src/db/types';

let sqlModule: Awaited<ReturnType<typeof initSqlJs>> | null = null;

async function loadSql(): Promise<Awaited<ReturnType<typeof initSqlJs>>> {
  if (sqlModule) return sqlModule;
  sqlModule = await initSqlJs({
    locateFile: (file) =>
      path.join(process.cwd(), 'node_modules', 'sql.js', 'dist', file),
  });
  return sqlModule;
}

/** Fresh in-memory SQLite database with the production v1 schema. */
export async function createTestDb(): Promise<AppDb> {
  const SQL = await loadSql();
  const sqlDb = new SQL.Database();
  sqlDb.run(INIT_SQL);

  // sql.js is synchronous; the repositories are typed against expo-sqlite's
  // async dialect. Awaiting a non-promise works identically at runtime.
  return drizzle(sqlDb, { schema }) as unknown as AppDb;
}
