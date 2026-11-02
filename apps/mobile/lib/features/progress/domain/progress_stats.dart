/// Interval (hari) yang dianggap "dikuasai". Selaras dengan target hafalan
/// jangka panjang: kartu yang sudah terjadwal tiga minggu ke depan tidak perlu
/// dihitung sebagai beban belajar harian.
const int masteredIntervalDays = 21;

/// Rentang waktu untuk grafik aktivitas dan retensi.
enum ProgressPeriod {
  week(7, 'Minggu ini', 'minggu sebelumnya'),
  month(30, '30 hari', '30 hari sebelumnya');

  const ProgressPeriod(this.days, this.label, this.comparisonLabel);

  final int days;
  final String label;
  final String comparisonLabel;
}

/// Progres satu deck untuk daftar "Per deck".
class DeckProgress {
  const DeckProgress({
    required this.deckId,
    required this.name,
    required this.total,
    required this.mastered,
    required this.due,
  });

  final String deckId;
  final String name;
  final int total;
  final int mastered;
  final int due;

  double get mastery => total == 0 ? 0 : mastered / total;
}

/// Ringkasan seluruh kartu aktif.
class CardProgress {
  const CardProgress({
    required this.total,
    required this.due,
    required this.mastered,
    required this.learning,
    required this.fresh,
    required this.decks,
  });

  final int total;
  final int due;
  final int mastered;
  final int learning;
  final int fresh;

  /// Urut dari deck dengan kartu terbanyak.
  final List<DeckProgress> decks;

  double get mastery => total == 0 ? 0 : mastered / total;
}

/// Satu batang pada grafik aktivitas.
class DayActivity {
  const DayActivity({required this.day, required this.reviews});

  final DateTime day;
  final int reviews;
}

/// Satu hari yang punya ulasan, untuk "Riwayat belajar".
class DayReviewSummary {
  const DayReviewSummary({
    required this.day,
    required this.reviews,
    required this.ingat,
  });

  final DateTime day;
  final int reviews;
  final int ingat;
}

/// Statistik ulasan untuk periode terpilih.
///
/// Retensi = porsi nilai "Ingat" dari semua ulasan di periode tersebut. Tidak
/// ada skor yang dikarang: periode tanpa ulasan menghasilkan `null`.
class ReviewActivity {
  const ReviewActivity({
    required this.period,
    required this.days,
    required this.total,
    required this.ingat,
    required this.ragu,
    required this.lupa,
    required this.previousTotal,
    required this.previousIngat,
    required this.streak,
    required this.recentDays,
    required this.hasAnyReview,
  });

  final ProgressPeriod period;
  final List<DayActivity> days;
  final int total;
  final int ingat;
  final int ragu;
  final int lupa;
  final int previousTotal;
  final int previousIngat;
  final int streak;
  final List<DayReviewSummary> recentDays;
  final bool hasAnyReview;

  double? get retention => total == 0 ? null : ingat / total;

  double? get previousRetention =>
      previousTotal == 0 ? null : previousIngat / previousTotal;

  /// Selisih retensi dalam porsi 0..1, mis. `0.06` berarti +6 poin.
  double? get retentionDelta {
    final current = retention;
    final previous = previousRetention;
    if (current == null || previous == null) return null;
    return current - previous;
  }
}
