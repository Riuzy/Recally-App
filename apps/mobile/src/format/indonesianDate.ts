const dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
] as const;

const monthNames = [
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
] as const;

function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function dayKey(date: Date): number {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
  ).getTime();
}

/** Example: "Selasa, 3 November". */
export function formatLongDate(date: Date): string {
  return `${dayNames[date.getDay() === 0 ? 6 : date.getDay() - 1]}, ${date.getDate()} ${
    monthNames[date.getMonth()]
  }`;
}

function pad(value: number): string {
  return value.toString().padStart(2, '0');
}

function timeLabel(date: Date): string {
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/** "Hari ini, 19:30", "Besok, 08:15", or "12 November, 08:15". */
export function formatDueLabel(due: Date, now: Date = new Date()): string {
  const today = startOfDay(now);
  const day = startOfDay(due);
  const diff = Math.round((day.getTime() - today.getTime()) / 86_400_000);

  if (diff === 0) return `Hari ini, ${timeLabel(due)}`;
  if (diff === 1) return `Besok, ${timeLabel(due)}`;
  return `${due.getDate()} ${monthNames[due.getMonth()]}, ${timeLabel(due)}`;
}

/** "Hari ini", "Kemarin", or "20 Oktober". */
export function formatDayLabel(date: Date, now: Date = new Date()): string {
  const today = startOfDay(now);
  const day = startOfDay(date);
  const diff = Math.round((day.getTime() - today.getTime()) / 86_400_000);

  if (diff === 0) return 'Hari ini';
  if (diff === -1) return 'Kemarin';

  const month = monthNames[date.getMonth()];
  if (date.getFullYear() === today.getFullYear()) {
    return `${date.getDate()} ${month}`;
  }
  return `${date.getDate()} ${month} ${date.getFullYear()}`;
}

/** "Sen", "Sel", ... for chart labels. */
export function shortWeekday(date: Date): string {
  return (dayNames[date.getDay() === 0 ? 6 : date.getDay() - 1] ?? '').slice(0, 3);
}

export function addDays(date: Date, days: number): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days);
}

export function isSameDay(a: Date, b: Date): boolean {
  return dayKey(a) === dayKey(b);
}

export function differenceInDays(a: Date, b: Date): number {
  return Math.round((startOfDay(a).getTime() - startOfDay(b).getTime()) / 86_400_000);
}

export { startOfDay };
