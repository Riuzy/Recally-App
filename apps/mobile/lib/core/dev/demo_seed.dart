import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/study/domain/srs_engine.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

/// Data contoh hanya untuk development dan pratinjau web. Build produksi tidak
/// menampilkan aksi ini kecuali dibangun dengan `--dart-define=DEMO_SEED=true`.
const bool demoSeedEnabled = kDebugMode || bool.fromEnvironment('DEMO_SEED');

final demoSeedProvider = Provider<DemoSeed>(
  (ref) => DemoSeed(ref.watch(appDatabaseProvider)),
);

/// Mengisi database lokal dengan satu deck contoh yang realistis.
///
/// Dipakai untuk mencoba alur Hari Ini, sesi belajar, dan Progres tanpa harus
/// membuat kartu satu per satu. Data contoh tidak ditandai `dirty`, jadi tidak
/// akan ikut tersinkron ke Supabase.
class DemoSeed {
  DemoSeed(this._db);

  final AppDatabase _db;

  static const String deckId = 'demo-biologi-sel';
  static const String deckName = 'Biologi Sel';

  /// Menambahkan deck, kartu, dan riwayat ulasan bila database belum punya
  /// deck sama sekali. Mengembalikan `true` bila data baru dibuat.
  Future<bool> seedIfEmpty() async {
    final existing = await (_db.select(_db.decks)..limit(1)).getSingleOrNull();
    if (existing != null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdAt = today.subtract(const Duration(days: 30));

    await _db.transaction(() async {
      await _db
          .into(_db.decks)
          .insert(
            DecksCompanion.insert(
              id: deckId,
              name: deckName,
              description: const Value(
                'Struktur dan fungsi sel untuk latihan harian.',
              ),
              createdAt: createdAt,
              updatedAt: now,
              dirty: const Value(false),
            ),
          );

      for (final card in _cards) {
        await _db
            .into(_db.cards)
            .insert(
              CardsCompanion.insert(
                id: card.id,
                deckId: deckId,
                front: card.front,
                back: card.back,
                dueAt: today.add(Duration(days: card.dueInDays)),
                intervalDays: Value(card.intervalDays),
                ease: Value(card.ease),
                reps: Value(card.reps),
                lapses: Value(card.lapses),
                createdAt: createdAt,
                updatedAt: now,
                dirty: const Value(false),
              ),
            );
      }

      for (final review in _reviews(today)) {
        await _db
            .into(_db.reviews)
            .insert(
              ReviewsCompanion.insert(
                id: review.id,
                cardId: review.cardId,
                rating: review.rating.index,
                reviewedAt: review.at,
                prevIntervalDays: review.prevIntervalDays,
                newIntervalDays: review.newIntervalDays,
                dirty: const Value(false),
              ),
            );
      }
    });

    return true;
  }
}

class _DemoCard {
  const _DemoCard({
    required this.id,
    required this.front,
    required this.back,
    required this.dueInDays,
    this.intervalDays = 0,
    this.reps = 0,
    this.lapses = 0,
    this.ease = 2.5,
  });

  final String id;
  final String front;
  final String back;
  final int dueInDays;
  final int intervalDays;
  final int reps;
  final int lapses;
  final double ease;
}

class _DemoReview {
  const _DemoReview({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.at,
    required this.prevIntervalDays,
    required this.newIntervalDays,
  });

