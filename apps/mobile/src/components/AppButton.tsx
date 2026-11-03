import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  View,
  type ViewStyle,
} from 'react-native';

import { withAlpha } from '../theme/color';
import { colors, radius, sizes } from '../theme/tokens';
import { AppIcon, type IconName } from './AppIcon';
import { AppText } from './AppText';

export type AppButtonVariant = 'primary' | 'secondary' | 'text' | 'danger';

export interface AppButtonProps {
  label: string;
  onPress?: () => void;
  variant?: AppButtonVariant;
  icon?: IconName;
  loading?: boolean;
  expand?: boolean;
  style?: ViewStyle;
  accessibilityHint?: string;
}

/** Premium pill button. Text on orange is always navy. */
export function AppButton({
  label,
  onPress,
  variant = 'primary',
  icon,
  loading = false,
  expand = true,
  style,
  accessibilityHint,
}: AppButtonProps): React.JSX.Element {
  const enabled = onPress !== undefined && !loading;
  const height = variant === 'text' ? sizes.textButton : sizes.button;
  const foreground = !enabled
    ? colors.muted
    : variant === 'primary'
      ? colors.ink
      : variant === 'secondary'
        ? colors.ink
        : variant === 'text'
          ? colors.accentStrong
          : colors.surface;

  const background = !enabled
    ? colors.surface3
    : variant === 'primary'
      ? colors.accent
      : variant === 'secondary'
        ? colors.surface
        : variant === 'text'
          ? 'transparent'
          : colors.danger;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityHint={accessibilityHint}
      accessibilityState={{ disabled: !enabled, busy: loading }}
      disabled={!enabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.base,
        {
          height,
          alignSelf: expand ? 'stretch' : 'flex-start',
          backgroundColor: background,
          borderWidth: variant === 'secondary' ? 1 : 0,
          borderColor: colors.border,
          opacity: enabled && pressed ? 0.85 : 1,
          paddingHorizontal: variant === 'text' ? 12 : 20,
        },
        variant === 'secondary' && enabled ? styles.secondaryShadow : null,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator size="small" color={foreground} />
      ) : icon ? (
        <AppIcon name={icon} size={20} color={foreground} />
      ) : null}
      <AppText
        variant="body"
        weight="semibold"
        color={foreground}
        numberOfLines={1}
        style={styles.label}
      >
        {label}
      </AppText>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    minHeight: sizes.button,
    borderRadius: radius.pill,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  label: {
    flexShrink: 1,
  },
  secondaryShadow: {
    shadowColor: withAlpha(colors.border, 0.2),
    shadowOpacity: 1,
    shadowRadius: 2,
    shadowOffset: { width: 0, height: 1 },
    elevation: 1,
  },
});

export const buttonStyles = StyleSheet.create({
  spacer: { height: 8 },
});

export function AppButtonSpacer({ size = 8 }: { size?: number }): React.JSX.Element {
  return <View style={{ height: size }} />;
}
