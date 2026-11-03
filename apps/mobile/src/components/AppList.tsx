import { Children, Fragment } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { colors, radius, space } from '../theme/tokens';
import { AppIcon, type IconName } from './AppIcon';
import { AppText } from './AppText';

/** One white container for a list; rows are separated by hairlines. */
export function AppListGroup({
  children,
}: {
  children: React.ReactNode;
}): React.JSX.Element {
  const items = Children.toArray(children);

  return (
    <View style={styles.group}>
      {items.map((child, index) => (
        <Fragment key={index}>
          {index > 0 ? <View style={styles.divider} /> : null}
          {child}
        </Fragment>
      ))}
    </View>
  );
}

export interface AppListRowProps {
  title: string;
  subtitle?: string;
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
  onPress?: () => void;
  showChevron?: boolean;
  destructive?: boolean;
  accessibilityLabel?: string;
}

export function AppListRow({
  title,
  subtitle,
  leading,
  trailing,
  onPress,
  showChevron = false,
  destructive = false,
  accessibilityLabel,
}: AppListRowProps): React.JSX.Element {
  const content = (
    <View style={styles.row}>
      {leading ? <View style={styles.leading}>{leading}</View> : null}
      <View style={styles.text}>
        <AppText
          variant="bodyLarge"
          weight="semibold"
          color={destructive ? colors.danger : colors.ink}
          numberOfLines={2}
        >
          {title}
        </AppText>
        {subtitle ? (
          <AppText
            variant="label"
            weight="regular"
            color={colors.muted}
            numberOfLines={1}
            style={styles.subtitle}
          >
            {subtitle}
          </AppText>
        ) : null}
      </View>
      {trailing ? <View style={styles.trailing}>{trailing}</View> : null}
      {showChevron ? (
        <AppIcon name="caretRight" size={16} color={colors.muted} />
      ) : null}
    </View>
  );

  if (!onPress) return content;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel ?? title}
      onPress={onPress}
      style={({ pressed }) => [
        { backgroundColor: pressed ? colors.surface2 : 'transparent' },
      ]}
    >
      {content}
    </Pressable>
  );
}

/** Circular icon badge used by list rows and cards. */
export function AppIconBadge({
  name,
  size = 36,
  iconSize = 18,
  rounded = 'circle',
}: {
  name: IconName;
  size?: number;
  iconSize?: number;
  rounded?: 'circle' | 'card';
}): React.JSX.Element {
  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: rounded === 'circle' ? size / 2 : radius.card,
        backgroundColor: colors.accentSoft,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <AppIcon name={name} size={iconSize} color={colors.accent} />
    </View>
  );
}

const styles = StyleSheet.create({
  group: {
    backgroundColor: colors.surface,
    borderRadius: radius.card,
    borderWidth: 1,
    borderColor: colors.border,
    overflow: 'hidden',
  },
  divider: {
    height: 1,
    backgroundColor: colors.border,
  },
  row: {
    minHeight: 64,
    paddingHorizontal: space.lg,
    paddingVertical: space.md,
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.md,
  },
  leading: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    flex: 1,
  },
  subtitle: {
    marginTop: space.xs,
  },
  trailing: {
    alignItems: 'flex-end',
    justifyContent: 'center',
  },
});
