import { describe, expect, it } from 'vitest';

import { computeStreak } from '../src/features/study/streak';

function day(offset: number, hour = 12): Date {
  return new Date(2026, 0, 15 + offset, hour);
}

const now = day(0);

describe('computeStreak', () => {
  it('returns zero without reviews', () => {
    expect(computeStreak([], now)).toBe(0);
  });

  it('counts today and consecutive previous days', () => {
    expect(computeStreak([day(0), day(-1), day(-2)], now)).toBe(3);
  });

  it('keeps yesterday\'s streak alive before today is reviewed', () => {
    expect(computeStreak([day(-1), day(-2), day(-3)], now)).toBe(3);
  });

  it('stops at the first missing day', () => {
    expect(computeStreak([day(0), day(-1), day(-3)], now)).toBe(2);
  });

  it('counts one streak day per calendar day', () => {
    expect(
      computeStreak(
        [day(0, 8), day(0, 9), day(0, 20), day(-1, 7), day(-1, 21)],
        now,
      ),
    ).toBe(2);
  });

  it('returns one when only today has a review', () => {
    expect(computeStreak([day(0)], now)).toBe(1);
  });

  it('returns zero when the last review is two days old', () => {
    expect(computeStreak([day(-2)], now)).toBe(0);
  });
});
