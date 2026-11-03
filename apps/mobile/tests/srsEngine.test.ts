import { describe, expect, it } from 'vitest';

import {
  ratingLabel,
  RecallRating,
  schedule,
} from '../src/features/study/srsEngine';

const now = new Date('2026-01-01T09:00:00.000Z');

describe('schedule', () => {
  it('sends a lapsed card to relearning in ten minutes', () => {
    const outcome = schedule({
      rating: RecallRating.Lupa,
      ease: 2.5,
      intervalDays: 12,
      reps: 4,
      lapses: 1,
      now,
    });

    expect(outcome.intervalDays).toBe(0);
    expect(outcome.reps).toBe(0);
    expect(outcome.lapses).toBe(2);
    expect(outcome.ease).toBeCloseTo(2.3);
    expect(outcome.dueAt.getTime()).toBe(now.getTime() + 10 * 60_000);
  });

  it('grows a hesitant interval by 20 percent and lowers ease', () => {
    const outcome = schedule({
      rating: RecallRating.Ragu,
      ease: 2.5,
      intervalDays: 4,
      reps: 2,
      lapses: 0,
      now,
    });

    expect(outcome.intervalDays).toBe(5);
    expect(outcome.reps).toBe(3);
    expect(outcome.lapses).toBe(0);
    expect(outcome.ease).toBeCloseTo(2.35);
    expect(outcome.dueAt.getTime()).toBe(now.getTime() + 5 * 86_400_000);
  });

  it('schedules a first successful review for tomorrow', () => {
    const outcome = schedule({
      rating: RecallRating.Ingat,
      ease: 2.5,
      intervalDays: 0,
      reps: 0,
      lapses: 0,
      now,
    });

    expect(outcome.intervalDays).toBe(1);
    expect(outcome.reps).toBe(1);
    expect(outcome.ease).toBeCloseTo(2.6);
  });

  it('schedules the second successful review for six days', () => {
    const outcome = schedule({
      rating: RecallRating.Ingat,
      ease: 2.6,
      intervalDays: 1,
      reps: 1,
      lapses: 0,
      now,
    });

    expect(outcome.intervalDays).toBe(6);
    expect(outcome.reps).toBe(2);
  });

  it('multiplies mature intervals by ease and caps ease at 3.0', () => {
    const outcome = schedule({
      rating: RecallRating.Ingat,
      ease: 2.95,
      intervalDays: 10,
      reps: 3,
      lapses: 0,
      now,
    });

    expect(outcome.intervalDays).toBe(30);
    expect(outcome.ease).toBeCloseTo(3.0);
  });

  it('never lets ease fall below 1.3', () => {
    const outcome = schedule({
      rating: RecallRating.Lupa,
      ease: 1.3,
      intervalDays: 3,
      reps: 1,
      lapses: 5,
      now,
    });

    expect(outcome.ease).toBeCloseTo(1.3);
  });
});

describe('ratingLabel', () => {
  it('returns the Indonesian grade labels', () => {
    expect(ratingLabel(RecallRating.Lupa)).toBe('Lupa');
    expect(ratingLabel(RecallRating.Ragu)).toBe('Ragu');
    expect(ratingLabel(RecallRating.Ingat)).toBe('Ingat');
  });
});
