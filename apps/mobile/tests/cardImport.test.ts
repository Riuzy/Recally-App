import { describe, expect, it } from 'vitest';

import { parseCardLines } from '../src/features/decks/cardImport';

describe('parseCardLines', () => {
  it('parses one card per line at the first semicolon', () => {
    const result = parseCardLines('pagi;morning\nmalam;night');

    expect(result.cards).toEqual([
      { front: 'pagi', back: 'morning' },
      { front: 'malam', back: 'night' },
    ]);
    expect(result.invalidLines).toEqual([]);
    expect(result.hasInvalid).toBe(false);
  });

  it('trims whitespace and skips blank lines', () => {
    const result = parseCardLines('  arigatou ; terima kasih  \n\n   \n');

    expect(result.cards).toEqual([
      { front: 'arigatou', back: 'terima kasih' },
    ]);
  });

  it('keeps semicolons inside the answer', () => {
    const result = parseCardLines('a;b;c');

    expect(result.cards).toEqual([{ front: 'a', back: 'b;c' }]);
  });

  it('reports lines without a separator or with an empty side', () => {
    const result = parseCardLines('valid;jawaban\ntanpa pemisah\n;kosong\nkosong;');

    expect(result.cards).toEqual([{ front: 'valid', back: 'jawaban' }]);
    expect(result.invalidLines).toEqual([2, 3, 4]);
    expect(result.hasInvalid).toBe(true);
  });

  it('accepts Windows line endings', () => {
    const result = parseCardLines('satu;one\r\ndua;two');

    expect(result.cards).toHaveLength(2);
    expect(result.hasInvalid).toBe(false);
  });

  it('returns nothing for empty input', () => {
    expect(parseCardLines('')).toEqual({
      cards: [],
      invalidLines: [],
      hasInvalid: false,
    });
  });
});
