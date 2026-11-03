import { eq } from 'drizzle-orm';

import type { AppDb } from '../../db/types';
import { cards, decks, reviews } from '../../db/schema';
import { withTransaction } from '../../db/transaction';
import { RecallRating } from '../study/srsEngine';

/** Demo data is available in development and in previews built with the flag. */
export const demoSeedEnabled =
  (typeof __DEV__ !== 'undefined' && __DEV__) ||
  process.env.EXPO_PUBLIC_DEMO_SEED === 'true';

export const DEMO_DECK_ID = 'demo-biologi-sel';
export const DEMO_DECK_NAME = 'Biologi Sel';

interface DemoCard {
  id: string;
  front: string;
  back: string;
  dueInDays: number;
  intervalDays?: number;
  reps?: number;
  lapses?: number;
  ease?: number;
}

interface DemoReview {
  id: string;
  cardId: string;
  rating: RecallRating;
  at: Date;
  prevIntervalDays: number;
  newIntervalDays: number;
}

const DEMO_CARDS: readonly DemoCard[] = [
  {
    id: 'demo-card-1',
    front: 'Apa fungsi mitokondria?',
    back: 'Menghasilkan ATP melalui respirasi sel.',
    dueInDays: 0,
  },
  {
    id: 'demo-card-2',
    front: 'Apa peran ribosom?',
    back: 'Menyusun protein dari asam amino.',
    dueInDays: 0,
  },
  {
    id: 'demo-card-3',
    front: 'Organel mana yang menghasilkan enzim hidrolitik?',
    back: 'Lisosom.',
    dueInDays: 0,
    intervalDays: 4,
    reps: 2,
    ease: 2.4,
  },
  {
    id: 'demo-card-4',
    front: 'Apa fungsi membran sel?',
    back: 'Mengatur keluar-masuknya zat dan melindungi sel.',
    dueInDays: 0,
    intervalDays: 1,
    reps: 1,
  },
  {
    id: 'demo-card-5',
    front: 'Di organel mana transkripsi DNA terjadi?',
    back: 'Inti sel (nukleus).',
    dueInDays: 1,
    intervalDays: 3,
    reps: 2,
  },
  {
    id: 'demo-card-6',
    front: 'Apa itu difusi?',
    back: 'Perpindahan zat dari konsentrasi tinggi ke rendah tanpa energi.',
    dueInDays: 2,
    intervalDays: 2,
    reps: 1,
  },
  {
    id: 'demo-card-7',
    front: 'Apa beda osmosis dan difusi?',
    back: 'Osmosis khusus perpindahan air melalui membran semipermeabel.',
    dueInDays: 5,
    intervalDays: 5,
    reps: 3,
  },
  {
    id: 'demo-card-8',
    front: 'Apa fungsi badan Golgi?',
    back: 'Mengemas dan mengirim protein serta lipid.',
    dueInDays: 5,
    intervalDays: 5,
    reps: 3,
  },
  {
    id: 'demo-card-9',
    front: 'Apa itu kloroplas?',
    back: 'Organel tempat fotosintesis pada sel tumbuhan.',
    dueInDays: 2,
    intervalDays: 2,
    reps: 3,
    ease: 2.3,
  },
  {
    id: 'demo-card-10',
    front: 'Apa fungsi vakuola pada sel tumbuhan?',
    back: 'Menyimpan air dan menjaga tekanan turgor.',
    dueInDays: 9,
    intervalDays: 10,
    reps: 4,
    lapses: 1,
    ease: 2.2,
  },
  {
    id: 'demo-card-11',
    front: 'Mengapa sel disebut unit terkecil kehidupan?',
    back: 'Karena sel adalah struktur dan fungsi terkecil yang mampu hidup.',
    dueInDays: 23,
    intervalDays: 24,
    reps: 5,
    ease: 2.6,
  },
  {
    id: 'demo-card-12',
    front: 'Apa itu sitoskeleton?',
    back: 'Jaringan protein yang memberi bentuk dan mendukung gerak sel.',
    dueInDays: 26,
    intervalDays: 30,
    reps: 6,
    lapses: 0,
    ease: 2.7,
  },
];