  final String id;
  final String cardId;
  final RecallRating rating;
  final DateTime at;
  final int prevIntervalDays;
  final int newIntervalDays;
}

const _cards = [
  _DemoCard(
    id: 'demo-card-1',
    front: 'Apa fungsi mitokondria?',
    back: 'Menghasilkan ATP melalui respirasi sel.',
    dueInDays: 0,
  ),
  _DemoCard(
    id: 'demo-card-2',
    front: 'Apa peran ribosom?',
    back: 'Menyusun protein dari asam amino.',
    dueInDays: 0,
  ),
  _DemoCard(
    id: 'demo-card-3',
    front: 'Organel mana yang menghasilkan enzim hidrolitik?',
    back: 'Lisosom.',
    dueInDays: 0,
    intervalDays: 4,
    reps: 2,
    ease: 2.4,
  ),
  _DemoCard(
    id: 'demo-card-4',
    front: 'Apa fungsi membran sel?',
    back: 'Mengatur keluar-masuknya zat dan melindungi sel.',
    dueInDays: 0,
    intervalDays: 1,
    reps: 1,
  ),
  _DemoCard(
    id: 'demo-card-5',
    front: 'Di organel mana transkripsi DNA terjadi?',
    back: 'Inti sel (nukleus).',
    dueInDays: 1,
    intervalDays: 3,
    reps: 2,
  ),
  _DemoCard(
    id: 'demo-card-6',
    front: 'Apa itu difusi?',
    back: 'Perpindahan zat dari konsentrasi tinggi ke rendah tanpa energi.',
    dueInDays: 2,
    intervalDays: 2,
    reps: 1,
  ),
  _DemoCard(
    id: 'demo-card-7',
    front: 'Apa beda osmosis dan difusi?',
    back: 'Osmosis khusus perpindahan air melalui membran semipermeabel.',
    dueInDays: 5,
    intervalDays: 5,
    reps: 3,
  ),
  _DemoCard(
    id: 'demo-card-8',
    front: 'Apa fungsi badan Golgi?',
    back: 'Mengemas dan mengirim protein serta lipid.',
    dueInDays: 5,
    intervalDays: 5,
    reps: 3,
  ),
  _DemoCard(
    id: 'demo-card-9',
    front: 'Apa itu kloroplas?',
    back: 'Organel tempat fotosintesis pada sel tumbuhan.',
    dueInDays: 2,
    intervalDays: 2,
    reps: 3,
    ease: 2.3,
  ),
  _DemoCard(
    id: 'demo-card-10',
    front: 'Apa fungsi vakuola pada sel tumbuhan?',
    back: 'Menyimpan air dan menjaga tekanan turgor.',
    dueInDays: 9,
    intervalDays: 10,
    reps: 4,
    lapses: 1,
    ease: 2.2,
  ),
  _DemoCard(
    id: 'demo-card-11',
    front: 'Mengapa sel disebut unit terkecil kehidupan?',
    back: 'Karena sel adalah struktur dan fungsi terkecil yang mampu hidup.',
    dueInDays: 23,
    intervalDays: 24,
    reps: 5,
    ease: 2.6,
  ),
  _DemoCard(
    id: 'demo-card-12',
    front: 'Apa itu sitoskeleton?',
    back: 'Jaringan protein yang memberi bentuk dan mendukung gerak sel.',
    dueInDays: 26,
    intervalDays: 30,
    reps: 6,
    lapses: 0,
    ease: 2.7,
  ),
];

/// Riwayat lima hari berturut-turut (plus dua ulasan lama sebagai pembanding)
/// agar grafik 7/30 hari, streak, dan retensi langsung terlihat.
List<_DemoReview> _reviews(DateTime today) {
  DateTime at(int daysAgo, int hour, int minute) =>
      DateTime(today.year, today.month, today.day - daysAgo, hour, minute);

  return [
    _DemoReview(
      id: 'demo-review-1',
      cardId: 'demo-card-7',
      rating: RecallRating.ingat,
      at: at(0, 8, 10),
      prevIntervalDays: 2,
      newIntervalDays: 5,
    ),
    _DemoReview(
      id: 'demo-review-2',
      cardId: 'demo-card-8',
      rating: RecallRating.ingat,
      at: at(0, 8, 20),
      prevIntervalDays: 2,
      newIntervalDays: 5,
    ),
    _DemoReview(
      id: 'demo-review-3',
      cardId: 'demo-card-9',
      rating: RecallRating.ragu,
      at: at(0, 8, 30),
      prevIntervalDays: 1,
      newIntervalDays: 2,
    ),
    _DemoReview(
      id: 'demo-review-4',
      cardId: 'demo-card-7',
      rating: RecallRating.ingat,
      at: at(1, 19, 10),
      prevIntervalDays: 1,
      newIntervalDays: 2,
    ),
    _DemoReview(
      id: 'demo-review-5',
      cardId: 'demo-card-10',
      rating: RecallRating.ingat,
      at: at(1, 19, 20),
      prevIntervalDays: 0,
      newIntervalDays: 10,
    ),
    _DemoReview(
      id: 'demo-review-6',
      cardId: 'demo-card-11',
      rating: RecallRating.ingat,
      at: at(1, 19, 30),
      prevIntervalDays: 18,
      newIntervalDays: 24,
    ),
    _DemoReview(
      id: 'demo-review-7',
      cardId: 'demo-card-8',
      rating: RecallRating.ingat,
      at: at(2, 18, 10),
      prevIntervalDays: 1,
      newIntervalDays: 2,
    ),
    _DemoReview(
      id: 'demo-review-8',
      cardId: 'demo-card-10',
      rating: RecallRating.lupa,
      at: at(2, 18, 20),
      prevIntervalDays: 5,
      newIntervalDays: 0,
    ),
    _DemoReview(
      id: 'demo-review-9',
      cardId: 'demo-card-9',
      rating: RecallRating.ragu,
      at: at(3, 20, 10),
      prevIntervalDays: 0,
      newIntervalDays: 1,
    ),
    _DemoReview(
      id: 'demo-review-10',
      cardId: 'demo-card-11',
      rating: RecallRating.ingat,
      at: at(3, 20, 20),
      prevIntervalDays: 12,
      newIntervalDays: 18,
    ),
    _DemoReview(
      id: 'demo-review-11',
      cardId: 'demo-card-12',
      rating: RecallRating.ingat,
      at: at(4, 19, 0),
      prevIntervalDays: 21,
      newIntervalDays: 30,
    ),
    _DemoReview(
      id: 'demo-review-12',
      cardId: 'demo-card-7',
      rating: RecallRating.ingat,
      at: at(6, 18, 0),
      prevIntervalDays: 0,
      newIntervalDays: 1,
    ),
    _DemoReview(
      id: 'demo-review-13',
      cardId: 'demo-card-8',
      rating: RecallRating.ingat,
      at: at(8, 19, 0),
      prevIntervalDays: 0,
      newIntervalDays: 1,
    ),
    _DemoReview(
      id: 'demo-review-14',
      cardId: 'demo-card-9',
      rating: RecallRating.lupa,
      at: at(12, 20, 0),
      prevIntervalDays: 4,
      newIntervalDays: 0,
    ),
  ];
}
