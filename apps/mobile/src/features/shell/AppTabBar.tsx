import type { BottomTabBarProps } from 'expo-router/tabs';
import { Pressable, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { colors, radius, sizes, space } from '../../theme/tokens';
import { AppIcon, type IconName } from '../../components/AppIcon';
import { AppText } from '../../components/AppText';

const tabMap: Record<string, { label: string; icon: IconName }> = {
  index: { label: 'Hari Ini', icon: 'calendarBlank' },
  decks: { label: 'Deck', icon: 'cards' },
  progress: { label: 'Progres', icon: 'chartLine' },
  settings: { label: 'Pengaturan', icon: 'gear' },
};

/** White 72px bottom navigation with a soft orange active pill. */
export function AppTabBar({
  state,
  navigateToTab,
}: BottomTabBarProps): React.JSX.Element {
  const insets = useSafeAreaInsets();

  return (
    <View
      style={[
        styles.bar,
        { paddingBottom: insets.bottom, height: sizes.nav + insets.bottom },
      ]}
    >
      {state.routes.map((route, index) => {
        const spec = tabMap[route.name] ?? {
          label: route.name,
          icon: 'cards' as const,
        };
        const selected = state.index === index;

        return (
          <Pressable
            key={route.key}
            accessibilityRole="tab"
            accessibilityLabel={spec.label}
            accessibilityState={{ selected }}
            style={styles.tab}
            onPress={() => {
              if (!selected) navigateToTab(route.key);
            }}
          >
            <View
              style={[
                styles.iconPill,
                selected ? { backgroundColor: colors.accentSoft } : null,
              ]}
            >
              <AppIcon
                name={spec.icon}
                size={20}
                color={selected ? colors.accentStrong : colors.muted}
              />
            </View>
            <AppText
              variant="label"
              weight={selected ? 'bold' : 'medium'}
              color={selected ? colors.ink : colors.muted}
              style={styles.label}
            >
              {spec.label}
            </AppText>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  bar: {
    flexDirection: 'row',
    backgroundColor: colors.surface,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: space.xs,
  },
  iconPill: {
    width: 40,
    height: 28,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    textAlign: 'center',
  },
});
