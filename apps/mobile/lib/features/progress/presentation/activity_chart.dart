import 'package:flutter/material.dart';

import '../../../core/format/indonesian_date.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/progress_stats.dart';

/// Grafik batang aktivitas ulasan. Batang hari ini memakai oranye solid.
class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key, required this.days});

  final List<DayActivity> days;

  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxReviews = days.fold<int>(
      0,
      (max, day) => day.reviews > max ? day.reviews : max,
    );
    final wide = days.length > 7;

    return SizedBox(
      height: 148,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < days.length; index++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: wide ? 1 : 3),
                child: Semantics(
                  label:
                      '${formatLongDate(days[index].day)}: '
                      '${days[index].reviews} ulasan',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: maxReviews == 0
                                ? 0.02
                                : (days[index].reviews / maxReviews).clamp(
                                    0.06,
                                    1.0,
                                  ),
                            widthFactor: 0.62,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: _isToday(days[index].day, today)
                                    ? colors.accent
                                    : colors.border,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: theme.space2),
                      SizedBox(
                        height: 14,
                        child: Text(
                          _label(days[index].day, index, wide),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: colors.muted,
                            fontSize: wide ? 10 : 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isToday(DateTime day, DateTime today) =>
      day.year == today.year &&
      day.month == today.month &&
      day.day == today.day;

  String _label(DateTime day, int index, bool wide) {
    if (!wide) return _weekdays[day.weekday - 1];

    final fromEnd = days.length - 1 - index;
    if (fromEnd == 0 || fromEnd % 7 == 0) return '${day.day}';
    return '';
  }
}
