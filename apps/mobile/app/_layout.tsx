import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { ActivityIndicator, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { DatabaseProvider } from '../src/db/provider';
import { colors } from '../src/theme/tokens';

export default function RootLayout(): React.JSX.Element {
  const [fontsLoaded] = useFonts({
    Inter_400Regular: require('../assets/fonts/Inter-Regular.ttf'),
    Inter_500Medium: require('../assets/fonts/Inter-Medium.ttf'),
    Inter_600SemiBold: require('../assets/fonts/Inter-SemiBold.ttf'),
    Inter_700Bold: require('../assets/fonts/Inter-Bold.ttf'),
  });

  if (!fontsLoaded) {
    return (
      <View
        style={{
          flex: 1,
          backgroundColor: colors.canvas,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <ActivityIndicator color={colors.accent} />
      </View>
    );
  }

  return (
    <SafeAreaProvider>
      <DatabaseProvider>
        <StatusBar style="dark" />
        <Stack
          screenOptions={{
            headerShown: false,
            contentStyle: { backgroundColor: colors.canvas },
            animation: 'fade',
          }}
        >
          <Stack.Screen name="(tabs)" />
          <Stack.Screen
            name="session"
            options={{ animation: 'slide_from_bottom' }}
          />
        </Stack>
      </DatabaseProvider>
    </SafeAreaProvider>
  );
}
