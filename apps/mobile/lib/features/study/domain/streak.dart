/// Menghitung hari beruntun dengan minimal satu ulasan.
///
/// Hari ini dihitung bila ada ulasan hari ini. Bila belum ada ulasan hari ini,
/// rentetan kemarin masih dianggap hidup (hari belum berakhir).
int computeStreak(Iterable<DateTime> reviewedAt, {required DateTime now}) {
  final days = reviewedAt
      .map((value) => DateTime(value.year, value.month, value.day))
      .toSet();
  if (days.isEmpty) return 0;

  var cursor = DateTime(now.year, now.month, now.day);
  if (!days.contains(cursor)) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return streak;
}
