// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Open Basket';

  @override
  String get signInHeadline => 'One person shops.\nEveryone adds.';

  @override
  String get signInBlurb =>
      'A basket that\'s open for a few minutes, then closes itself.';

  @override
  String get signInEmailLabel => 'EMAIL';

  @override
  String get signInEmailHint => 'you@example.com';

  @override
  String get signInSendCode => 'Send me a code';

  @override
  String get signInCodeNote => 'Six digits by email. No password to forget.';

  @override
  String get signInTerms => 'By continuing you agree to the terms.';

  @override
  String get signInInvalidEmail => 'That does not look like an email address.';

  @override
  String get codeEntryTitle => 'Check your email';

  @override
  String codeEntrySentTo(String email) {
    return 'We sent a six-digit code to $email.';
  }

  @override
  String get codeEntryContinue => 'Continue';

  @override
  String get codeEntryResendIn => 'Resend in';

  @override
  String get codeEntryResend => 'Send a new code';

  @override
  String get codeEntryResendNote => 'The old code stops working straight away.';

  @override
  String get codeEntryWrongAddress => 'Wrong address?';

  @override
  String get codeEntryChangeEmail => 'Change email';

  @override
  String get codeEntryMismatch => 'That code didn\'t match';

  @override
  String get codeEntryMismatchNote =>
      'Codes expire after 10 minutes. Then we\'ll send a fresh one.';

  @override
  String get codeEntryExpired => 'That code has expired';

  @override
  String get codeEntryExpiredNote =>
      'Codes last ten minutes. We can send you a new one.';

  @override
  String get codeEntryBurned => 'Too many tries';

  @override
  String get codeEntryBurnedNote =>
      'That code is no longer usable. Ask for a new one.';

  @override
  String get countdownCheckoutIn => 'CHECKOUT IN';

  @override
  String get countdownLastCall => 'LAST CALL';

  @override
  String get countdownLocked => 'LOCKED';

  @override
  String get countdownFrozen => 'FROZEN';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSomethingWentWrong => 'Something went wrong';

  @override
  String get commonOffline => 'Can\'t reach the basket';

  @override
  String get commonOfflineNote =>
      'Your items are saved on this phone and will sync the moment you\'re back.';
}
