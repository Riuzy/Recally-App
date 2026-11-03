import { View } from 'react-native';

import { AppText } from '../../components/AppText';
import { formatLongDate, shortWeekday } from '../../format/indonesianDate';
import { colors, space } from '../../theme/tokens';
import type { DayActivity } from './progressStats';

const wideLabelEvery = 7;

/** Review-activity bar chart. Today's bar uses solid orange. */
export function ActivityChart({ days }: { days: DayActivity[] }): React.JSX.Element {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const maxReviews = days.reduce((max, day) => Math.max(max, day.reviews), 0);
  const wide = days.length > 7;

  return (
    <View
      style={{
        height: 148,
        flexDirection: 'row',
        alignItems: 'flex-end',
      }}
    >
      {days.map((day, index) => {
        const fraction =
          maxReviews === 0
            ? 0.02
            : Math.max(0.06, Math.min(1, day.reviews / maxReviews));
        const isToday =
          day.day.getFullYear() === today.getFullYear() &&
          day.day.getMonth() === today.getMonth() &&
          day.day.getDate() === today.getDate();

        return (
          <View
            key={day.day.getTime()}
            style={{
              flex: 1,
              paddingHorizontal: wide ? 1 : 3,
              alignItems: 'center',
            }}
          >
            <View
              accessibilityLabel={`${formatLongDate(day.day)}: ${day.reviews} ulasan`}
              style={{
                height: 110,
                width: '100%',
                justifyContent: 'flex-end',
                alignItems: 'center',
              }}
            >
              <View
                style={{
                  height: Math.max(4, fraction * 110),
                  width: '62%',
                  backgroundColor: isToday ? colors.accent : colors.border,
                  borderTopLeftRadius: 4,
                  borderTopRightRadius: 4,
                }}
              />
            </View>
            <View style={{ height: 14, marginTop: space.sm, alignSelf: 'stretch' }}>
              <AppText
                variant="caption"
                color={colors.muted}
                align="center"
                numberOfLines={1}
                style={wide ? { fontSize: 10 } : undefined}
              >
                {chartLabel(day.day, index, days.length, wide)}
              </AppText>
            </View>
          </View>
        );
      })}
    </View>
  );
}

function chartLabel(
  day: Date,
  index: number,
  length: number,
  wide: boolean,
): string {
  if (!wide) return shortWeekday(day);

  const fromEnd = length - 1 - index;
  if (fromEnd === 0 || fromEnd % wideLabelEvery === 0) return `${day.getDate()}`;
  return '';
}
