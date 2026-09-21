import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Open Basket'**
  String get appName;

  /// No description provided for @signInHeadline.
  ///
  /// In en, this message translates to:
  /// **'One person shops.\nEveryone adds.'**
  String get signInHeadline;

  /// No description provided for @signInBlurb.
  ///
  /// In en, this message translates to:
  /// **'A basket that\'s open for a few minutes, then closes itself.'**
  String get signInBlurb;

  /// No description provided for @signInEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get signInEmailLabel;

  /// No description provided for @signInEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get signInEmailHint;

  /// No description provided for @signInSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send me a code'**
  String get signInSendCode;

  /// No description provided for @signInCodeNote.
  ///
  /// In en, this message translates to:
  /// **'Six digits by email. No password to forget.'**
  String get signInCodeNote;

  /// No description provided for @signInTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the terms.'**
  String get signInTerms;

  /// No description provided for @signInInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That does not look like an email address.'**
  String get signInInvalidEmail;

  /// No description provided for @codeEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get codeEntryTitle;

  /// No description provided for @codeEntrySentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a six-digit code to {email}.'**
  String codeEntrySentTo(String email);

  /// No description provided for @codeEntryContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get codeEntryContinue;

  /// No description provided for @codeEntryResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get codeEntryResendIn;

  /// No description provided for @codeEntryResend.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get codeEntryResend;

  /// No description provided for @codeEntryResendNote.
  ///
  /// In en, this message translates to:
  /// **'The old code stops working straight away.'**
  String get codeEntryResendNote;

  /// No description provided for @codeEntryWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address?'**
  String get codeEntryWrongAddress;

  /// No description provided for @codeEntryChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get codeEntryChangeEmail;

  /// No description provided for @codeEntryMismatch.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t match'**
  String get codeEntryMismatch;

  /// No description provided for @codeEntryMismatchNote.
  ///
  /// In en, this message translates to:
  /// **'Codes expire after 10 minutes. Then we\'ll send a fresh one.'**
  String get codeEntryMismatchNote;

  /// No description provided for @codeEntryExpired.
  ///
  /// In en, this message translates to:
  /// **'That code has expired'**
  String get codeEntryExpired;

  /// No description provided for @codeEntryExpiredNote.
  ///
  /// In en, this message translates to:
  /// **'Codes last ten minutes. We can send you a new one.'**
  String get codeEntryExpiredNote;

  /// No description provided for @codeEntryBurned.
  ///
  /// In en, this message translates to:
  /// **'Too many tries'**
  String get codeEntryBurned;

  /// No description provided for @codeEntryBurnedNote.
  ///
  /// In en, this message translates to:
  /// **'That code is no longer usable. Ask for a new one.'**
  String get codeEntryBurnedNote;

  /// No description provided for @countdownCheckoutIn.
  ///
  /// In en, this message translates to:
  /// **'CHECKOUT IN'**
  String get countdownCheckoutIn;

  /// No description provided for @countdownLastCall.
  ///
  /// In en, this message translates to:
  /// **'LAST CALL'**
  String get countdownLastCall;

  /// No description provided for @countdownLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get countdownLocked;

  /// No description provided for @countdownFrozen.
  ///
  /// In en, this message translates to:
  /// **'FROZEN'**
  String get countdownFrozen;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the basket'**
  String get commonOffline;

  /// No description provided for @commonOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'Your items are saved on this phone and will sync the moment you\'re back.'**
  String get commonOfflineNote;

  /// No description provided for @householdChoiceHeadline.
  ///
  /// In en, this message translates to:
  /// **'Who are you\nshopping with?'**
  String get householdChoiceHeadline;

  /// No description provided for @householdChoiceBlurb.
  ///
  /// In en, this message translates to:
  /// **'Start a household, or join one with the six characters someone already in it can read out.'**
  String get householdChoiceBlurb;

  /// No description provided for @householdChoiceCreate.
  ///
  /// In en, this message translates to:
  /// **'Start a household'**
  String get householdChoiceCreate;

  /// No description provided for @householdChoiceJoin.
  ///
  /// In en, this message translates to:
  /// **'I have a code'**
  String get householdChoiceJoin;

  /// No description provided for @createHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your household'**
  String get createHouseholdTitle;

  /// No description provided for @createHouseholdBlurb.
  ///
  /// In en, this message translates to:
  /// **'Everyone in it will see this name. You can change it later.'**
  String get createHouseholdBlurb;

  /// No description provided for @createHouseholdLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get createHouseholdLabel;

  /// No description provided for @createHouseholdHint.
  ///
  /// In en, this message translates to:
  /// **'Kaya household'**
  String get createHouseholdHint;

  /// No description provided for @createHouseholdAction.
  ///
  /// In en, this message translates to:
  /// **'Create it'**
  String get createHouseholdAction;

  /// No description provided for @createHouseholdEmpty.
  ///
  /// In en, this message translates to:
  /// **'Give it a name first.'**
  String get createHouseholdEmpty;

  /// No description provided for @joinHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get joinHouseholdTitle;

  /// No description provided for @joinHouseholdBlurb.
  ///
  /// In en, this message translates to:
  /// **'Six characters from someone already in the household. Case does not matter.'**
  String get joinHouseholdBlurb;

  /// No description provided for @joinHouseholdLabel.
  ///
  /// In en, this message translates to:
  /// **'CODE'**
  String get joinHouseholdLabel;

  /// No description provided for @joinHouseholdHint.
  ///
  /// In en, this message translates to:
  /// **'K7Q2M4'**
  String get joinHouseholdHint;

  /// No description provided for @joinHouseholdAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinHouseholdAction;

  /// No description provided for @joinHouseholdUnknown.
  ///
  /// In en, this message translates to:
  /// **'No household with that code.'**
  String get joinHouseholdUnknown;

  /// No description provided for @joinHouseholdAlreadyIn.
  ///
  /// In en, this message translates to:
  /// **'You are already in a household.'**
  String get joinHouseholdAlreadyIn;

  /// No description provided for @homeMembersOne.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String homeMembersOne(int count);

  /// No description provided for @homeCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'HOUSEHOLD CODE'**
  String get homeCodeLabel;

  /// No description provided for @homeCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get homeCodeCopied;

  /// No description provided for @homeCodeNote.
  ///
  /// In en, this message translates to:
  /// **'Anyone with these six characters can join.'**
  String get homeCodeNote;

  /// No description provided for @homeOpenBasket.
  ///
  /// In en, this message translates to:
  /// **'Open a basket'**
  String get homeOpenBasket;

  /// No description provided for @homeBasketRunning.
  ///
  /// In en, this message translates to:
  /// **'A basket is already open'**
  String get homeBasketRunning;

  /// No description provided for @homeBasketRunningNote.
  ///
  /// In en, this message translates to:
  /// **'{name} is shopping. Tap to add what you need.'**
  String homeBasketRunningNote(String name);

  /// No description provided for @homeNoBasket.
  ///
  /// In en, this message translates to:
  /// **'No basket is open.'**
  String get homeNoBasket;

  /// No description provided for @homeNoBasketNote.
  ///
  /// In en, this message translates to:
  /// **'Open one when you are heading out, and the house has until it closes to add things.'**
  String get homeNoBasketNote;

  /// No description provided for @homeSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSignOut;

  /// No description provided for @homeMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'IN THIS HOUSEHOLD'**
  String get homeMembersTitle;

  /// No description provided for @homeOwnerTag.
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get homeOwnerTag;

  /// No description provided for @homeYouTag.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get homeYouTag;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
