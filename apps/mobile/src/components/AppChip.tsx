import { Pressable, StyleSheet, View } from 'react-native';

import { colors, radius, sizes, space } from '../theme/tokens';
import { AppIcon, type IconName } from './AppIcon';
import { AppText } from './AppText';

export interface AppChipProps {
  label: string;
  selected?: boolean;
  onPress?: () => void;
  icon?: IconName;
  trailingIcon?: IconName;
  accessibilityLabel?: string;
}

/** Capsule chip. Active: soft orange background, navy bold text. */
export function AppChip({
  label,
  selected = false,
  onPress,
  icon,
  trailingIcon,
  accessibilityLabel,
}: AppChipProps): React.JSX.Element {
  const iconColor = selected ? colors.accentStrong : colors.muted;

  return (
    <Pressable
      accessibilityRole={onPress ? 'button' : undefined}
      accessibilityLabel={accessibilityLabel ?? label}
      accessibilityState={onPress ? { selected } : undefined}
      disabled={!onPress}
      onPress={onPress}
      style={({ pressed }) => [
        styles.chip,
        {
          backgroundColor: selected ? colors.accentSoft : colors.surface,
          borderColor: selected ? colors.accent : colors.border,
          opacity: onPress && pressed ? 0.85 : 1,
        },
      ]}
    >
      {icon ? <AppIcon name={icon} size={16} color={iconColor} /> : null}
      <AppText
        variant="label"
        weight={selected ? 'bold' : 'semibold'}
        color={colors.ink}
      >
        {label}
      </AppText>
      {trailingIcon ? (
        <AppIcon name={trailingIcon} size={16} color={iconColor} />
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  chip: {
    minHeight: sizes.touch,
    borderRadius: radius.chip,
    borderWidth: 1,
    paddingHorizontal: space.lg,
    paddingVertical: space.xs,
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    gap: space.sm,
  },
});

export function ChipRow({ children }: { children: React.ReactNode }): React.JSX.Element {
  return <View style={{ flexDirection: 'row', gap: space.sm }}>{children}</View>;
}
