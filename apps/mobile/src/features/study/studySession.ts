import type { CardRow } from '../../db/schema';
import { RecallRating } from './srsEngine';

/** How the user answers cards during a session. */
export type StudyMode = 'tulis' | 'hafalan';

/** Position within a single card. */
export type StudyStep = 'jawab' | 'nilai';

export interface StudyEntry {
  card: CardRow;
  answer: string;
  rating: RecallRating | null;
}

/**
 * Study session state machine. Pure (no UI, no database) so the grading flow
 * can be tested without React.
 */
export class StudySession {
  readonly entries: StudyEntry[];
  private mode: StudyMode;
  private index = 0;
  private step: StudyStep = 'jawab';
  private finished = false;

  constructor(cards: CardRow[], mode: StudyMode = 'tulis') {
    this.entries = cards.map((card) => ({
      card,
      answer: '',
      rating: null,
    }));
    this.mode = mode;
  }

  getMode(): StudyMode {
    return this.mode;
  }

  getStep(): StudyStep {
    return this.step;
  }

  getIndex(): number {
    return this.index;
  }

  get position(): number {
    return this.index + 1;
  }

  get total(): number {
    return this.entries.length;
  }

  get isEmpty(): boolean {
    return this.entries.length === 0;
  }

  get isLast(): boolean {
    return this.index >= this.entries.length - 1;
  }

  get isFinished(): boolean {
    return this.finished;
  }

  get current(): StudyEntry {
    return this.entries[this.index]!;
  }

  get answeredCount(): number {
    return this.entries.filter((entry) => entry.rating !== null).length;
  }

  /** 0..1 for the progress bar. */
  get progress(): number {
    return this.total === 0 ? 0 : this.answeredCount / this.total;
  }

  countOf(rating: RecallRating): number {
    return this.entries.filter((entry) => entry.rating === rating).length;
  }

  /** Cards graded "Lupa"; used to repeat them immediately. */
  get lapsedCards(): CardRow[] {
    return this.entries
      .filter((entry) => entry.rating === RecallRating.Lupa)
      .map((entry) => entry.card);
  }

  /** Stores the answer and opens the comparison. Empty answers are rejected. */
  submitAnswer(text: string): void {
    if (this.finished || this.step !== 'jawab') return;
    const trimmed = text.trim();
    if (trimmed.length === 0) return;
    this.current.answer = trimmed;
    this.step = 'nilai';
  }

  /** Reveals the answer without typing (reveal button / hafalan mode). */
  reveal(): void {
    if (this.finished || this.step !== 'jawab') return;
    this.step = 'nilai';
  }

  /** Grades the current card and advances to the next one. */
  grade(rating: RecallRating): void {
    if (this.finished || this.step !== 'nilai') return;
    this.current.rating = rating;

    if (this.isLast) {
      this.finished = true;
      return;
    }

    this.index += 1;
    this.step = 'jawab';
  }

  setMode(mode: StudyMode): void {
    this.mode = mode;
  }
}