function buildReviews(today: Date): DemoReview[] {
  const at = (daysAgo: number, hour: number, minute: number) =>
    new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate() - daysAgo,
      hour,
      minute,
    );

  return [
    {
      id: 'demo-review-1',
      cardId: 'demo-card-7',
      rating: RecallRating.Ingat,
      at: at(0, 8, 10),
      prevIntervalDays: 2,
      newIntervalDays: 5,
    },
    {
      id: 'demo-review-2',
      cardId: 'demo-card-8',
      rating: RecallRating.Ingat,
      at: at(0, 8, 20),
      prevIntervalDays: 2,
      newIntervalDays: 5,
    },
    {
      id: 'demo-review-3',
      cardId: 'demo-card-9',
      rating: RecallRating.Ragu,
      at: at(0, 8, 30),
      prevIntervalDays: 1,
      newIntervalDays: 2,
    },
    {
      id: 'demo-review-4',
      cardId: 'demo-card-7',
      rating: RecallRating.Ingat,
      at: at(1, 19, 10),
      prevIntervalDays: 1,
      newIntervalDays: 2,
    },
    {
      id: 'demo-review-5',
      cardId: 'demo-card-10',
      rating: RecallRating.Ingat,
      at: at(1, 19, 20),
      prevIntervalDays: 0,
      newIntervalDays: 10,
    },
    {
      id: 'demo-review-6',
      cardId: 'demo-card-11',
      rating: RecallRating.Ingat,
      at: at(1, 19, 30),
      prevIntervalDays: 18,
      newIntervalDays: 24,
    },
    {
      id: 'demo-review-7',
      cardId: 'demo-card-8',
      rating: RecallRating.Ingat,
      at: at(2, 18, 10),
      prevIntervalDays: 1,
      newIntervalDays: 2,
    },
    {
      id: 'demo-review-8',
      cardId: 'demo-card-10',
      rating: RecallRating.Lupa,
      at: at(2, 18, 20),
      prevIntervalDays: 5,
      newIntervalDays: 0,
    },
    {
      id: 'demo-review-9',
      cardId: 'demo-card-9',
      rating: RecallRating.Ragu,
      at: at(3, 20, 10),
      prevIntervalDays: 0,
      newIntervalDays: 1,
    },
    {
      id: 'demo-review-10',
      cardId: 'demo-card-11',
      rating: RecallRating.Ingat,
      at: at(3, 20, 20),
      prevIntervalDays: 12,
      newIntervalDays: 18,
    },
    {
      id: 'demo-review-11',
      cardId: 'demo-card-12',
      rating: RecallRating.Ingat,
      at: at(4, 19, 0),
      prevIntervalDays: 21,
      newIntervalDays: 30,
    },
    {
      id: 'demo-review-12',
      cardId: 'demo-card-7',
      rating: RecallRating.Ingat,
      at: at(6, 18, 0),
      prevIntervalDays: 0,
      newIntervalDays: 1,
    },
    {
      id: 'demo-review-13',
      cardId: 'demo-card-8',
      rating: RecallRating.Ingat,
      at: at(8, 19, 0),
      prevIntervalDays: 0,
      newIntervalDays: 1,
    },
    {
      id: 'demo-review-14',
      cardId: 'demo-card-9',
      rating: RecallRating.Lupa,
      at: at(12, 20, 0),
      prevIntervalDays: 4,
      newIntervalDays: 0,
    },
  ];
}

/**
 * Adds the demo deck, cards, and review history when it does not exist yet.
 * Existing user decks are never touched. Demo rows are not dirty, so they will
 * not be pushed by a future sync.
 */
export async function seedDemoData(
  db: AppDb,
  now: Date = new Date(),
): Promise<boolean> {
  const existing = await db
    .select({ id: decks.id })
    .from(decks)
    .where(eq(decks.id, DEMO_DECK_ID))
    .limit(1);
  if (existing.length > 0) return false;

  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const createdAt = new Date(today.getTime() - 30 * 86_400_000);

  await withTransaction(db, async () => {
    await db.insert(decks).values({
      id: DEMO_DECK_ID,
      name: DEMO_DECK_NAME,
      description: 'Struktur dan fungsi sel untuk latihan harian.',
      createdAt,
      updatedAt: now,
      dirty: false,
    });

    for (const card of DEMO_CARDS) {
      await db.insert(cards).values({
        id: card.id,
        deckId: DEMO_DECK_ID,
        front: card.front,
        back: card.back,
        dueAt: new Date(
          today.getFullYear(),
          today.getMonth(),
          today.getDate() + card.dueInDays,
        ),
        intervalDays: card.intervalDays ?? 0,
        ease: card.ease ?? 2.5,
        reps: card.reps ?? 0,
        lapses: card.lapses ?? 0,
        createdAt,
        updatedAt: now,
        dirty: false,
      });
    }

    for (const review of buildReviews(today)) {
      await db.insert(reviews).values({
        id: review.id,
        cardId: review.cardId,
        rating: review.rating,
        reviewedAt: review.at,
        prevIntervalDays: review.prevIntervalDays,
        newIntervalDays: review.newIntervalDays,
        dirty: false,
      });
    }
  });

  return true;
}
