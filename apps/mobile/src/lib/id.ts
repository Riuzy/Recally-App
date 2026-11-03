/** Local, non-cryptographic UUID v4. Sufficient for offline row ids. */
export function createId(): string {
  const cryptoObject = globalThis.crypto as
    | { randomUUID?: () => string }
    | undefined;

  if (cryptoObject?.randomUUID) return cryptoObject.randomUUID();

  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (char) => {
    const random = Math.floor(Math.random() * 16);
    const value = char === 'x' ? random : (random & 0x3) | 0x8;
    return value.toString(16);
  });
}
