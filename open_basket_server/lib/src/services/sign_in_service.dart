import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../util/sign_in_code_policy.dart';
import 'sign_in_email_sender.dart';

/// Passwordless sign-in (ADR-004).
///
/// The bundled email provider is password-based, so this flow is ours: issue a
/// six-digit code, check it, and mint a session through the same token manager
/// every other provider uses. Accounts are created on first successful code,
/// not on request — otherwise typing a stranger's address would create an
/// account for them.
abstract final class SignInService {
  /// Reused from the template's `passwords.yaml`, which already defines it in
  /// every run mode. One less secret to distribute.
  static const _pepperKey = 'emailSecretHashPepper';

  static String _pepper(Session session) {
    final pepper = session.passwords[_pepperKey];
    if (pepper == null || pepper.isEmpty) {
      // Refusing is the right failure: hashing with a constant fallback would
      // look like it worked while quietly removing the protection.
      throw StateError(
        'No $_pepperKey in passwords.yaml. Sign-in codes cannot be hashed.',
      );
    }
    return pepper;
  }

  /// Issues a code and emails it.
  ///
  /// Answers identically whether or not the address has an account — the
  /// response must never be a way to find out who has signed up.
  ///
  /// Inside the resend cooldown this does nothing and returns: the code
  /// already in flight stays valid. That is what the countdown on the resend
  /// button is enforcing, and it stops the endpoint being used to send
  /// somebody a stream of email.
  static Future<void> requestCode(Session session, String email) async {
    if (!SignInCodePolicy.looksLikeEmail(email)) {
      throw OpenBasketException(
        error: BasketError.invalidSignInCode,
        message: 'That does not look like an email address.',
      );
    }
    final address = SignInCodePolicy.normalizeEmail(email);

    final latest = await _latestCodeFor(session, address);
    if (latest != null &&
        DateTime.now().toUtc().difference(latest.createdAt) <
            SignInCodePolicy.resendCooldown) {
      return;
    }

    // Anything still outstanding for this address stops working the moment a
    // new code is issued (ADR-004).
    await _burnOutstandingCodes(session, address);

    final code = SignInCodePolicy.generate();
    await SignInCode.db.insertRow(
      session,
      SignInCode(
        email: address,
        codeHash: SignInCodePolicy.hash(
          email: address,
          code: code,
          pepper: _pepper(session),
        ),
        expiresAt: DateTime.now().toUtc().add(SignInCodePolicy.lifetime),
      ),
    );

    await SignInEmailSender.send(session, email: address, code: code);
  }

  /// Exchanges a code for a session, creating the account on first use.
  ///
  /// The three failures are told apart deliberately: the screens word a wrong
  /// code, an expired one and a burnt one differently, and a user who cannot
  /// tell them apart retypes the same dead code forever.
  static Future<AuthSuccess> verifyCode(
    Session session,
    String email,
    String code,
  ) async {
    final address = SignInCodePolicy.normalizeEmail(email);
    final typed = SignInCodePolicy.normalizeCode(code);
    if (typed == null) {
      throw OpenBasketException(
        error: BasketError.invalidSignInCode,
        message: 'Enter the six digits we emailed you.',
      );
    }

    final record = await _latestCodeFor(session, address);
    if (record == null) {
      throw OpenBasketException(
        error: BasketError.invalidSignInCode,
        message: 'That code did not match.',
      );
    }

    if (DateTime.now().toUtc().isAfter(record.expiresAt)) {
      throw OpenBasketException(
        error: BasketError.signInCodeExpired,
        message: 'That code has expired. We can send you a new one.',
      );
    }

    if (record.attemptsRemaining <= 0) {
      throw OpenBasketException(
        error: BasketError.tooManySignInAttempts,
        message: 'Too many tries. We can send you a new code.',
      );
    }

    final expected = SignInCodePolicy.hash(
      email: address,
      code: typed,
      pepper: _pepper(session),
    );
    if (!SignInCodePolicy.hashesMatch(record.codeHash, expected)) {
      final remaining = record.attemptsRemaining - 1;
      await SignInCode.db.updateRow(
        session,
        record.copyWith(attemptsRemaining: remaining),
      );
      throw OpenBasketException(
        error: remaining <= 0
            ? BasketError.tooManySignInAttempts
            : BasketError.invalidSignInCode,
        message: remaining <= 0
            ? 'Too many tries. We can send you a new code.'
            : 'That code did not match.',
      );
    }

    // Consumed before the session is minted, so the same code cannot be
    // redeemed twice by two requests arriving together.
    await SignInCode.db.updateRow(
      session,
      record.copyWith(consumedAt: DateTime.now().toUtc()),
    );

    final authUserId = await _findOrCreateAccount(session, address);
    return AuthServices.instance.tokenManager.issueToken(
      session,
      authUserId: authUserId,
      method: 'email_code',
    );
  }

  /// The newest code for an address that has not been used yet. Burnt and
  /// consumed codes are left in the table: they are the audit trail for a
  /// household that reports not being able to get in.
  static Future<SignInCode?> _latestCodeFor(
    Session session,
    String address,
  ) {
    return SignInCode.db.findFirstRow(
      session,
      where: (final t) => t.email.equals(address) & t.consumedAt.equals(null),
      orderByList: (final t) => [t.createdAt.desc()],
    );
  }

  static Future<void> _burnOutstandingCodes(
    Session session,
    String address,
  ) async {
    final outstanding = await SignInCode.db.find(
      session,
      where: (final t) => t.email.equals(address) & t.consumedAt.equals(null),
    );
    if (outstanding.isEmpty) return;
    final now = DateTime.now().toUtc();
    await SignInCode.db.update(
      session,
      [for (final row in outstanding) row.copyWith(consumedAt: now)],
    );
  }

  /// Existing account, or a new one. The profile carries the address, which is
  /// how we find the account again next time.
  static Future<UuidValue> _findOrCreateAccount(
    Session session,
    String address,
  ) async {
    final profiles = await AuthServices.instance.userProfiles.admin
        .listUserProfiles(session, email: address, limit: 1);
    final existing = profiles.firstOrNull;
    if (existing != null) return existing.authUserId;

    final authUser = await AuthServices.instance.authUsers.create(session);
    await AuthServices.instance.userProfiles.createUserProfile(
      session,
      authUser.id,
      UserProfileData(email: address),
    );
    return authUser.id;
  }
}
