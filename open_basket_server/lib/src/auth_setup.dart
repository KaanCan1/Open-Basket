import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// One definition of how authentication is configured, used by both
/// `server.dart` and the integration tests.
///
/// The test harness does not run `server.dart`, so without this the endpoints
/// would run against an uninitialised `AuthServices` and every sign-in would
/// fail with "AuthServices is not set". Sharing the lists also stops the two
/// setups drifting apart, which would make the tests prove something the real
/// server does not do.
abstract final class AuthSetup {
  /// Shown to recipients of the emails the bundled provider sends.
  static const appDisplayName = 'open_basket';

  /// JWT for authentication keys towards the server (ADR-039).
  ///
  /// The defaults are ten minutes and fourteen days. On Serverpod Cloud a
  /// refresh takes three to four seconds, and the client makes the next call
  /// wait for it, so ten minutes put a stall in the middle of most shopping
  /// runs. An hour covers a run; a signed-out session stays usable for at
  /// most that long, which a shopping list can live with.
  static const accessTokenLifetime = Duration(hours: 1);

  /// Sliding: every refresh restarts it. A house that shops fortnightly
  /// should not be signed out between runs.
  static const refreshTokenLifetime = Duration(days: 90);

  static List<TokenManagerBuilder> tokenManagerBuilders() => [
    JwtConfigFromPasswords(
      accessTokenLifetime: accessTokenLifetime,
      refreshTokenLifetime: refreshTokenLifetime,
    ),
  ];

  /// The bundled email provider stays wired up even though our own sign-in is
  /// passwordless (ADR-004): it owns the account and profile tables our flow
  /// writes into, and leaving it out would change what the tests exercise.
  static List<IdentityProviderBuilder> identityProviderBuilders() => [
    ServerpodCloudEmailIdpConfig(appDisplayName: appDisplayName),
  ];

  /// For tests, which have no `server.dart` to call `initializeAuthServices`.
  static void configureForTests() {
    AuthServices.set(
      tokenManagerBuilders: tokenManagerBuilders(),
      identityProviderBuilders: identityProviderBuilders(),
    );
  }
}
