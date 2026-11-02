const _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Contoh: "Selasa, 3 November".
String formatLongDate(DateTime date) {
  return '${_dayNames[date.weekday - 1]}, ${date.day} '
      '${_monthNames[date.month - 1]}';
}

/// Label jadwal ulang: "Hari ini, 19:30", "Besok, 08:15", atau
/// "12 November, 08:15".
String formatDueLabel(DateTime due, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final day = DateTime(due.year, due.month, due.day);
  final time =
      '${due.hour.toString().padLeft(2, '0')}:'
      '${due.minute.toString().padLeft(2, '0')}';

  if (day == today) return 'Hari ini, $time';
  if (day == DateTime(today.year, today.month, today.day + 1)) {
    return 'Besok, $time';
  }
  return '${due.day} ${_monthNames[due.month - 1]}, $time';
}

/// Label hari tanpa jam: "Hari ini", "Kemarin", atau "20 Oktober".
String formatDayLabel(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final day = DateTime(date.year, date.month, date.day);

  if (day == today) return 'Hari ini';
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return 'Kemarin';
  }

  final month = _monthNames[date.month - 1];
  if (date.year == today.year) return '${date.day} $month';
  return '${date.day} $month ${date.year}';
}
