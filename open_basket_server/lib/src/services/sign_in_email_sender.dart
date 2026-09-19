import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Delivers the six-digit sign-in code.
///
/// In development and test the code is written to the console, which is what
/// the bundled email provider does too — so a developer never waits on a real
/// inbox, and the integration tests can read the code back.
///
/// In staging and production it goes through the same hosted transactional
/// service the bundled provider uses, reading the `scloudAuthEmailKey`
/// password that Serverpod Cloud supplies. We call the client directly because
/// our sign-in flow is our own: the bundled provider only sends codes for
/// registration verification and password reset (ADR-004).
abstract final class SignInEmailSender {
  /// Name shown to the recipient.
  static const appDisplayName = 'Open Basket';

  /// The `passwords.yaml` key Serverpod Cloud fills in.
  static const _emailKeyName = 'scloudAuthEmailKey';

  /// Overridable so tests can assert what would have been sent without
  /// reaching the network.
  static ServerpodCloudEmailClient client = ServerpodCloudEmailClient();

  /// The last code handed to [send], in development and test only. The
  /// integration tests read it instead of scraping the log.
  static String? lastCodeForTesting;

  static bool get _isDevelopment {
    final runMode = Serverpod.instance.runMode;
    return runMode == ServerpodRunMode.development ||
        runMode == ServerpodRunMode.test;
  }

  /// Best-effort, exactly like the bundled provider: a delivery failure is
  /// logged and swallowed.
  ///
  /// Never propagating matters here for a reason beyond robustness. If a send
  /// failure surfaced to the client, the difference between a delivered and an
  /// undelivered code would tell an attacker which addresses have accounts —
  /// and `requestSignInCode` is careful to answer identically either way.
  static Future<void> send(
    Session session, {
    required String email,
    required String code,
  }) async {
    if (_isDevelopment) {
      lastCodeForTesting = code;
      session.log(
        'Sign-in code for $email: $code',
        level: LogLevel.info,
      );
      return;
    }

    final token = session.passwords[_emailKeyName];
    if (token == null) {
      session.log(
        'No $_emailKeyName in passwords.yaml — the sign-in code for $email '
        'was not sent. Self-hosted servers need their own sender here.',
        level: LogLevel.error,
      );
      return;
    }

    try {
      await client.sendEmail(
        token: token,
        emailType: ServerpodCloudEmailType.signup,
        email: email,
        projectName: appDisplayName,
        authCode: code,
      );
    } catch (e, stackTrace) {
      session.log(
        'Failed to send a sign-in code to $email',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }
}
