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
  /// **'Resend in {time}'**
  String codeEntryResendIn(String time);

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

  /// No description provided for @homeBasketOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'A basket is open'**
  String get homeBasketOpenTitle;

  /// No description provided for @homeBasketOpenNote.
  ///
  /// In en, this message translates to:
  /// **'{name} is shopping. Add what you need.'**
  String homeBasketOpenNote(String name);

  /// No description provided for @homeBasketFrozenTitle.
  ///
  /// In en, this message translates to:
  /// **'At checkout'**
  String get homeBasketFrozenTitle;

  /// No description provided for @homeBasketFrozenNote.
  ///
  /// In en, this message translates to:
  /// **'The list is final. {name} is paying.'**
  String homeBasketFrozenNote(String name);

  /// No description provided for @homeBasketSee.
  ///
  /// In en, this message translates to:
  /// **'Open it'**
  String get homeBasketSee;

  /// No description provided for @openSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How long?'**
  String get openSheetTitle;

  /// No description provided for @openSheetBlurb.
  ///
  /// In en, this message translates to:
  /// **'The basket closes itself when the time runs out. Everyone can add until then.'**
  String get openSheetBlurb;

  /// No description provided for @openSheetMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String openSheetMinutes(int count);

  /// No description provided for @openSheetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get openSheetCustom;

  /// No description provided for @openSheetStart.
  ///
  /// In en, this message translates to:
  /// **'Open the basket'**
  String get openSheetStart;

  /// No description provided for @openSheetAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'Someone in your household already has a basket open.'**
  String get openSheetAlreadyOpen;

  /// No description provided for @liveBasketItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items yet} =1{1 item} other{{count} items}}'**
  String liveBasketItems(int count);

  /// No description provided for @liveBasketClosesByItself.
  ///
  /// In en, this message translates to:
  /// **'CLOSES BY ITSELF'**
  String get liveBasketClosesByItself;

  /// No description provided for @liveBasketAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get liveBasketAddHint;

  /// No description provided for @liveBasketNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get liveBasketNoteHint;

  /// No description provided for @liveBasketAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get liveBasketAdd;

  /// No description provided for @liveBasketEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the basket yet.'**
  String get liveBasketEmpty;

  /// No description provided for @liveBasketEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Type what you need. Everyone sees it the moment you add it.'**
  String get liveBasketEmptyNote;

  /// No description provided for @liveBasketExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend once'**
  String get liveBasketExtend;

  /// No description provided for @liveBasketExtendUsed.
  ///
  /// In en, this message translates to:
  /// **'Already extended'**
  String get liveBasketExtendUsed;

  /// No description provided for @liveBasketCheckout.
  ///
  /// In en, this message translates to:
  /// **'At checkout'**
  String get liveBasketCheckout;

  /// No description provided for @liveBasketCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel the run'**
  String get liveBasketCancel;

  /// No description provided for @liveBasketCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this run?'**
  String get liveBasketCancelConfirm;

  /// No description provided for @liveBasketCancelConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing gets priced and nobody owes anybody. The run shows up as cancelled.'**
  String get liveBasketCancelConfirmNote;

  /// No description provided for @liveBasketCancelKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep shopping'**
  String get liveBasketCancelKeep;

  /// No description provided for @liveBasketCancelYes.
  ///
  /// In en, this message translates to:
  /// **'Cancel it'**
  String get liveBasketCancelYes;

  /// No description provided for @liveBasketReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get liveBasketReconnecting;

  /// No description provided for @liveBasketClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'This basket closed'**
  String get liveBasketClosedTitle;

  /// No description provided for @liveBasketBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get liveBasketBack;

  /// No description provided for @liveBasketRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get liveBasketRemove;

  /// No description provided for @countdownListFinal.
  ///
  /// In en, this message translates to:
  /// **'The list is final.'**
  String get countdownListFinal;

  /// No description provided for @itemGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get itemGotIt;

  /// No description provided for @itemNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get itemNotAvailable;

  /// No description provided for @itemGotBy.
  ///
  /// In en, this message translates to:
  /// **'{name} got it'**
  String itemGotBy(String name);

  /// No description provided for @itemMarkBackOnList.
  ///
  /// In en, this message translates to:
  /// **'Put it back on the list'**
  String get itemMarkBackOnList;

  /// No description provided for @itemMarkCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get itemMarkCancel;

  /// No description provided for @liveBasketTickHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an item when it is in your basket.'**
  String get liveBasketTickHint;

  /// No description provided for @liveBasketEnterPrices.
  ///
  /// In en, this message translates to:
  /// **'Enter the prices'**
  String get liveBasketEnterPrices;

  /// No description provided for @liveBasketWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to settle yet'**
  String get liveBasketWaitingTitle;

  /// No description provided for @liveBasketWaitingNote.
  ///
  /// In en, this message translates to:
  /// **'{name} hasn\'t typed the prices in yet. Your share appears here when they do.'**
  String liveBasketWaitingNote(String name);

  /// No description provided for @liveBasketSeeSettlement.
  ///
  /// In en, this message translates to:
  /// **'See who owes what'**
  String get liveBasketSeeSettlement;

  /// No description provided for @checkoutLocked.
  ///
  /// In en, this message translates to:
  /// **'BASKET LOCKED'**
  String get checkoutLocked;

  /// No description provided for @checkoutFrozen.
  ///
  /// In en, this message translates to:
  /// **'FROZEN'**
  String get checkoutFrozen;

  /// No description provided for @checkoutItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String checkoutItems(int count);

  /// No description provided for @checkoutClosedAt.
  ///
  /// In en, this message translates to:
  /// **'closed {time}'**
  String checkoutClosedAt(String time);

  /// No description provided for @checkoutHint.
  ///
  /// In en, this message translates to:
  /// **'Type what each thing cost. Tap anything that wasn\'t there.'**
  String get checkoutHint;

  /// No description provided for @checkoutUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get checkoutUndo;

  /// No description provided for @checkoutItemsAddUp.
  ///
  /// In en, this message translates to:
  /// **'Items add up to'**
  String get checkoutItemsAddUp;

  /// No description provided for @checkoutReceiptTotal.
  ///
  /// In en, this message translates to:
  /// **'Receipt total'**
  String get checkoutReceiptTotal;

  /// No description provided for @checkoutGapMore.
  ///
  /// In en, this message translates to:
  /// **'Receipt is {gap} more than the items.{count, plural, =1{} other{ Split evenly across all {count} — {each} each.}}'**
  String checkoutGapMore(String gap, int count, String each);

  /// No description provided for @checkoutGapLess.
  ///
  /// In en, this message translates to:
  /// **'Receipt is {gap} less than the items.{count, plural, =1{} other{ Split evenly across all {count} — {each} off each.}}'**
  String checkoutGapLess(String gap, int count, String each);

  /// No description provided for @checkoutSettle.
  ///
  /// In en, this message translates to:
  /// **'Work out who owes what'**
  String get checkoutSettle;

  /// No description provided for @checkoutUnfinished.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item still needs a price} other{{count} items still need a price}}'**
  String checkoutUnfinished(int count);

  /// No description provided for @checkoutNotAPrice.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a price.'**
  String get checkoutNotAPrice;

  /// No description provided for @settlementBadge.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get settlementBadge;

  /// No description provided for @settlementTitle.
  ///
  /// In en, this message translates to:
  /// **'Settled up'**
  String get settlementTitle;

  /// No description provided for @settlementSummary.
  ///
  /// In en, this message translates to:
  /// **'{items}{unavailable, plural, =0{} other{ · {unavailable} unavailable}} · receipt {total}'**
  String settlementSummary(String items, int unavailable, String total);

  /// No description provided for @settlementWhoOwes.
  ///
  /// In en, this message translates to:
  /// **'WHO OWES WHOM'**
  String get settlementWhoOwes;

  /// No description provided for @settlementOwes.
  ///
  /// In en, this message translates to:
  /// **'{from} owes {to}'**
  String settlementOwes(String from, String to);

  /// No description provided for @settlementBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{items} items + {gap} gap'**
  String settlementBreakdown(String items, String gap);

  /// No description provided for @settlementBreakdownCredit.
  ///
  /// In en, this message translates to:
  /// **'{items} items − {gap} off'**
  String settlementBreakdownCredit(String items, String gap);

  /// No description provided for @settlementNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody owes anybody'**
  String get settlementNobody;

  /// No description provided for @settlementNobodyNote.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'s share came to nothing, or to what the shopper bought for themselves.'**
  String get settlementNobodyNote;

  /// No description provided for @settlementGapTitle.
  ///
  /// In en, this message translates to:
  /// **'THE RECEIPT GAP'**
  String get settlementGapTitle;

  /// No description provided for @settlementItemsPriced.
  ///
  /// In en, this message translates to:
  /// **'Items priced'**
  String get settlementItemsPriced;

  /// No description provided for @settlementReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get settlementReceipt;

  /// No description provided for @settlementGapAcross.
  ///
  /// In en, this message translates to:
  /// **'{gap} across {count, plural, =1{1 member} other{{count} members}}'**
  String settlementGapAcross(String gap, int count);

  /// No description provided for @settlementCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy the summary'**
  String get settlementCopy;

  /// No description provided for @settlementCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied. Paste it wherever the house talks.'**
  String get settlementCopied;

  /// No description provided for @settlementShareLine.
  ///
  /// In en, this message translates to:
  /// **'{from} owes {to} {amount}'**
  String settlementShareLine(String from, String to, String amount);

  /// No description provided for @settlementDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get settlementDone;

  /// No description provided for @checkoutSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone new'**
  String get checkoutSomeone;

  /// No description provided for @homeLastRunTitle.
  ///
  /// In en, this message translates to:
  /// **'LAST RUN · SETTLED'**
  String get homeLastRunTitle;

  /// No description provided for @homeLastRunYouOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe {name} {amount}'**
  String homeLastRunYouOwe(String name, String amount);

  /// No description provided for @homeLastRunOwesYou.
  ///
  /// In en, this message translates to:
  /// **'{name} owes you {amount}'**
  String homeLastRunOwesYou(String name, String amount);

  /// No description provided for @homeLastRunManyOweYou.
  ///
  /// In en, this message translates to:
  /// **'{count} people owe you {amount} in total'**
  String homeLastRunManyOweYou(int count, String amount);

  /// No description provided for @homeLastRunClear.
  ///
  /// In en, this message translates to:
  /// **'You don\'t owe anything on this one.'**
  String get homeLastRunClear;

  /// No description provided for @liveBasketReconnectingNote.
  ///
  /// In en, this message translates to:
  /// **'The countdown is right — the server keeps the clock, not this phone.'**
  String get liveBasketReconnectingNote;

  /// No description provided for @liveBasketLastSynced.
  ///
  /// In en, this message translates to:
  /// **'last synced {time}'**
  String liveBasketLastSynced(String time);

  /// No description provided for @liveBasketQueuedRow.
  ///
  /// In en, this message translates to:
  /// **'Queued on this phone · sends when you\'re back'**
  String get liveBasketQueuedRow;

  /// No description provided for @liveBasketQueuedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} queued'**
  String liveBasketQueuedCount(int count);

  /// No description provided for @liveBasketOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Offline — anything you add is kept here and sent the moment you\'re back.'**
  String get liveBasketOfflineHint;

  /// No description provided for @liveBasketBackOnline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Back online · 1 item sent} other{Back online · {count} items sent}}'**
  String liveBasketBackOnline(int count);

  /// No description provided for @liveBasketBackOnlineNote.
  ///
  /// In en, this message translates to:
  /// **'Now on everyone\'s list: {names}.'**
  String liveBasketBackOnlineNote(String names);

  /// No description provided for @liveBasketDropped.
  ///
  /// In en, this message translates to:
  /// **'The basket closed before these could be sent: {names}.'**
  String liveBasketDropped(String names);

  /// No description provided for @liveBasketJoinedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} opened one at {time}'**
  String liveBasketJoinedTitle(String name, String time);

  /// No description provided for @liveBasketJoinedNote.
  ///
  /// In en, this message translates to:
  /// **'One basket at a time in a household — so here\'s that run instead.'**
  String get liveBasketJoinedNote;

  /// No description provided for @countdownClosedOnTime.
  ///
  /// In en, this message translates to:
  /// **'CLOSED ON TIME'**
  String get countdownClosedOnTime;

  /// No description provided for @countdownSettled.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get countdownSettled;

  /// No description provided for @countdownCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get countdownCancelled;

  /// No description provided for @countdownClosedItself.
  ///
  /// In en, this message translates to:
  /// **'The basket closed itself at {time}'**
  String countdownClosedItself(String time);

  /// No description provided for @countdownClosedItselfNote.
  ///
  /// In en, this message translates to:
  /// **'It ran the full {minutes, plural, =1{minute} other{{minutes} minutes}} and shut on the server.'**
  String countdownClosedItselfNote(int minutes);

  /// No description provided for @countdownClosedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} closed it at {time}'**
  String countdownClosedBy(String name, String time);

  /// No description provided for @countdownCancelledBy.
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled this run'**
  String countdownCancelledBy(String name);

  /// No description provided for @countdownCancelledNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing was priced and nobody owes anybody.'**
  String get countdownCancelledNote;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storesTitle;

  /// No description provided for @storesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the house can pick it when they open a basket.'**
  String get storesBlurb;

  /// No description provided for @storesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stores yet. Add the ones the house actually goes to.'**
  String get storesEmpty;

  /// No description provided for @storesAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a store'**
  String get storesAddTitle;

  /// No description provided for @storesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get storesNameLabel;

  /// No description provided for @storesNameHint.
  ///
  /// In en, this message translates to:
  /// **'Migros Bağdat Cd.'**
  String get storesNameHint;

  /// No description provided for @storesLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get storesLocationLabel;

  /// No description provided for @storesUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get storesUseLocation;

  /// No description provided for @storesLocationNote.
  ///
  /// In en, this message translates to:
  /// **'Pinned once, now. We use it only to estimate how long a run takes.'**
  String get storesLocationNote;

  /// No description provided for @storesPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned · {lat}, {lng}'**
  String storesPinned(String lat, String lng);

  /// No description provided for @storesNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location · baskets default to 10 minutes'**
  String get storesNoLocation;

  /// No description provided for @storesHasLocation.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get storesHasLocation;

  /// No description provided for @storesLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your location. You can save it without one.'**
  String get storesLocationFailed;

  /// No description provided for @storesSave.
  ///
  /// In en, this message translates to:
  /// **'Save store'**
  String get storesSave;

  /// No description provided for @storesSkipNote.
  ///
  /// In en, this message translates to:
  /// **'Skip the location and we\'ll default every basket to 10 minutes.'**
  String get storesSkipNote;

  /// No description provided for @storesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get storesRemove;

  /// No description provided for @storesRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String storesRemoveConfirm(String name);

  /// No description provided for @storesRemoveNote.
  ///
  /// In en, this message translates to:
  /// **'Past runs at {name} keep their history.'**
  String storesRemoveNote(String name);

  /// No description provided for @storesInvalid.
  ///
  /// In en, this message translates to:
  /// **'Give the store a name.'**
  String get storesInvalid;

  /// No description provided for @openSheetStore.
  ///
  /// In en, this message translates to:
  /// **'STORE'**
  String get openSheetStore;

  /// No description provided for @openSheetHowLong.
  ///
  /// In en, this message translates to:
  /// **'HOW LONG'**
  String get openSheetHowLong;

  /// No description provided for @openSheetAddStore.
  ///
  /// In en, this message translates to:
  /// **'Add a store'**
  String get openSheetAddStore;

  /// No description provided for @openSheetEstimating.
  ///
  /// In en, this message translates to:
  /// **'Working out how far {store} is…'**
  String openSheetEstimating(String store);

  /// No description provided for @openSheetEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated {minutes} min'**
  String openSheetEstimated(int minutes);

  /// No description provided for @openSheetEstimatedNote.
  ///
  /// In en, this message translates to:
  /// **'From your distance to {store}. Pick your own if you know better.'**
  String openSheetEstimatedNote(String store);

  /// No description provided for @openSheetNoEstimate.
  ///
  /// In en, this message translates to:
  /// **'No estimate for {store}, so pick a time.'**
  String openSheetNoEstimate(String store);

  /// No description provided for @openSheetOpenFor.
  ///
  /// In en, this message translates to:
  /// **'Open for {minutes} minutes'**
  String openSheetOpenFor(int minutes);

  /// No description provided for @homeStoresLabel.
  ///
  /// In en, this message translates to:
  /// **'STORES'**
  String get homeStoresLabel;

  /// No description provided for @homeStoresNone.
  ///
  /// In en, this message translates to:
  /// **'None yet · add one'**
  String get homeStoresNone;

  /// No description provided for @countdownAtStore.
  ///
  /// In en, this message translates to:
  /// **'AT {store}'**
  String countdownAtStore(String store);

  /// No description provided for @homeBasketOpenAt.
  ///
  /// In en, this message translates to:
  /// **'{name} is shopping at {store}. Add what you need.'**
  String homeBasketOpenAt(String name, String store);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 run} other{{count} runs}} · {total} through the house'**
  String historySummary(int count, String total);

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No finished runs yet. They show up here once a basket is settled or cancelled.'**
  String get historyEmpty;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String historyToday(String time);

  /// A weekday or a short date, then a time: "Sunday, 11:04", "3 Sep, 18:40".
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String historyDayAndTime(String day, String time);

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String historyYesterday(String time);

  /// No description provided for @historyWhen.
  ///
  /// In en, this message translates to:
  /// **'{when} · {name} shopped'**
  String historyWhen(String when, String name);

  /// No description provided for @historyRan.
  ///
  /// In en, this message translates to:
  /// **'ran {minutes} min'**
  String historyRan(int minutes);

  /// No description provided for @historyNoStore.
  ///
  /// In en, this message translates to:
  /// **'A run'**
  String get historyNoStore;

  /// No description provided for @historySettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get historySettled;

  /// No description provided for @historyCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get historyCancelled;

  /// No description provided for @historyStatItems.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get historyStatItems;

  /// No description provided for @historyStatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get historyStatUnavailable;

  /// No description provided for @historyStatReceipt.
  ///
  /// In en, this message translates to:
  /// **'receipt'**
  String get historyStatReceipt;

  /// No description provided for @historyHowSettled.
  ///
  /// In en, this message translates to:
  /// **'HOW IT SETTLED'**
  String get historyHowSettled;

  /// No description provided for @historyLine.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String historyLine(String from, String to);

  /// No description provided for @historyGapNote.
  ///
  /// In en, this message translates to:
  /// **'Includes {each} each of the {gap} receipt gap.'**
  String historyGapNote(String each, String gap);

  /// No description provided for @historyNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody owes anybody'**
  String get historyNobody;

  /// No description provided for @historyCancelledNote.
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled before the till, so nothing was priced and no settlement was made.'**
  String historyCancelledNote(String name);

  /// No description provided for @historyWhatWasInIt.
  ///
  /// In en, this message translates to:
  /// **'WHAT WAS IN IT'**
  String get historyWhatWasInIt;

  /// No description provided for @historyAskedDropped.
  ///
  /// In en, this message translates to:
  /// **'{name} asked · dropped'**
  String historyAskedDropped(String name);

  /// No description provided for @historyHowItRan.
  ///
  /// In en, this message translates to:
  /// **'HOW IT RAN'**
  String get historyHowItRan;

  /// No description provided for @historyOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get historyOpened;

  /// No description provided for @historyOpenedFor.
  ///
  /// In en, this message translates to:
  /// **'{time} · for {minutes} min'**
  String historyOpenedFor(String time, int minutes);

  /// No description provided for @historyClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get historyClosed;

  /// No description provided for @historyPriced.
  ///
  /// In en, this message translates to:
  /// **'Priced'**
  String get historyPriced;

  /// No description provided for @historyNothing.
  ///
  /// In en, this message translates to:
  /// **'nothing'**
  String get historyNothing;

  /// No description provided for @homeHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get homeHistoryLabel;

  /// No description provided for @homeHistoryNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing finished yet'**
  String get homeHistoryNone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHousehold.
  ///
  /// In en, this message translates to:
  /// **'HOUSEHOLD'**
  String get settingsHousehold;

  /// No description provided for @settingsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Every price and settlement uses it.'**
  String get settingsCurrencyNote;

  /// No description provided for @settingsStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get settingsStores;

  /// No description provided for @settingsMembers.
  ///
  /// In en, this message translates to:
  /// **'Members and code'**
  String get settingsMembers;

  /// No description provided for @settingsMembersValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}} · {code}'**
  String settingsMembersValue(int count, String code);

  /// No description provided for @settingsOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change this.'**
  String get settingsOwnerOnly;

  /// No description provided for @settingsRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename the household'**
  String get settingsRenameTitle;

  /// No description provided for @settingsRenameSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsRenameSave;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}'**
  String settingsLeave(String name);

  /// No description provided for @settingsLeaveNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll lose access to its history.'**
  String get settingsLeaveNote;

  /// No description provided for @settingsLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String settingsLeaveConfirm(String name);

  /// No description provided for @settingsLeaveConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'The household keeps every run you were part of. You can come back with its code.'**
  String get settingsLeaveConfirmNote;

  /// No description provided for @settingsLeaveYes.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get settingsLeaveYes;

  /// No description provided for @settingsShopperCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'Finish or cancel your basket before you leave.'**
  String get settingsShopperCannotLeave;

  /// No description provided for @currencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyTitle;

  /// No description provided for @currencyBlurb.
  ///
  /// In en, this message translates to:
  /// **'One for the whole household. Every price, settlement and shared summary uses it.'**
  String get currencyBlurb;

  /// No description provided for @currencyInUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get currencyInUse;

  /// No description provided for @currencySample.
  ///
  /// In en, this message translates to:
  /// **'{code} · {sample}'**
  String currencySample(String code, String sample);

  /// No description provided for @currencyNoCents.
  ///
  /// In en, this message translates to:
  /// **'{code} · {sample} · no cents'**
  String currencyNoCents(String code, String sample);

  /// No description provided for @currencyNote.
  ///
  /// In en, this message translates to:
  /// **'Changing this doesn\'t convert anything. Past runs keep the currency they were settled in.'**
  String get currencyNote;

  /// No description provided for @currencySave.
  ///
  /// In en, this message translates to:
  /// **'Save currency'**
  String get currencySave;

  /// No description provided for @currencyNameTRY.
  ///
  /// In en, this message translates to:
  /// **'Turkish lira'**
  String get currencyNameTRY;

  /// No description provided for @currencyNameEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyNameEUR;

  /// No description provided for @currencyNameGBP.
  ///
  /// In en, this message translates to:
  /// **'Pound sterling'**
  String get currencyNameGBP;

  /// No description provided for @currencyNameUSD.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyNameUSD;

  /// No description provided for @currencyNameJPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese yen'**
  String get currencyNameJPY;

  /// No description provided for @currencyNameCHF.
  ///
  /// In en, this message translates to:
  /// **'Swiss franc'**
  String get currencyNameCHF;

  /// No description provided for @liveBasketUsually.
  ///
  /// In en, this message translates to:
  /// **'YOU USUALLY ASK FOR'**
  String get liveBasketUsually;

  /// No description provided for @liveBasketTooMany.
  ///
  /// In en, this message translates to:
  /// **'That\'s a lot at once. Give it a moment.'**
  String get liveBasketTooMany;

  /// No description provided for @errorNotAMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in this household any more.'**
  String get errorNotAMember;

  /// No description provided for @errorNotTheShopper.
  ///
  /// In en, this message translates to:
  /// **'Only the shopper can do that.'**
  String get errorNotTheShopper;

  /// No description provided for @errorBasketNotFound.
  ///
  /// In en, this message translates to:
  /// **'That basket is gone.'**
  String get errorBasketNotFound;

  /// No description provided for @errorInvalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Pick between 1 and 120 minutes.'**
  String get errorInvalidDuration;

  /// No description provided for @errorItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'That item was just removed.'**
  String get errorItemNotFound;

  /// No description provided for @errorNotYourItem.
  ///
  /// In en, this message translates to:
  /// **'Only the person who asked for it can change it.'**
  String get errorNotYourItem;

  /// No description provided for @errorInvalidItem.
  ///
  /// In en, this message translates to:
  /// **'Give the item a name, and a quantity from 1 to 99.'**
  String get errorInvalidItem;

  /// No description provided for @errorStoreNotFound.
  ///
  /// In en, this message translates to:
  /// **'That store was just removed.'**
  String get errorStoreNotFound;

  /// No description provided for @errorInvalidStore.
  ///
  /// In en, this message translates to:
  /// **'Store names are 1 to 60 characters.'**
  String get errorInvalidStore;

  /// No description provided for @errorInvalidHouseholdName.
  ///
  /// In en, this message translates to:
  /// **'Household names are 1 to 60 characters.'**
  String get errorInvalidHouseholdName;

  /// No description provided for @errorInvalidCurrency.
  ///
  /// In en, this message translates to:
  /// **'That currency isn\'t one we support yet.'**
  String get errorInvalidCurrency;

  /// No description provided for @errorBasketNotFrozen.
  ///
  /// In en, this message translates to:
  /// **'Prices go in once the basket is at checkout.'**
  String get errorBasketNotFrozen;

  /// No description provided for @errorAlreadySettled.
  ///
  /// In en, this message translates to:
  /// **'This basket is already settled.'**
  String get errorAlreadySettled;

  /// No description provided for @errorNotFullyPriced.
  ///
  /// In en, this message translates to:
  /// **'Mark every item first: got it, with a price, or not available.'**
  String get errorNotFullyPriced;

  /// No description provided for @errorExtensionUsed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already added five minutes to this basket.'**
  String get errorExtensionUsed;

  /// No description provided for @checkoutEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody added anything this time.'**
  String get checkoutEmpty;

  /// No description provided for @checkoutEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Settle to close the run. If you enter a receipt total, it\'s split evenly across the household.'**
  String get checkoutEmptyNote;

  /// No description provided for @liveBasketNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get liveBasketNoItems;

  /// No description provided for @liveBasketEmptyClosed.
  ///
  /// In en, this message translates to:
  /// **'Nobody added anything.'**
  String get liveBasketEmptyClosed;

  /// No description provided for @settingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsYourName;

  /// No description provided for @settingsYourNameNote.
  ///
  /// In en, this message translates to:
  /// **'What the house sees on your items and in who owes whom.'**
  String get settingsYourNameNote;

  /// No description provided for @settingsYourNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should the house call you?'**
  String get settingsYourNameTitle;

  /// No description provided for @errorInvalidMemberName.
  ///
  /// In en, this message translates to:
  /// **'Names are 1 to 40 characters.'**
  String get errorInvalidMemberName;

  /// No description provided for @settingsYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get settingsYou;

  /// No description provided for @errorInvalidDeviceToken.
  ///
  /// In en, this message translates to:
  /// **'This phone couldn\'t sign up for notifications.'**
  String get errorInvalidDeviceToken;

  /// No description provided for @checkoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Settle {amount}?'**
  String checkoutConfirmTitle(String amount);

  /// No description provided for @checkoutConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'Who owes what is worked out from these prices and can\'t be changed afterwards.'**
  String get checkoutConfirmNote;

  /// No description provided for @checkoutConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get checkoutConfirmYes;

  /// No description provided for @membersLabel.
  ///
  /// In en, this message translates to:
  /// **'HOUSEHOLD'**
  String get membersLabel;

  /// No description provided for @membersCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'HOUSEHOLD CODE'**
  String get membersCodeLabel;

  /// No description provided for @membersPermanent.
  ///
  /// In en, this message translates to:
  /// **'PERMANENT'**
  String get membersPermanent;

  /// No description provided for @membersShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get membersShare;

  /// No description provided for @membersRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get membersRotate;

  /// No description provided for @membersCodeNote.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this code can join.'**
  String get membersCodeNote;

  /// No description provided for @membersRotateOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change the code.'**
  String get membersRotateOwnerOnly;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 MEMBER} other{{count} MEMBERS}}'**
  String membersCount(int count);

  /// No description provided for @membersYou.
  ///
  /// In en, this message translates to:
  /// **'· you'**
  String get membersYou;

  /// No description provided for @membersJoined.
  ///
  /// In en, this message translates to:
  /// **'{when, select, thisWeek{Joined this week} lastWeek{Joined last week} other{Joined {month}}}'**
  String membersJoined(String when, String month);

  /// No description provided for @membersOwnerJoined.
  ///
  /// In en, this message translates to:
  /// **'{when, select, thisWeek{Owner · joined this week} lastWeek{Owner · joined last week} other{Owner · joined {month}}}'**
  String membersOwnerJoined(String when, String month);

  /// No description provided for @membersShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Join {household} on Open Basket'**
  String membersShareSubject(String household);

  /// No description provided for @membersShareText.
  ///
  /// In en, this message translates to:
  /// **'Join {household} on Open Basket. The code is {code}. Get the app at https://open-basket.serverpod.space'**
  String membersShareText(String household, String code);

  /// No description provided for @rotateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate the household code?'**
  String get rotateTitle;

  /// No description provided for @rotateBlurb.
  ///
  /// In en, this message translates to:
  /// **'Everyone already in stays in. Only new joins are affected.'**
  String get rotateBlurb;

  /// No description provided for @rotateOld.
  ///
  /// In en, this message translates to:
  /// **'OLD'**
  String get rotateOld;

  /// No description provided for @rotateOldNote.
  ///
  /// In en, this message translates to:
  /// **'stops working now'**
  String get rotateOldNote;

  /// No description provided for @rotateNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get rotateNew;

  /// No description provided for @rotateNewNote.
  ///
  /// In en, this message translates to:
  /// **'picked when you rotate'**
  String get rotateNewNote;

  /// No description provided for @rotateWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone holding the old code can no longer join, including any message you already sent.'**
  String get rotateWarning;

  /// No description provided for @rotateKeepPlace.
  ///
  /// In en, this message translates to:
  /// **'{names} keep their place. Nothing in history changes.'**
  String rotateKeepPlace(String names);

  /// No description provided for @rotateKeepPlaceOne.
  ///
  /// In en, this message translates to:
  /// **'You keep your place. Nothing in history changes.'**
  String get rotateKeepPlaceOne;

  /// No description provided for @namesAnd.
  ///
  /// In en, this message translates to:
  /// **'{first} and {last}'**
  String namesAnd(String first, String last);

  /// No description provided for @rotateOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Owner only. There\'s no expiry: rotate as often as you like.'**
  String get rotateOwnerOnly;

  /// No description provided for @rotateAction.
  ///
  /// In en, this message translates to:
  /// **'Rotate and share the new code'**
  String get rotateAction;

  /// No description provided for @rotateKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep {code}'**
  String rotateKeep(String code);

  /// No description provided for @rotateNewDone.
  ///
  /// In en, this message translates to:
  /// **'yours from now on'**
  String get rotateNewDone;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifyOpened.
  ///
  /// In en, this message translates to:
  /// **'A basket opens'**
  String get settingsNotifyOpened;

  /// No description provided for @settingsNotifyClosingSoon.
  ///
  /// In en, this message translates to:
  /// **'Two minutes left'**
  String get settingsNotifyClosingSoon;

  /// No description provided for @settingsNotifySettled.
  ///
  /// In en, this message translates to:
  /// **'Settlement is ready'**
  String get settingsNotifySettled;

  /// No description provided for @settingsNotificationsNote.
  ///
  /// In en, this message translates to:
  /// **'Kept on the server for when this phone can receive notifications; it can\'t yet.'**
  String get settingsNotificationsNote;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'Open Basket {version}'**
  String settingsFooter(String version);

  /// No description provided for @settingsFooterEmail.
  ///
  /// In en, this message translates to:
  /// **'Open Basket {version} · {email}'**
  String settingsFooterEmail(String version, String email);

  /// No description provided for @errorHouseholdCodeRotated.
  ///
  /// In en, this message translates to:
  /// **'That code has been replaced'**
  String get errorHouseholdCodeRotated;

  /// No description provided for @errorTooManyJoinAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a few minutes and try again.'**
  String get errorTooManyJoinAttempts;

  /// No description provided for @joinTriesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tries left for now: wait a few minutes.} =1{One try left.} other{{count} tries left.}}'**
  String joinTriesLeft(int count);

  /// No description provided for @joinUnknownNote.
  ///
  /// In en, this message translates to:
  /// **'Check it against the message you were sent.'**
  String get joinUnknownNote;

  /// No description provided for @joinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get joinTryAgain;

  /// No description provided for @joinPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste what you were sent'**
  String get joinPaste;

  /// No description provided for @joinRotatedNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing wrong with what you typed: the household changed its code after the message you were sent.'**
  String get joinRotatedNote;

  /// No description provided for @joinAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for the new six characters'**
  String get joinAskTitle;

  /// No description provided for @joinAskNote.
  ///
  /// In en, this message translates to:
  /// **'Whoever invited you can see the current code on their members screen. Codes don\'t expire on their own; this one was changed on purpose.'**
  String get joinAskNote;

  /// No description provided for @joinAskAction.
  ///
  /// In en, this message translates to:
  /// **'Send them a request'**
  String get joinAskAction;

  /// No description provided for @joinAskShareText.
  ///
  /// In en, this message translates to:
  /// **'Could you send me the new code for our household on Open Basket?'**
  String get joinAskShareText;

  /// No description provided for @joinEnterDifferent.
  ///
  /// In en, this message translates to:
  /// **'Enter a different code'**
  String get joinEnterDifferent;

  /// No description provided for @joinNeverIn.
  ///
  /// In en, this message translates to:
  /// **'Nobody has removed you from anything: you were never in yet.'**
  String get joinNeverIn;

  /// No description provided for @joinNoCode.
  ///
  /// In en, this message translates to:
  /// **'No code yet?'**
  String get joinNoCode;

  /// No description provided for @joinStartOwn.
  ///
  /// In en, this message translates to:
  /// **'Start your own household'**
  String get joinStartOwn;
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
