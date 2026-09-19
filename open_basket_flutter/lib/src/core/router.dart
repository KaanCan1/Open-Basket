import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/code_entry_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/home/home_placeholder_screen.dart';
import 'client_provider.dart';

abstract final class Routes {
  static const signIn = '/sign-in';
  static const codeEntry = '/sign-in/code';
  static const home = '/';
}

final routerProvider = Provider<GoRouter>((final ref) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (final context, final state) {
      // While the stored session is still being read, stay put rather than
      // bouncing the user to sign-in and back.
      final signedIn = ref.read(authStateProvider).value;
      if (signedIn == null) return null;

      final onAuthScreen = state.matchedLocation.startsWith(Routes.signIn);
      if (!signedIn && !onAuthScreen) return Routes.signIn;
      if (signedIn && onAuthScreen) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (final context, final state) => const HomePlaceholderScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (final context, final state) => const SignInScreen(),
        routes: [
          GoRoute(
            path: 'code',
            builder: (final context, final state) =>
                CodeEntryScreen(email: state.extra! as String),
          ),
        ],
      ),
    ],
  );
});
