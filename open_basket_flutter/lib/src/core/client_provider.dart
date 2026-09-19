import 'dart:async';

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

/// Whether someone is signed in, rebuilt whenever that changes.
///
/// The session manager keeps the token across restarts, so this is also what
/// decides whether a cold start lands on sign-in or on the household.
final authStateProvider = StreamProvider<bool>((final ref) {
  final client = ref.watch(clientProvider);
  final controller = StreamController<bool>();

  void emit() => controller.add(client.auth.isAuthenticated);

  client.auth.authInfoListenable.addListener(emit);
  emit();

  ref.onDispose(() {
    client.auth.authInfoListenable.removeListener(emit);
    controller.close();
  });

  return controller.stream;
});
