import { Tabs } from 'expo-router';

import { AppTabBar } from '../../src/features/shell/AppTabBar';
import { colors } from '../../src/theme/tokens';

export default function TabsLayout(): React.JSX.Element {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        sceneStyle: { backgroundColor: colors.canvas },
      }}
      tabBar={(props) => <AppTabBar {...props} />}
    >
      <Tabs.Screen name="index" options={{ title: 'Hari Ini' }} />
      <Tabs.Screen name="decks" options={{ title: 'Deck' }} />
      <Tabs.Screen name="progress" options={{ title: 'Progres' }} />
      <Tabs.Screen name="settings" options={{ title: 'Pengaturan' }} />
    </Tabs>
  );
}
