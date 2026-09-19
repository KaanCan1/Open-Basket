import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:open_basket_flutter/l10n/app_localizations.dart';
import 'package:open_basket_flutter/main.dart';
import 'package:open_basket_flutter/src/core/client_provider.dart';
import 'package:open_basket_flutter/src/features/auth/code_entry_screen.dart';

/// Drives the real screens against a **real running server**. Nothing is
/// stubbed: these calls cross the wire, hit the endpoints, and write rows.
///
///     cd open_basket_server && dart bin/main.dart --apply-migrations
///     cd open_basket_flutter && flutter test integration_test -d <device>
///
/// The happy path needs the six digits the server emailed, and in development
/// those are logged to the server console rather than sent. Pass them in to
/// prove the whole round trip:
///
///     flutter test integration_test -d <device> \
///       --dart-define=SIGN_IN_CODE=407193 --dart-define=SIGN_IN_EMAIL=...
///
/// Without the define the happy-path test is skipped and the rest still runs,
/// so this file is useful either way.
const _suppliedCode = String.fromEnvironment('SIGN_IN_CODE');

/// Used by the tests that only need *an* address.
///
/// Unique per run on purpose. With a fixed address, two runs a few seconds
/// apart land inside the server's 24-second resend window and interfere with
/// each other's codes — which showed up as an intermittent failure until the
/// address stopped being shared.
final _flowEmail = 'flow-${DateTime.now().millisecondsSinceEpoch}@kaya.co';

/// The address the supplied code was issued for. Kept separate from
/// [_flowEmail] on purpose: the request test would otherwise issue a fresh
/// code for the same address and burn the one passed in.
const _suppliedEmail = String.fromEnvironment(
  'SIGN_IN_EMAIL',
  defaultValue: 'happy-path@kaya.co',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Client client;

  setUpAll(() async {
    client = await createClient();
    // A session stored by an earlier run would make the first test fail for
    // the wrong reason, so every run starts signed out.
    if (client.auth.isAuthenticated) await client.auth.signOutDevice();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clientProvider.overrideWithValue(client)],
        child: const OpenBasketApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpCodeEntry(WidgetTester tester, String email) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clientProvider.overrideWithValue(client)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CodeEntryScreen(email: email),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a signed-out app opens on sign-in, not on the household', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Send me a code'), findsOneWidget);
  });

  testWidgets('asking for a code reaches the server and moves the user on', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), _flowEmail);
    await tester.tap(find.text('Send me a code'));
    // The real round trip, not a frame or two. Generous because the first
    // call of a run also pays for connection setup: at five seconds this
    // assertion failed intermittently, which looked like a bug in the app and
    // was a bug in the waiting.
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Getting here means the endpoint accepted the address, issued a code and
    // the app advanced — the whole wire in both directions.
    expect(find.text('Check your email'), findsOneWidget);
  });

  testWidgets('a wrong code comes back worded as a wrong code', (tester) async {
    await pumpCodeEntry(tester, _flowEmail);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Not a generic failure: the server distinguishes a wrong code from an
    // expired or burnt one, and the screen has to keep them apart.
    expect(find.text("That code didn't match"), findsOneWidget);
  });

  testWidgets(
    'the real code signs the user in',
    (tester) async {
      expect(client.auth.isAuthenticated, isFalse, reason: 'start signed out');

      await pumpCodeEntry(tester, _suppliedEmail);
      await tester.enterText(find.byType(TextField), _suppliedCode);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // The session is the proof: the client is holding a token the server
      // minted, which is the end of the round trip.
      expect(client.auth.isAuthenticated, isTrue);

      await client.auth.signOutDevice();
    },
    skip: _suppliedCode.isEmpty,
  );
}
