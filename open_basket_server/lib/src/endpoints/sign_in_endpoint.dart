import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../services/sign_in_service.dart';

/// Passwordless sign-in: the user types an email address, we email a six-digit
/// code, they type it back (ADR-004).
///
/// The bundled email identity provider is password-based — its only code flows
/// are registration verification and password reset — so this flow is ours.
/// The policy lives in [SignInService]; this is the wire.
/// Named `SignInEndpoint`, not `AuthEndpoint`, so the client reaches it at
/// `client.signIn`. `client.auth` belongs to the Serverpod auth module — the
/// session manager, `isAuthenticated`, sign-out — and an endpoint called
/// `auth` silently shadows all of it.
class SignInEndpoint extends Endpoint {
  /// Issues a code and emails it. Invalidates any code still outstanding for
  /// this address.
  ///
  /// Returns the same result whether or not the address already has an
  /// account: the response must not reveal who has signed up. Inside the
  /// resend cooldown it does nothing and the code already in flight stays
  /// valid.
  Future<void> requestSignInCode(Session session, String email) {
    return SignInService.requestCode(session, email);
  }

  /// Exchanges a code for a session, creating the account on first use.
  ///
  /// Throws `OpenBasketException` with `invalidSignInCode`, `signInCodeExpired`
  /// or `tooManySignInAttempts` so the client can tell the three apart — the
  /// screens word them differently.
  Future<AuthSuccess> verifySignInCode(
    Session session,
    String email,
    String code,
  ) {
    return SignInService.verifyCode(session, email, code);
  }
}
