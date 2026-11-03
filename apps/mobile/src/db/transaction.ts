import { sql } from 'drizzle-orm';

import type { AppDb } from './types';

/**
 * Explicit BEGIN / COMMIT keeps transactions identical on expo-sqlite and the
 * sql.js test double (whose drizzle transaction helper is synchronous).
 */
export async function withTransaction<T>(
  db: AppDb,
  work: () => Promise<T>,
): Promise<T> {
  await db.run(sql`BEGIN`);
  try {
    const result = await work();
    await db.run(sql`COMMIT`);
    return result;
  } catch (error) {
    await db.run(sql`ROLLBACK`);
    throw error;
  }
}
