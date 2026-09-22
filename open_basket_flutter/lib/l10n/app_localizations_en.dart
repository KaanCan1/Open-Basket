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

  @override
  String get householdChoiceHeadline => 'Who are you\nshopping with?';

  @override
  String get householdChoiceBlurb =>
      'Start a household, or join one with the six characters someone already in it can read out.';

  @override
  String get householdChoiceCreate => 'Start a household';

  @override
  String get householdChoiceJoin => 'I have a code';

  @override
  String get createHouseholdTitle => 'Name your household';

  @override
  String get createHouseholdBlurb =>
      'Everyone in it will see this name. You can change it later.';

  @override
  String get createHouseholdLabel => 'NAME';

  @override
  String get createHouseholdHint => 'Kaya household';

  @override
  String get createHouseholdAction => 'Create it';

  @override
  String get createHouseholdEmpty => 'Give it a name first.';

  @override
  String get joinHouseholdTitle => 'Enter the code';

  @override
  String get joinHouseholdBlurb =>
      'Six characters from someone already in the household. Case does not matter.';

  @override
  String get joinHouseholdLabel => 'CODE';

  @override
  String get joinHouseholdHint => 'K7Q2M4';

  @override
  String get joinHouseholdAction => 'Join';

  @override
  String get joinHouseholdUnknown => 'No household with that code.';

  @override
  String get joinHouseholdAlreadyIn => 'You are already in a household.';

  @override
  String homeMembersOne(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get homeCodeLabel => 'HOUSEHOLD CODE';

  @override
  String get homeCodeCopied => 'Code copied';

  @override
  String get homeCodeNote => 'Anyone with these six characters can join.';

  @override
  String get homeOpenBasket => 'Open a basket';

  @override
  String get homeBasketRunning => 'A basket is already open';

  @override
  String homeBasketRunningNote(String name) {
    return '$name is shopping. Tap to add what you need.';
  }

  @override
  String get homeNoBasket => 'No basket is open.';

  @override
  String get homeNoBasketNote =>
      'Open one when you are heading out, and the house has until it closes to add things.';

  @override
  String get homeSignOut => 'Sign out';

  @override
  String get homeMembersTitle => 'IN THIS HOUSEHOLD';

  @override
  String get homeOwnerTag => 'OWNER';

  @override
  String get homeYouTag => 'YOU';

  @override
  String get homeBasketOpenTitle => 'A basket is open';

  @override
  String homeBasketOpenNote(String name) {
    return '$name is shopping. Add what you need.';
  }

  @override
  String get homeBasketFrozenTitle => 'At checkout';

  @override
  String homeBasketFrozenNote(String name) {
    return 'The list is final. $name is paying.';
  }

  @override
  String get homeBasketSee => 'Open it';

  @override
  String get openSheetTitle => 'How long?';

  @override
  String get openSheetBlurb =>
      'The basket closes itself when the time runs out. Everyone can add until then.';

  @override
  String openSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get openSheetCustom => 'Custom';

  @override
  String get openSheetStart => 'Open the basket';

  @override
  String get openSheetAlreadyOpen =>
      'Someone in your household already has a basket open.';

  @override
  String liveBasketItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items yet',
    );
    return '$_temp0';
  }

  @override
  String get liveBasketClosesByItself => 'CLOSES BY ITSELF';

  @override
  String get liveBasketAddHint => 'Add an item';

  @override
  String get liveBasketNoteHint => 'Note (optional)';

  @override
  String get liveBasketAdd => 'Add';

  @override
  String get liveBasketEmpty => 'Nothing in the basket yet.';

  @override
  String get liveBasketEmptyNote =>
      'Type what you need. Everyone else sees it as you type it.';

  @override
  String get liveBasketExtend => 'Extend once';

  @override
  String get liveBasketExtendUsed => 'Already extended';

  @override
  String get liveBasketCheckout => 'At checkout';

  @override
  String get liveBasketCancel => 'Cancel the run';

  @override
  String get liveBasketCancelConfirm => 'Cancel this run?';

  @override
  String get liveBasketCancelConfirmNote =>
      'Nothing gets priced and nobody owes anybody. The run shows up as cancelled.';

  @override
  String get liveBasketCancelKeep => 'Keep shopping';

  @override
  String get liveBasketCancelYes => 'Cancel it';

  @override
  String get liveBasketReconnecting => 'Reconnecting…';

  @override
  String get liveBasketClosedTitle => 'This basket closed';

  @override
  String get liveBasketClosedNote => 'It closed while you were away.';

  @override
  String get liveBasketBack => 'Back';

  @override
  String get liveBasketRemove => 'Remove';

  @override
  String get countdownListFinal => 'The list is final.';

  @override
  String get itemGotIt => 'Got it';

  @override
  String get itemNotAvailable => 'Not available';

  @override
  String itemGotBy(String name) {
    return '$name got it';
  }

  @override
  String get itemMarkBackOnList => 'Put it back on the list';

  @override
  String get itemMarkCancel => 'Cancel';

  @override
  String get liveBasketTickHint => 'Tap an item when it is in your basket.';

  @override
  String get liveBasketEnterPrices => 'Enter the prices';

  @override
  String get liveBasketWaitingTitle => 'Nothing to settle yet';

  @override
  String liveBasketWaitingNote(String name) {
    return '$name hasn\'t typed the prices in yet. Your share appears here when they do.';
  }

  @override
  String get liveBasketSeeSettlement => 'See who owes what';

  @override
  String get checkoutLocked => 'BASKET LOCKED';

  @override
  String get checkoutFrozen => 'FROZEN';

  @override
  String checkoutItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String checkoutClosedAt(String time) {
    return 'closed $time';
  }

  @override
  String get checkoutHint =>
      'Type what each thing cost. Tap anything that wasn\'t there.';

  @override
  String get checkoutUndo => 'Undo';

  @override
  String get checkoutItemsAddUp => 'Items add up to';

  @override
  String get checkoutReceiptTotal => 'Receipt total';

  @override
  String checkoutGapMore(String gap, int count, String each) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' Split evenly across all $count — $each each.',
      one: '',
    );
    return 'Receipt is $gap more than the items.$_temp0';
  }

  @override
  String checkoutGapLess(String gap, int count, String each) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' Split evenly across all $count — $each off each.',
      one: '',
    );
    return 'Receipt is $gap less than the items.$_temp0';
  }

  @override
  String get checkoutSettle => 'Work out who owes what';

  @override
  String checkoutUnfinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items still need a price',
      one: '1 item still needs a price',
    );
    return '$_temp0';
  }

  @override
  String get checkoutNotAPrice => 'That doesn\'t look like a price.';

  @override
  String get checkoutDidNotSave => 'That didn\'t save. Try again.';

  @override
  String get settlementBadge => 'SETTLED';

  @override
  String get settlementTitle => 'Settled up';

  @override
  String settlementSummary(String items, int unavailable, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      unavailable,
      locale: localeName,
      other: ' · $unavailable unavailable',
      zero: '',
    );
    return '$items$_temp0 · receipt $total';
  }

  @override
  String get settlementWhoOwes => 'WHO OWES WHOM';

  @override
  String settlementOwes(String from, String to) {
    return '$from owes $to';
  }

  @override
  String settlementBreakdown(String items, String gap) {
    return '$items items + $gap gap';
  }

  @override
  String settlementBreakdownCredit(String items, String gap) {
    return '$items items − $gap off';
  }

  @override
  String get settlementNobody => 'Nobody owes anybody';

  @override
  String get settlementNobodyNote =>
      'Everyone\'s share came to nothing, or to what the shopper bought for themselves.';

  @override
  String get settlementGapTitle => 'THE RECEIPT GAP';

  @override
  String get settlementItemsPriced => 'Items priced';

  @override
  String get settlementReceipt => 'Receipt';

  @override
  String settlementGapAcross(String gap, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$gap across $_temp0';
  }

  @override
  String get settlementCopy => 'Copy the summary';

  @override
  String get settlementCopied => 'Copied. Paste it wherever the house talks.';

  @override
  String settlementShareLine(String from, String to, String amount) {
    return '$from owes $to $amount';
  }

  @override
  String get settlementDone => 'Done';

  @override
  String get checkoutSomeone => 'Someone new';
}
