import { describe, expect, it } from 'vitest';

import { makeCard } from './helpers/fixtures';
import { RecallRating } from '../src/features/study/srsEngine';
import { StudySession } from '../src/features/study/studySession';

const cards = [
  makeCard({ id: 'a', front: 'Satu' }),
  makeCard({ id: 'b', front: 'Dua' }),
];

describe('StudySession', () => {
  it('walks through answer, reveal, grade, and finish', () => {
    const session = new StudySession(cards);

    expect(session.position).toBe(1);
    expect(session.total).toBe(2);
    expect(session.getStep()).toBe('jawab');
    expect(session.progress).toBe(0);

    session.submitAnswer('  jawabanku  ');
    expect(session.current.answer).toBe('jawabanku');
    expect(session.getStep()).toBe('nilai');

    session.grade(RecallRating.Ingat);
    expect(session.position).toBe(2);
    expect(session.getStep()).toBe('jawab');
    expect(session.answeredCount).toBe(1);
    expect(session.progress).toBe(0.5);

    session.reveal();
    session.grade(RecallRating.Lupa);
    expect(session.isFinished).toBe(true);
    expect(session.answeredCount).toBe(2);
    expect(session.progress).toBe(1);
  });

  it('ignores empty answers and grading before reveal', () => {
    const session = new StudySession(cards);

    session.submitAnswer('   ');
    expect(session.getStep()).toBe('jawab');

    session.grade(RecallRating.Ingat);
    expect(session.getStep()).toBe('jawab');
    expect(session.answeredCount).toBe(0);
  });

  it('does not advance after the session is finished', () => {
    const session = new StudySession([cards[0]!]);

    session.reveal();
    session.grade(RecallRating.Ingat);

    expect(session.isFinished).toBe(true);
    expect(session.isLast).toBe(true);

    session.grade(RecallRating.Lupa);
    expect(session.countOf(RecallRating.Ingat)).toBe(1);
    expect(session.countOf(RecallRating.Lupa)).toBe(0);
  });

  it('counts ratings and collects forgotten cards', () => {
    const session = new StudySession([
      ...cards,
      makeCard({ id: 'c', front: 'Tiga' }),
    ]);

    session.reveal();
    session.grade(RecallRating.Ingat);
    session.reveal();
    session.grade(RecallRating.Ragu);
    session.reveal();
    session.grade(RecallRating.Lupa);

    expect(session.countOf(RecallRating.Ingat)).toBe(1);
    expect(session.countOf(RecallRating.Ragu)).toBe(1);
    expect(session.countOf(RecallRating.Lupa)).toBe(1);
    expect(session.lapsedCards.map((card) => card.id)).toEqual(['c']);
    expect(session.isFinished).toBe(true);
  });

  it('switches study mode and reports empty sessions', () => {
    const session = new StudySession([], 'hafalan');

    expect(session.isEmpty).toBe(true);
    expect(session.getMode()).toBe('hafalan');
    expect(session.progress).toBe(0);

    session.setMode('tulis');
    expect(session.getMode()).toBe('tulis');
  });
});
