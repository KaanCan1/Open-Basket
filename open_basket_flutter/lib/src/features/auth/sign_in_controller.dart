import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../core/client_provider.dart';

/// What went wrong, in the terms the screens care about.
///
/// The server tells a wrong code, an expired one and a burnt one apart on
/// purpose (ADR-004) — the screens word them differently, and a user who
/// cannot tell them apart retypes the same dead code forever.
enum SignInFailure {
  wrongCode,
  expiredCode,
  tooManyAttempts,
  badEmail,
  offline,
}

SignInFailure failureFrom(Object error) {
  if (error is OpenBasketException) {
    return switch (error.error) {
      BasketError.signInCodeExpired => SignInFailure.expiredCode,
      BasketError.tooManySignInAttempts => SignInFailure.tooManyAttempts,
      BasketError.invalidSignInCode => SignInFailure.wrongCode,
      BasketError.invalidEmailAddress => SignInFailure.badEmail,
      _ => SignInFailure.offline,
    };
  }
  return SignInFailure.offline;
}

class SignInController {
  SignInController(this._ref);

  final Ref _ref;

  Client get _client => _ref.read(clientProvider);

  /// Asks the server to email a code. Inside the resend cooldown the server
  /// quietly keeps the code already in flight, so calling this twice is safe.
  Future<void> requestCode(String email) =>
      _client.signIn.requestSignInCode(email);

  /// Exchanges the code for a session.
  ///
  /// The endpoint hands back an `AuthSuccess`, but nothing adopts it on its
  /// own: the bundled providers store the token through their own client-side
  /// helpers, and our flow has none. Without this call the code verified, the
  /// server minted a session, and the app stayed signed out — which is exactly
  /// what the integration test caught.
  ///
  /// Storing it also flips `authInfoListenable`, which is what makes the
  /// router re-run its redirect and move the user on.
  Future<void> verifyCode(String email, String code) async {
    final success = await _client.signIn.verifySignInCode(email, code);
    await _client.auth.updateSignedInUser(success);
  }
}

final signInControllerProvider = Provider<SignInController>(
  SignInController.new,
);
