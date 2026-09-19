import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'src/core/client_provider.dart';
import 'src/core/router.dart';
import 'src/core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = await createClient();
  runApp(
    ProviderScope(
      overrides: [clientProvider.overrideWithValue(client)],
      child: const OpenBasketApp(),
    ),
  );
}

class OpenBasketApp extends ConsumerWidget {
  const OpenBasketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched, not read: signing in or out has to rebuild the router so its
    // redirect runs again.
    ref.watch(authStateProvider);

    return MaterialApp.router(
      title: 'Open Basket',
      debugShowCheckedModeBanner: false,
      theme: buildOpenBasketTheme(Brightness.light),
      darkTheme: buildOpenBasketTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
