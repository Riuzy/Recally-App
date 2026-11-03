import { StyleSheet, View } from 'react-native';

import { colors, sizes, space } from '../theme/tokens';
import { AppIcon, type IconName } from './AppIcon';
import { AppText } from './AppText';

export interface AppEmptyStateProps {
  icon: IconName;
  title: string;
  message?: string;
  action?: React.ReactNode;
}

/** One soft icon, one title, one explanation, one action. */
export function AppEmptyState({
  icon,
  title,
  message,
  action,
}: AppEmptyStateProps): React.JSX.Element {
  return (
    <View style={styles.container}>
      <View style={styles.iconCircle}>
        <AppIcon name={icon} size={32} color={colors.accentStrong} />
      </View>
      <AppText variant="h1" align="center" style={styles.title}>
        {title}
      </AppText>
      {message ? (
        <AppText variant="body" color={colors.muted} align="center" style={styles.message}>
          {message}
        </AppText>
      ) : null}
      {action ? <View style={styles.action}>{action}</View> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: space.xxl,
    paddingVertical: space.xxxl,
  },
  iconCircle: {
    width: sizes.emptyIcon,
    height: sizes.emptyIcon,
    borderRadius: sizes.emptyIcon / 2,
    backgroundColor: colors.accentSoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    marginTop: space.xl,
  },
  message: {
    marginTop: space.sm,
  },
  action: {
    marginTop: space.xxl,
  },
});
