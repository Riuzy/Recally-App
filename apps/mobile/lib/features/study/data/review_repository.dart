import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/streak.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(ref.watch(appDatabaseProvider)),
);

/// Rentetan hari belajar, dihitung dari tabel `reviews` (tanpa tabel baru).
final streakProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(reviewRepositoryProvider).watchStreak(),
);

/// Jumlah kartu yang sudah dinilai hari ini.
final reviewedTodayProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(reviewRepositoryProvider).watchReviewedToday(),
);

class ReviewRepository {
  ReviewRepository(this._db);

  final AppDatabase _db;

  Stream<int> watchStreak({DateTime? now}) {
    final query = _db.selectOnly(_db.reviews)
      ..addColumns([_db.reviews.reviewedAt]);

    return query.watch().map((rows) {
      final timestamps = <DateTime>[
        for (final row in rows)
          if (row.read(_db.reviews.reviewedAt) case final value?) value,
      ];
      return computeStreak(timestamps, now: now ?? DateTime.now());
    });
  }

  Stream<int> watchReviewedToday({DateTime? now}) {
    final at = now ?? DateTime.now();
    final start = DateTime(at.year, at.month, at.day);
    final end = start.add(const Duration(days: 1));
    
    return _db.select(_db.reviews).watch().map((rows) {
      return rows.where((row) {
        final reviewedAt = row.reviewedAt;
        return reviewedAt != null && 
               !reviewedAt.isBefore(start) && 
               reviewedAt.isBefore(end);
      }).length;
    });
  }
}
