import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/sign_in_email_sender.dart';
import 'package:open_basket_server/src/util/sign_in_code_policy.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// The code the sender captured. In development and test it is logged rather
/// than emailed, so this is how a test learns what the user would have typed.
String get _sentCode {
  final code = SignInEmailSender.lastCodeForTesting;
  expect(code, isNotNull, reason: 'no sign-in code was sent');
  return code!;
}

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

void main() {
  withServerpod('Given the auth endpoint', (sessionBuilder, endpoints) {
    setUp(() => SignInEmailSender.lastCodeForTesting = null);

    test('a six-digit code is sent and signs the user in', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, 'kaan@kaya.co');

      expect(_sentCode, hasLength(6));

      final success = await endpoints.auth.verifySignInCode(
        sessionBuilder,
        'kaan@kaya.co',
        _sentCode,
      );
      expect(success.authUserId, isNotNull);
    });

    test('the same address signs in to the same account twice', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, 'ayse@kaya.co');
      final first = await endpoints.auth.verifySignInCode(
        sessionBuilder,
        'ayse@kaya.co',
        _sentCode,
      );

      // Past the resend cooldown by clearing the trail the first request left.
      await SignInCode.db.deleteWhere(
        sessionBuilder.build(),
        where: (final t) => t.email.equals('ayse@kaya.co'),
      );

      await endpoints.auth.requestSignInCode(sessionBuilder, 'ayse@kaya.co');
      final second = await endpoints.auth.verifySignInCode(
        sessionBuilder,
        'ayse@kaya.co',
        _sentCode,
      );

      expect(second.authUserId, first.authUserId);
    });

    test('a wrong code is rejected and does not sign anyone in', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, 'deniz@kaya.co');
      final real = _sentCode;
      final wrong = real == '000000' ? '111111' : '000000';

      await expectLater(
        endpoints.auth.verifySignInCode(sessionBuilder, 'deniz@kaya.co', wrong),
        throwsA(
          predicate(
            (final e) => _errorOf(e) == BasketError.invalidSignInCode,
          ),
        ),
      );

      // The real code still works: one wrong guess must not burn it.
      final success = await endpoints.auth.verifySignInCode(
        sessionBuilder,
        'deniz@kaya.co',
        real,
      );
      expect(success.authUserId, isNotNull);
    });

    test('the code dies after three wrong guesses', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, 'mert@kaya.co');
      final real = _sentCode;
      final wrong = real == '000000' ? '111111' : '000000';

      for (
        var attempt = 1;
        attempt <= SignInCodePolicy.maxAttempts;
        attempt++
      ) {
        final expected = attempt < SignInCodePolicy.maxAttempts
            ? BasketError.invalidSignInCode
            : BasketError.tooManySignInAttempts;
        await expectLater(
          endpoints.auth.verifySignInCode(
            sessionBuilder,
            'mert@kaya.co',
            wrong,
          ),
          throwsA(predicate((final e) => _errorOf(e) == expected)),
          reason: 'attempt $attempt',
        );
      }

      // Even the correct code is no good now — the user has to ask for a new one.
      await expectLater(
        endpoints.auth.verifySignInCode(sessionBuilder, 'mert@kaya.co', real),
        throwsA(
          predicate(
            (final e) => _errorOf(e) == BasketError.tooManySignInAttempts,
          ),
        ),
      );
    });

    test('an expired code is told apart from a wrong one', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, 'selin@kaya.co');
      final code = _sentCode;

      final session = sessionBuilder.build();
      final row = await SignInCode.db.findFirstRow(
        session,
        where: (final t) => t.email.equals('selin@kaya.co'),
      );
      await SignInCode.db.updateRow(
        session,
        row!.copyWith(
          expiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        ),
      );

      await expectLater(
        endpoints.auth.verifySignInCode(sessionBuilder, 'selin@kaya.co', code),
        throwsA(
          predicate((final e) => _errorOf(e) == BasketError.signInCodeExpired),
        ),
      );
    });

    test('a code cannot be redeemed twice', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, 'reuse@kaya.co');
      final code = _sentCode;

      await endpoints.auth.verifySignInCode(
        sessionBuilder,
        'reuse@kaya.co',
        code,
      );

      await expectLater(
        endpoints.auth.verifySignInCode(sessionBuilder, 'reuse@kaya.co', code),
        throwsA(
          predicate((final e) => _errorOf(e) == BasketError.invalidSignInCode),
        ),
      );
    });

    test(
      'asking again inside the cooldown keeps the first code alive',
      () async {
        await endpoints.auth.requestSignInCode(sessionBuilder, 'cool@kaya.co');
        final first = _sentCode;

        SignInEmailSender.lastCodeForTesting = null;
        await endpoints.auth.requestSignInCode(sessionBuilder, 'cool@kaya.co');

        // Nothing new was sent...
        expect(SignInEmailSender.lastCodeForTesting, isNull);
        // ...and the code already in the user's inbox still works.
        final success = await endpoints.auth.verifySignInCode(
          sessionBuilder,
          'cool@kaya.co',
          first,
        );
        expect(success.authUserId, isNotNull);
      },
    );

    test('the address is normalized, so case cannot fork an account', () async {
      await endpoints.auth.requestSignInCode(sessionBuilder, '  Case@Kaya.CO ');
      final success = await endpoints.auth.verifySignInCode(
        sessionBuilder,
        'case@kaya.co',
        _sentCode,
      );
      expect(success.authUserId, isNotNull);
    });

    test('a malformed address is refused before anything is sent', () async {
      await expectLater(
        endpoints.auth.requestSignInCode(sessionBuilder, 'not-an-address'),
        throwsA(
          predicate((final e) => _errorOf(e) == BasketError.invalidSignInCode),
        ),
      );
      expect(SignInEmailSender.lastCodeForTesting, isNull);
    });
  });
}
