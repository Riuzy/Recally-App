import { Pressable, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { colors, sizes, space } from '../theme/tokens';
import { AppText } from './AppText';

export interface AppPageProps {
  title: string;
  children: React.ReactNode;
  subtitle?: string;
  eyebrow?: string;
  trailing?: React.ReactNode;
  leading?: React.ReactNode;
}

/**
 * Screen frame: 20px margin, 20px bold title, 24px gap to content. The child
 * is expected to be a scroll view or a full-height state.
 */
export function AppPage({
  title,
  children,
  subtitle,
  eyebrow,
  trailing,
  leading,
}: AppPageProps): React.JSX.Element {
  const insets = useSafeAreaInsets();

  return (
    <View
      style={[
        styles.page,
        { paddingTop: space.xl + insets.top },
      ]}
    >
      <View style={styles.header}>
        {leading ? <View style={styles.leading}>{leading}</View> : null}
        <View style={styles.heading}>
          {eyebrow ? (
            <AppText variant="overline" color={colors.muted} style={styles.eyebrow}>
              {eyebrow}
            </AppText>
          ) : null}
          <AppText variant="h1">{title}</AppText>
          {subtitle ? (
            <AppText variant="body" color={colors.muted} style={styles.subtitle}>
              {subtitle}
            </AppText>
          ) : null}
        </View>
        {trailing ? <View style={styles.trailing}>{trailing}</View> : null}
      </View>
      <View style={styles.content}>{children}</View>
    </View>
  );
}

/** 44x44 icon button used in headers. */
export function AppIconButton({
  children,
  onPress,
  label,
}: {
  children: React.ReactNode;
  onPress?: () => void;
  label: string;
}): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      style={({ pressed }) => [
        styles.iconButton,
        pressed ? { backgroundColor: colors.surface2 } : null,
      ]}
    >
      {children}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  page: {
    flex: 1,
    backgroundColor: colors.canvas,
    paddingHorizontal: sizes.screenMargin,
    paddingBottom: space.xxl,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 44,
  },
  leading: {
    marginRight: space.sm,
  },
  heading: {
    flex: 1,
  },
  eyebrow: {
    marginBottom: space.xs,
  },
  subtitle: {
    marginTop: space.xs,
  },
  trailing: {
    marginLeft: space.md,
  },
  content: {
    flex: 1,
    marginTop: space.xxl,
  },
  iconButton: {
    width: sizes.touch,
    height: sizes.touch,
    borderRadius: sizes.touch / 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
