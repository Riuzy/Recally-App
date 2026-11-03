import { describe, expect, it } from 'vitest';

import {
  addDays,
  differenceInDays,
  formatDayLabel,
  formatDueLabel,
  formatLongDate,
  isSameDay,
  shortWeekday,
  startOfDay,
} from '../src/format/indonesianDate';

describe('formatLongDate', () => {
  it('formats the Indonesian weekday and month', () => {
    expect(formatLongDate(new Date(2025, 10, 3))).toBe('Senin, 3 November');
    expect(formatLongDate(new Date(2026, 0, 4))).toBe('Minggu, 4 Januari');
  });
});

describe('formatDueLabel', () => {
  const now = new Date(2026, 5, 10, 10, 0);

  it('uses a relative label for today and tomorrow', () => {
    expect(formatDueLabel(new Date(2026, 5, 10, 19, 30), now)).toBe(
      'Hari ini, 19:30',
    );
    expect(formatDueLabel(new Date(2026, 5, 11, 8, 15), now)).toBe(
      'Besok, 08:15',
    );
  });

  it('uses day and month for later dates', () => {
    expect(formatDueLabel(new Date(2026, 5, 12, 8, 15), now)).toBe(
      '12 Juni, 08:15',
    );
  });
});

describe('formatDayLabel', () => {
  const now = new Date(2026, 5, 10, 10, 0);

  it('labels today and yesterday', () => {
    expect(formatDayLabel(new Date(2026, 5, 10, 19, 0), now)).toBe('Hari ini');
    expect(formatDayLabel(new Date(2026, 5, 9, 7, 0), now)).toBe('Kemarin');
  });

  it('omits the year for the current year and includes it otherwise', () => {
    expect(formatDayLabel(new Date(2026, 9, 20), now)).toBe('20 Oktober');
    expect(formatDayLabel(new Date(2025, 9, 20), now)).toBe('20 Oktober 2025');
  });
});

describe('date helpers', () => {
  it('shortens weekdays starting on Monday', () => {
    expect(shortWeekday(new Date(2025, 10, 3))).toBe('Sen');
    expect(shortWeekday(new Date(2025, 10, 9))).toBe('Min');
  });

  it('adds days across month boundaries', () => {
    expect(addDays(new Date(2026, 0, 31), 1).getMonth()).toBe(1);
    expect(addDays(new Date(2026, 0, 1), -1).getDate()).toBe(31);
  });

  it('compares dates by calendar day', () => {
    expect(isSameDay(new Date(2026, 5, 10, 1), new Date(2026, 5, 10, 23))).toBe(
      true,
    );
    expect(isSameDay(new Date(2026, 5, 10), new Date(2026, 5, 11))).toBe(false);
  });

  it('measures whole-day differences', () => {
    expect(
      differenceInDays(new Date(2026, 5, 12), new Date(2026, 5, 10, 23, 59)),
    ).toBe(2);
    expect(differenceInDays(new Date(2026, 5, 9), new Date(2026, 5, 10))).toBe(
      -1,
    );
  });

  it('returns the local start of day', () => {
    const start = startOfDay(new Date(2026, 5, 10, 19, 45));
    expect(start.getHours()).toBe(0);
    expect(start.getMinutes()).toBe(0);
    expect(start.getDate()).toBe(10);
  });
});
