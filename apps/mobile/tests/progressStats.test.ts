import { describe, expect, it } from 'vitest';

import {
  createCardProgress,
  createReviewActivity,
} from '../src/features/progress/progressStats';

describe('createCardProgress', () => {
  it('computes mastery and sorts decks by card count then name', () => {
    const progress = createCardProgress({
      total: 10,
      due: 4,
      mastered: 3,
      learning: 2,
      fresh: 5,
      decks: [
        { deckId: 'a', name: 'Zeta', total: 2, mastered: 1, due: 1 },
        { deckId: 'b', name: 'Alfa', total: 6, mastered: 2, due: 2 },
        { deckId: 'c', name: 'Beta', total: 2, mastered: 0, due: 1 },
      ],
    });

    expect(progress.mastery).toBeCloseTo(0.3);
    expect(progress.decks.map((deck) => deck.name)).toEqual([
      'Alfa',
      'Beta',
      'Zeta',
    ]);
    expect(progress.decks[0]?.mastery).toBeCloseTo(2 / 6);
  });

  it('reports zero mastery for an empty library', () => {
    const progress = createCardProgress({
      total: 0,
      due: 0,
      mastered: 0,
      learning: 0,
      fresh: 0,
      decks: [],
    });

    expect(progress.mastery).toBe(0);
    expect(progress.decks).toEqual([]);
  });
});

describe('createReviewActivity', () => {
  const days = [
    { day: new Date(2026, 5, 9), reviews: 2 },
    { day: new Date(2026, 5, 10), reviews: 3 },
  ];

  it('derives totals, retention, and the delta', () => {
    const activity = createReviewActivity({
      period: 'week',
      days,
      counts: { 0: 1, 1: 1, 2: 3 },
      previousTotal: 4,
      previousIngat: 1,
      streak: 2,
      recentDays: [],
      hasAnyReview: true,
    });

    expect(activity.total).toBe(5);
    expect(activity.ingat).toBe(3);
    expect(activity.ragu).toBe(1);
    expect(activity.lupa).toBe(1);
    expect(activity.retention).toBeCloseTo(0.6);
    expect(activity.previousRetention).toBeCloseTo(0.25);
    expect(activity.retentionDelta).toBeCloseTo(0.35);
  });

  it('returns null retention when there are no reviews', () => {
    const activity = createReviewActivity({
      period: 'month',
      days: [],
      counts: { 0: 0, 1: 0, 2: 0 },
      previousTotal: 0,
      previousIngat: 0,
      streak: 0,
      recentDays: [],
      hasAnyReview: false,
    });

    expect(activity.retention).toBeNull();
    expect(activity.previousRetention).toBeNull();
    expect(activity.retentionDelta).toBeNull();
  });

  it('leaves the delta null when there is no comparison period', () => {
    const activity = createReviewActivity({
      period: 'week',
      days,
      counts: { 0: 0, 1: 0, 2: 2 },
      previousTotal: 0,
      previousIngat: 0,
      streak: 1,
      recentDays: [],
      hasAnyReview: true,
    });

    expect(activity.retention).toBe(1);
    expect(activity.previousRetention).toBeNull();
    expect(activity.retentionDelta).toBeNull();
  });
});
