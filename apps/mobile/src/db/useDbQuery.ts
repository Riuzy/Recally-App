import { useCallback, useEffect, useRef, useState } from 'react';

import { useDataVersion } from './events';
import { useDb } from './provider';
import type { AppDb } from './types';

export interface DbQueryResult<T> {
  data: T | null;
  error: Error | null;
  loading: boolean;
  reload: () => void;
}

/**
 * Re-runs an async repository read whenever the data version changes. Screens
 * stay reactive without a third-party cache: repositories call
 * `notifyDataChanged` after writes.
 *
 * A version change refreshes in the background (previous data stays visible);
 * `reload` shows the loading state because the user explicitly asked for it.
 */
export function useDbQuery<T>(
  loader: (db: AppDb) => Promise<T>,
  dependencies: readonly unknown[] = [],
): DbQueryResult<T> {
  const db = useDb();
  const version = useDataVersion();
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(true);
  const [reloadToken, setReloadToken] = useState(0);
  const loaderRef = useRef(loader);

  // Keep the latest loader without making inline arrow functions a dependency.
  useEffect(() => {
    loaderRef.current = loader;
  });

  useEffect(() => {
    let cancelled = false;

    loaderRef
      .current(db)
      .then((result) => {
        if (cancelled) return;
        setData(result);
        setError(null);
        setLoading(false);
      })
      .catch((cause: unknown) => {
        if (cancelled) return;
        setError(cause instanceof Error ? cause : new Error(String(cause)));
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [db, version, reloadToken, ...dependencies]);

  const reload = useCallback(() => {
    setLoading(true);
    setError(null);
    setReloadToken((value) => value + 1);
  }, []);

  return { data, error, loading, reload };
}
