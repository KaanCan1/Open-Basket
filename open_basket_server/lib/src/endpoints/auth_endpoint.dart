import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

/// Passwordless sign-in: the user types an email address, we email a six-digit
/// code, they type it back (ADR-004).
///
/// The bundled email identity provider is password-based — its only code flows
/// are registration verification and password reset — so this flow is ours.
/// `ServerSideSessions.createSession(session, authUserId:, method:)` in
/// `serverpod_auth_core_server` is what mints the session once a code checks
/// out; look up or create the `AuthUser` for the address first.
///
/// Policy, enforced here and not in the UI: a code expires 10 minutes after it
/// is issued, survives 3 failed attempts, and is invalidated the moment a new
/// code is issued for the same address.
class AuthEndpoint extends Endpoint {
  /// Issues a code and emails it. Invalidates any code still outstanding for
  /// this address.
  ///
  /// Returns the same result whether or not the address already has an account:
  /// the response must not reveal who has signed up. Rate limited per address.
  Future<void> requestSignInCode(Session session, String email) async {
    throw UnimplementedError('Day 3-4');
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
  ) async {
    throw UnimplementedError('Day 3-4');
  }
}
