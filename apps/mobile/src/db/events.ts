import { useSyncExternalStore } from 'react';

/**
 * Minimal change signal. Repositories bump this after every write; screens
 * subscribe through `useDbQuery` and re-run their loader.
 */
let version = 0;
const listeners = new Set<() => void>();

export function notifyDataChanged(): void {
  version += 1;
  for (const listener of listeners) listener();
}

export function subscribeToData(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function currentDataVersion(): number {
  return version;
}

export function useDataVersion(): number {
  return useSyncExternalStore(
    subscribeToData,
    currentDataVersion,
    currentDataVersion,
  );
}
