import type { ExpoSQLiteDatabase } from 'drizzle-orm/expo-sqlite';

import type { schema } from './schema';

/**
 * The query-builder type used by repositories. Tests substitute a sql.js
 * database cast to this type: both are SQLite dialects with the same builder.
 */
export type AppDb = ExpoSQLiteDatabase<typeof schema>;
