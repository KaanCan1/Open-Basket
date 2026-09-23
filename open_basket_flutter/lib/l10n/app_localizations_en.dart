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
  String codeEntryResendIn(String time) {
    return 'Resend in $time';
  }

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
  String get liveBasketAddHint => 'Add an item';

  @override
  String get liveBasketNoteHint => 'Note (optional)';

  @override
  String get liveBasketAdd => 'Add';

  @override
  String get liveBasketEmpty => 'Nothing in the basket yet.';

  @override
  String get liveBasketEmptyNote =>
      'Type what you need. Everyone sees it the moment you add it.';

  @override
  String get liveBasketExtend => 'Extend once';

  @override
  String get liveBasketExtendUsed => 'Extend used';

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

  @override
  String get homeLastRunTitle => 'LAST RUN · SETTLED';

  @override
  String homeLastRunYouOwe(String name, String amount) {
    return 'You owe $name $amount';
  }

  @override
  String homeLastRunOwesYou(String name, String amount) {
    return '$name owes you $amount';
  }

  @override
  String homeLastRunManyOweYou(int count, String amount) {
    return '$count people owe you $amount in total';
  }

  @override
  String get homeLastRunClear => 'You don\'t owe anything on this one.';

  @override
  String get liveBasketReconnectingNote =>
      'The countdown is right — the server keeps the clock, not this phone.';

  @override
  String liveBasketLastSynced(String time) {
    return 'last synced $time';
  }

  @override
  String get liveBasketQueuedRow =>
      'Queued on this phone · sends when you\'re back';

  @override
  String liveBasketQueuedCount(int count) {
    return '$count queued';
  }

  @override
  String get liveBasketOfflineHint =>
      'Offline — anything you add is kept here and sent the moment you\'re back.';

  @override
  String liveBasketBackOnline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Back online · $count items sent',
      one: 'Back online · 1 item sent',
    );
    return '$_temp0';
  }

  @override
  String liveBasketBackOnlineNote(String names) {
    return 'Now on everyone\'s list: $names.';
  }

  @override
  String liveBasketDropped(String names) {
    return 'The basket closed before these could be sent: $names.';
  }

  @override
  String liveBasketJoinedTitle(String name, String time) {
    return '$name opened one at $time';
  }

  @override
  String get liveBasketJoinedNote =>
      'One basket at a time in a household — so here\'s that run instead.';

  @override
  String get countdownClosedOnTime => 'CLOSED ON TIME';

  @override
  String get countdownSettled => 'SETTLED';

  @override
  String get countdownCancelled => 'CANCELLED';

  @override
  String countdownClosedItself(String time) {
    return 'The basket closed itself at $time';
  }

  @override
  String countdownClosedItselfNote(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: 'minute',
    );
    return 'It ran the full $_temp0 and shut on the server.';
  }

  @override
  String countdownClosedBy(String name, String time) {
    return '$name closed it at $time';
  }

  @override
  String countdownCancelledBy(String name) {
    return '$name cancelled this run';
  }

  @override
  String get countdownCancelledNote =>
      'Nothing was priced and nobody owes anybody.';

  @override
  String get storesTitle => 'Stores';

  @override
  String get storesBlurb =>
      'Everyone in the house can pick it when they open a basket.';

  @override
  String get storesEmpty =>
      'No stores yet. Add the ones the house actually goes to.';

  @override
  String get storesAddTitle => 'Add a store';

  @override
  String get storesNameLabel => 'NAME';

  @override
  String get storesNameHint => 'Migros Bağdat Cd.';

  @override
  String get storesLocationLabel => 'LOCATION';

  @override
  String get storesUseLocation => 'Use my current location';

  @override
  String get storesLocationNote =>
      'Pinned once, now. We use it only to estimate how long a run takes.';

  @override
  String storesPinned(String lat, String lng) {
    return 'Pinned · $lat, $lng';
  }

  @override
  String get storesNoLocation => 'No location · baskets default to 10 minutes';

  @override
  String get storesHasLocation => 'Pinned';

  @override
  String get storesLocationFailed =>
      'Couldn\'t read your location. You can save it without one.';

  @override
  String get storesSave => 'Save store';

  @override
  String get storesSkipNote =>
      'Skip the location and we\'ll default every basket to 10 minutes.';

  @override
  String get storesRemove => 'Remove';

  @override
  String storesRemoveConfirm(String name) {
    return 'Remove $name?';
  }

  @override
  String storesRemoveNote(String name) {
    return 'Past runs at $name keep their history.';
  }

  @override
  String get storesInvalid => 'Give the store a name.';

  @override
  String get openSheetStore => 'STORE';

  @override
  String get openSheetHowLong => 'HOW LONG';

  @override
  String get openSheetAddStore => 'Add a store';

  @override
  String openSheetEstimating(String store) {
    return 'Working out how far $store is…';
  }

  @override
  String openSheetEstimated(int minutes) {
    return 'Estimated $minutes min';
  }

  @override
  String openSheetEstimatedNote(String store) {
    return 'From your distance to $store. Pick your own if you know better.';
  }

  @override
  String openSheetNoEstimate(String store) {
    return 'No estimate for $store, so pick a time.';
  }

  @override
  String openSheetOpenFor(int minutes) {
    return 'Open for $minutes minutes';
  }

  @override
  String get homeStoresLabel => 'STORES';

  @override
  String get homeStoresNone => 'None yet · add one';

  @override
  String countdownAtStore(String store) {
    return 'AT $store';
  }

  @override
  String homeBasketOpenAt(String name, String store) {
    return '$name is shopping at $store. Add what you need.';
  }

  @override
  String get historyTitle => 'History';

  @override
  String historySummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count runs',
      one: '1 run',
    );
    return '$_temp0 · $total through the house';
  }

  @override
  String get historyEmpty =>
      'No finished runs yet. They show up here once a basket is settled or cancelled.';

  @override
  String historyToday(String time) {
    return 'Today, $time';
  }

  @override
  String historyDayAndTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String historyYesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String historyWhen(String when, String name) {
    return '$when · $name shopped';
  }

  @override
  String historyRan(int minutes) {
    return 'ran $minutes min';
  }

  @override
  String get historyNoStore => 'A run';

  @override
  String get historySettled => 'Settled';

  @override
  String get historyCancelled => 'Cancelled';

  @override
  String get historyStatItems => 'items';

  @override
  String get historyStatUnavailable => 'unavailable';

  @override
  String get historyStatReceipt => 'receipt';

  @override
  String get historyHowSettled => 'HOW IT SETTLED';

  @override
  String historyLine(String from, String to) {
    return '$from → $to';
  }

  @override
  String historyGapNote(String each, String gap) {
    return 'Includes $each each of the $gap receipt gap.';
  }

  @override
  String get historyNobody => 'Nobody owes anybody';

  @override
  String historyCancelledNote(String name) {
    return '$name cancelled before the till, so nothing was priced and no settlement was made.';
  }

  @override
  String get historyWhatWasInIt => 'WHAT WAS IN IT';

  @override
  String historyAskedDropped(String name) {
    return '$name asked · dropped';
  }

  @override
  String get historyHowItRan => 'HOW IT RAN';

  @override
  String get historyOpened => 'Opened';

  @override
  String historyOpenedFor(String time, int minutes) {
    return '$time · for $minutes min';
  }

  @override
  String get historyClosed => 'Closed';

  @override
  String get historyPriced => 'Priced';

  @override
  String get historyNothing => 'nothing';

  @override
  String get homeHistoryLabel => 'HISTORY';

  @override
  String get homeHistoryNone => 'Nothing finished yet';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHousehold => 'HOUSEHOLD';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsCurrencyNote => 'Every price and settlement uses it.';

  @override
  String get settingsStores => 'Stores';

  @override
  String get settingsMembers => 'Members and code';

  @override
  String settingsMembersValue(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0 · $code';
  }

  @override
  String get settingsOwnerOnly => 'Only the owner can change this.';

  @override
  String get settingsRenameTitle => 'Rename the household';

  @override
  String get settingsRenameSave => 'Save';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String settingsLeave(String name) {
    return 'Leave $name';
  }

  @override
  String get settingsLeaveNote => 'You\'ll lose access to its history.';

  @override
  String settingsLeaveConfirm(String name) {
    return 'Leave $name?';
  }

  @override
  String get settingsLeaveConfirmNote =>
      'The household keeps every run you were part of. You can come back with its code.';

  @override
  String get settingsLeaveYes => 'Leave';

  @override
  String get settingsShopperCannotLeave =>
      'Finish or cancel your basket before you leave.';

  @override
  String get currencyTitle => 'Currency';

  @override
  String get currencyBlurb =>
      'One for the whole household. Every price, settlement and shared summary uses it.';

  @override
  String get currencyInUse => 'In use';

  @override
  String currencySample(String code, String sample) {
    return '$code · $sample';
  }

  @override
  String currencyNoCents(String code, String sample) {
    return '$code · $sample · no cents';
  }

  @override
  String get currencyNote =>
      'Changing this doesn\'t convert anything. Past runs keep the currency they were settled in.';

  @override
  String get currencySave => 'Save currency';

  @override
  String get currencyNameTRY => 'Turkish lira';

  @override
  String get currencyNameEUR => 'Euro';

  @override
  String get currencyNameGBP => 'Pound sterling';

  @override
  String get currencyNameUSD => 'US dollar';

  @override
  String get currencyNameJPY => 'Japanese yen';

  @override
  String get currencyNameCHF => 'Swiss franc';

  @override
  String get liveBasketUsually => 'YOU USUALLY ASK FOR';

  @override
  String get liveBasketTooMany => 'That\'s a lot at once. Give it a moment.';

  @override
  String get errorNotAMember => 'You\'re not in this household any more.';

  @override
  String get errorNotTheShopper => 'Only the shopper can do that.';

  @override
  String get errorBasketNotFound => 'That basket is gone.';

  @override
  String get errorInvalidDuration => 'Pick between 1 and 120 minutes.';

  @override
  String get errorItemNotFound => 'That item was just removed.';

  @override
  String get errorNotYourItem =>
      'Only the person who asked for it can change it.';

  @override
  String get errorInvalidItem =>
      'Give the item a name, and a quantity from 1 to 99.';

  @override
  String get errorStoreNotFound => 'That store was just removed.';

  @override
  String get errorInvalidStore => 'Store names are 1 to 60 characters.';

  @override
  String get errorInvalidHouseholdName =>
      'Household names are 1 to 60 characters.';

  @override
  String get errorInvalidCurrency => 'That currency isn\'t one we support yet.';

  @override
  String get errorBasketNotFrozen =>
      'Prices go in once the basket is at checkout.';

  @override
  String get errorAlreadySettled => 'This basket is already settled.';

  @override
  String get errorNotFullyPriced =>
      'Mark every item first: got it, with a price, or not available.';

  @override
  String get errorExtensionUsed =>
      'You\'ve already added five minutes to this basket.';

  @override
  String get checkoutEmpty => 'Nobody added anything this time.';

  @override
  String get checkoutEmptyNote =>
      'Settle to close the run. If you enter a receipt total, it\'s split evenly across the household.';

  @override
  String get liveBasketNoItems => 'No items';

  @override
  String get liveBasketEmptyClosed => 'Nobody added anything.';

  @override
  String get settingsYourName => 'Your name';

  @override
  String get settingsYourNameNote =>
      'What the house sees on your items and in who owes whom.';

  @override
  String get settingsYourNameTitle => 'What should the house call you?';

  @override
  String get errorInvalidMemberName => 'Names are 1 to 40 characters.';

  @override
  String get settingsYou => 'YOU';

  @override
  String get errorInvalidDeviceToken =>
      'This phone couldn\'t sign up for notifications.';

  @override
  String checkoutConfirmTitle(String amount) {
    return 'Settle $amount?';
  }

  @override
  String get checkoutConfirmNote =>
      'Who owes what is worked out from these prices and can\'t be changed afterwards.';

  @override
  String get checkoutConfirmYes => 'Settle';

  @override
  String get membersLabel => 'HOUSEHOLD';

  @override
  String get membersCodeLabel => 'HOUSEHOLD CODE';

  @override
  String get membersPermanent => 'PERMANENT';

  @override
  String get membersShare => 'Share';

  @override
  String get membersRotate => 'Rotate';

  @override
  String get membersCodeNote => 'Anyone with this code can join.';

  @override
  String get membersRotateOwnerOnly => 'Only the owner can change the code.';

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MEMBERS',
      one: '1 MEMBER',
    );
    return '$_temp0';
  }

  @override
  String get membersYou => '· you';

  @override
  String membersJoined(String when, String month) {
    String _temp0 = intl.Intl.selectLogic(
      when,
      {
        'thisWeek': 'Joined this week',
        'lastWeek': 'Joined last week',
        'other': 'Joined $month',
      },
    );
    return '$_temp0';
  }

  @override
  String membersOwnerJoined(String when, String month) {
    String _temp0 = intl.Intl.selectLogic(
      when,
      {
        'thisWeek': 'Owner · joined this week',
        'lastWeek': 'Owner · joined last week',
        'other': 'Owner · joined $month',
      },
    );
    return '$_temp0';
  }

  @override
  String membersShareSubject(String household) {
    return 'Join $household on Open Basket';
  }

  @override
  String membersShareText(String household, String code) {
    return 'Join $household on Open Basket. The code is $code. Get the app at https://open-basket.serverpod.space';
  }

  @override
  String get rotateTitle => 'Rotate the household code?';

  @override
  String get rotateBlurb =>
      'Everyone already in stays in. Only new joins are affected.';

  @override
  String get rotateOld => 'OLD';

  @override
  String get rotateOldNote => 'stops working now';

  @override
  String get rotateNew => 'NEW';

  @override
  String get rotateNewNote => 'picked when you rotate';

  @override
  String get rotateWarning =>
      'Anyone holding the old code can no longer join, including any message you already sent.';

  @override
  String rotateKeepPlace(String names) {
    return '$names keep their place. Nothing in history changes.';
  }

  @override
  String get rotateKeepPlaceOne =>
      'You keep your place. Nothing in history changes.';

  @override
  String namesAnd(String first, String last) {
    return '$first and $last';
  }

  @override
  String get rotateOwnerOnly =>
      'Owner only. There\'s no expiry: rotate as often as you like.';

  @override
  String get rotateAction => 'Rotate and share the new code';

  @override
  String rotateKeep(String code) {
    return 'Keep $code';
  }

  @override
  String get rotateNewDone => 'yours from now on';

  @override
  String get settingsNotifications => 'NOTIFICATIONS';

  @override
  String get settingsNotifyOpened => 'A basket opens';

  @override
  String get settingsNotifyClosingSoon => 'Two minutes left';

  @override
  String get settingsNotifySettled => 'Settlement is ready';

  @override
  String get settingsNotificationsNote =>
      'Kept on the server for when this phone can receive notifications; it can\'t yet.';

  @override
  String settingsFooter(String version) {
    return 'Open Basket $version';
  }

  @override
  String settingsFooterEmail(String version, String email) {
    return 'Open Basket $version · $email';
  }

  @override
  String get errorHouseholdCodeRotated => 'That code has been replaced';

  @override
  String get errorTooManyJoinAttempts =>
      'Too many tries. Wait a few minutes and try again.';

  @override
  String joinTriesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tries left.',
      one: 'One try left.',
      zero: 'No tries left for now: wait a few minutes.',
    );
    return '$_temp0';
  }

  @override
  String get joinUnknownNote => 'Check it against the message you were sent.';

  @override
  String get joinTryAgain => 'Try again';

  @override
  String get joinPaste => 'Paste what you were sent';

  @override
  String get joinRotatedNote =>
      'Nothing wrong with what you typed: the household changed its code after the message you were sent.';

  @override
  String get joinAskTitle => 'Ask for the new six characters';

  @override
  String get joinAskNote =>
      'Whoever invited you can see the current code on their members screen. Codes don\'t expire on their own; this one was changed on purpose.';

  @override
  String get joinAskAction => 'Send them a request';

  @override
  String get joinAskShareText =>
      'Could you send me the new code for our household on Open Basket?';

  @override
  String get joinEnterDifferent => 'Enter a different code';

  @override
  String get joinNeverIn =>
      'Nobody has removed you from anything: you were never in yet.';

  @override
  String get joinNoCode => 'No code yet?';

  @override
  String get joinStartOwn => 'Start your own household';

  @override
  String get liveBasketQuantityDone => 'Done';

  @override
  String liveBasketQuantityLabel(int count) {
    return 'Quantity $count';
  }

  @override
  String countdownClosesAt(String time) {
    return 'CLOSES $time';
  }

  @override
  String countdownExtendedTo(String time) {
    return 'EXTENDED TO $time';
  }

  @override
  String liveBasketGot(int count) {
    return '$count got';
  }

  @override
  String liveBasketYours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count are yours',
      one: '1 is yours',
    );
    return '$_temp0';
  }

  @override
  String get homeInvite => 'Invite';

  @override
  String householdChoiceSignedInAs(String email) {
    return 'Signed in as $email. Not you?';
  }

  @override
  String get householdChoiceNotYou => 'Not you?';
}
