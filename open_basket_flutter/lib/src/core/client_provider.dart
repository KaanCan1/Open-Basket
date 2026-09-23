import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// The generated Serverpod client, created once and shared.
///
/// Override this in `main` after [createClient] has finished; reading it
/// before then is a programming error rather than a state to handle, so it
/// throws instead of returning null.
final clientProvider = Provider<Client>(
  (final ref) => throw StateError('clientProvider was not overridden'),
);

Future<Client> createClient() async {
  final client = Client(await getServerUrl())
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // Local only: whatever session this device last had. The first frame must
  // never wait on the network.
  await client.auth.restore();
  unawaited(_validateSession(client));
  return client;
}

/// Checks the restored session with the server, off the startup path.
///
/// This used to be `auth.initialize()`, awaited before `runApp`. It asks the
/// server with a two-second timeout, and although its own documentation says
/// a timeout returns false without signing anyone out, it only catches
/// `ServerpodClientException` — the `TimeoutException` escapes. So a server
/// that took longer than two seconds to answer, which is exactly what a
/// freshly deployed or long-idle one does, left an unhandled exception in
/// `main`, `runApp` never ran, and the app was a white screen for good.
/// Found by relaunching against production a minute after a deploy.
///
/// Offline, a cold server, a timeout: all of them keep the stored session.
/// If it really has expired, validation signs the device out, the auth
/// listenable fires, and the router sends the user to sign in.
Future<void> _validateSession(Client client) async {
  try {
    await client.auth.validateAuthentication(
      timeout: const Duration(seconds: 15),
    );
  } catch (_) {
    // Deliberately quiet. See above.
  }
}

/// Signs this device out. Kept here so screens never have to import the auth
/// package just to end a session.
final signOutProvider = Provider<Future<void> Function()>((final ref) {
  final client = ref.watch(clientProvider);
  return client.auth.signOutDevice;
});

/// Notifies whenever the session changes, which is what makes the router
/// re-run its redirect on sign-in and sign-out.
///
/// This is the auth module's own listenable rather than something derived:
/// routing has to read the current answer synchronously, and a stream that has
/// not emitted yet reads as "no answer", which left an unauthenticated user
/// sitting on the home screen.
/// The signed-in user's id, or null.
///
/// Wrapped here rather than read in a feature: `client.auth` comes from the
/// auth package, and keeping that import in one file means a screen only ever
/// talks to the app's own vocabulary. There is no `authInfo` getter on the
/// session manager despite what its documentation says, so this reads the
/// listenable's current value.
UuidValue? currentUserId(Client client) =>
    client.auth.authInfoListenable.value?.authUserId;

final authListenableProvider = Provider<Listenable>(
  (final ref) => ref.watch(clientProvider).auth.authInfoListenable,
);

/// Whether someone is signed in, right now.
///
/// Accurate from the first build because `createClient` awaits
/// `auth.initialize()`, which is what restores a stored session.
bool isSignedIn(Client client) => client.auth.isAuthenticated;

/// Who is signed in, as a value providers can depend on.
///
/// Every provider that fetches someone's data watches this, so the moment
/// the account changes they are thrown away and fetched again. Without it a
/// phone signed out and signed in as someone else kept showing the first
/// person's household, history and code — Riverpod caches by provider, not
/// by account (ADR-045).
final sessionUserProvider = NotifierProvider<SessionUser, UuidValue?>(
  SessionUser.new,
);

class SessionUser extends Notifier<UuidValue?> {
  @override
  UuidValue? build() {
    final listenable = ref.watch(authListenableProvider);
    void update() {
      final now = currentUserId(ref.read(clientProvider));
      if (now != state) state = now;
    }

    listenable.addListener(update);
    ref.onDispose(() => listenable.removeListener(update));
    return currentUserId(ref.read(clientProvider));
  }
}
