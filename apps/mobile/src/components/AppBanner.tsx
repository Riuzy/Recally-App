import { Pressable, StyleSheet, View } from 'react-native';

import { withAlpha } from '../theme/color';
import { colors, radius, space } from '../theme/tokens';
import { AppIcon, type IconName } from './AppIcon';
import { AppText } from './AppText';

export type AppBannerTone = 'info' | 'success' | 'warning' | 'danger';

export interface AppBannerProps {
  message: string;
  tone?: AppBannerTone;
  actionLabel?: string;
  onAction?: () => void;
}

const toneMap: Record<
  AppBannerTone,
  { background: string; border: string; foreground: string; icon: IconName }
> = {
  info: {
    background: colors.infoSoft,
    border: colors.info,
    foreground: colors.ink,
    icon: 'info',
  },
  success: {
    background: colors.successSoft,
    border: colors.success,
    foreground: colors.ink,
    icon: 'checkCircle',
  },
  warning: {
    background: colors.warningSoft,
    border: colors.warning,
    foreground: colors.ink,
    icon: 'warning',
  },
  danger: {
    background: colors.dangerSoft,
    border: colors.danger,
    foreground: colors.danger,
    icon: 'warningCircle',
  },
};

/** Inline banner: icon, message, optional action. */
export function AppBanner({
  message,
  tone = 'info',
  actionLabel,
  onAction,
}: AppBannerProps): React.JSX.Element {
  const spec = toneMap[tone];

  return (
    <View
      accessibilityRole="alert"
      style={[
        styles.container,
        {
          backgroundColor: spec.background,
          borderColor: withAlpha(spec.border, 0.55),
        },
      ]}
    >
      <AppIcon name={spec.icon} size={20} color={spec.foreground} />
      <AppText
        variant="body"
        color={spec.foreground}
        style={styles.message}
      >
        {message}
      </AppText>
      {actionLabel ? (
        <Pressable
          accessibilityRole="button"
          onPress={onAction}
          hitSlop={8}
          style={styles.action}
        >
          <AppText variant="label" weight="bold" color={colors.accentStrong}>
            {actionLabel}
          </AppText>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: space.lg,
    borderRadius: radius.control,
    borderWidth: 1,
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: space.md,
  },
  message: {
    flex: 1,
    lineHeight: 21,
  },
  action: {
    minHeight: 22,
    justifyContent: 'center',
  },
});
