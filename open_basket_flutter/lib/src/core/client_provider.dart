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
  await client.auth.initialize();
  return client;
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
final authListenableProvider = Provider<Listenable>(
  (final ref) => ref.watch(clientProvider).auth.authInfoListenable,
);

/// Whether someone is signed in, right now.
///
/// Accurate from the first build because `createClient` awaits
/// `auth.initialize()`, which is what restores a stored session.
bool isSignedIn(Client client) => client.auth.isAuthenticated;
