import { View } from 'react-native';

import { colors, sizes } from '../theme/tokens';

/** Capsule progress track with a solid orange fill. */
export function AppProgressBar({
  value,
  height = sizes.progress,
}: {
  value: number;
  height?: number;
}): React.JSX.Element {
  const clamped = Math.max(0, Math.min(1, value));

  return (
    <View
      accessibilityRole="progressbar"
      accessibilityValue={{ min: 0, max: 100, now: Math.round(clamped * 100) }}
      style={{
        height,
        width: '100%',
        borderRadius: height / 2,
        backgroundColor: colors.surface3,
        overflow: 'hidden',
      }}
    >
      <View
        style={{
          width: `${clamped * 100}%`,
          height: '100%',
          borderRadius: height / 2,
          backgroundColor: colors.accent,
        }}
      />
    </View>
  );
}

/** Segmented bar for the mastery breakdown. */
export function AppSegmentedBar({
  segments,
  height = sizes.progress,
}: {
  segments: { value: number; color: string }[];
  height?: number;
}): React.JSX.Element {
  const total = segments.reduce((sum, segment) => sum + segment.value, 0);

  return (
    <View
      style={{
        height,
        width: '100%',
        borderRadius: height / 2,
        backgroundColor: colors.surface3,
        overflow: 'hidden',
        flexDirection: 'row',
      }}
    >
      {total === 0
        ? null
        : segments.map((segment, index) =>
            segment.value > 0 ? (
              <View
                key={index}
                style={{
                  flex: segment.value,
                  backgroundColor: segment.color,
                }}
              />
            ) : null,
          )}
    </View>
  );
}
