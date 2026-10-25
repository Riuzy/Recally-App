import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/settings/theme_mode_provider.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase opsional: kegagalan inisialisasi tidak menghalangi mode lokal.
  await FirebaseBootstrap.initialize();

  runApp(const ProviderScope(child: RecallyApp()));
}

class RecallyApp extends ConsumerWidget {
  const RecallyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Recally',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
