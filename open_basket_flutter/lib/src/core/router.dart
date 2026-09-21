import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/code_entry_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/household/create_household_screen.dart';
import '../features/household/household_home_screen.dart';
import '../features/household/join_household_screen.dart';
import 'client_provider.dart';

abstract final class Routes {
  static const signIn = '/sign-in';
  static const codeEntry = '/sign-in/code';
  static const home = '/';
  static const createHousehold = '/household/new';
  static const joinHousehold = '/household/join';
}

final routerProvider = Provider<GoRouter>((final ref) {
  final client = ref.watch(clientProvider);

  return GoRouter(
    initialLocation: Routes.home,
    // Without this the redirect runs once, at startup, and never again — so
    // signing in left the user on the sign-in screen and a signed-out user sat
    // on the home screen. Only running the app showed it.
    refreshListenable: ref.watch(authListenableProvider),
    redirect: (final context, final state) {
      final signedIn = isSignedIn(client);
      final onAuthScreen = state.matchedLocation.startsWith(Routes.signIn);
      if (!signedIn && !onAuthScreen) return Routes.signIn;
      if (signedIn && onAuthScreen) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (final context, final state) => const HouseholdHomeScreen(),
        routes: [
          GoRoute(
            path: 'household/new',
            builder: (final context, final state) =>
                const CreateHouseholdScreen(),
          ),
          GoRoute(
            path: 'household/join',
            builder: (final context, final state) =>
                const JoinHouseholdScreen(),
          ),
        ],
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
