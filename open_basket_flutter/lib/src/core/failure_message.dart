import 'package:open_basket_client/open_basket_client.dart';

import '../../l10n/app_localizations.dart';

/// Turns anything a server call can throw into the sentence to show.
///
/// The switch over [BasketError] has no default on purpose: a new error code
/// on the server stops the app compiling until someone words it, instead of
/// shipping as "Something went wrong". Before this, screens mapped the one or
/// two codes they expected, and the stores screen showed the server's own
/// English message, which rule 11 does not allow.
String failureMessage(AppLocalizations l10n, Object error) => switch (error) {
  OpenBasketException(:final error) => errorMessage(l10n, error),
  // No connection, or it dropped: the one case where trying again helps.
  ServerpodClientNetworkException() => l10n.commonOffline,
  // The server answered, but not with a code of ours: a crash or a 500.
  ServerpodClientException() => l10n.commonSomethingWentWrong,
  _ => l10n.commonOffline,
};

String errorMessage(AppLocalizations l10n, BasketError error) =>
    switch (error) {
      BasketError.notAMember => l10n.errorNotAMember,
      BasketError.notTheShopper => l10n.errorNotTheShopper,
      BasketError.notTheOwner => l10n.settingsOwnerOnly,
      BasketError.householdAlreadyHasOpenBasket => l10n.openSheetAlreadyOpen,
      BasketError.alreadyInAHousehold => l10n.joinHouseholdAlreadyIn,
      BasketError.unknownHouseholdCode => l10n.joinHouseholdUnknown,
      BasketError.basketNotFound => l10n.errorBasketNotFound,
      BasketError.invalidDuration => l10n.errorInvalidDuration,
      BasketError.itemNotFound => l10n.errorItemNotFound,
      BasketError.notYourItem => l10n.errorNotYourItem,
      BasketError.invalidItem => l10n.errorInvalidItem,
      BasketError.invalidPrice => l10n.checkoutNotAPrice,
      BasketError.storeNotFound => l10n.errorStoreNotFound,
      BasketError.invalidStore => l10n.errorInvalidStore,
      BasketError.invalidHouseholdName => l10n.errorInvalidHouseholdName,
      BasketError.invalidCurrency => l10n.errorInvalidCurrency,
      BasketError.shopperCannotLeave => l10n.settingsShopperCannotLeave,
      BasketError.tooManyItems => l10n.liveBasketTooMany,
      BasketError.basketNotOpen => l10n.liveBasketClosedTitle,
      BasketError.basketNotFrozen => l10n.errorBasketNotFrozen,
      BasketError.basketAlreadySettled => l10n.errorAlreadySettled,
      BasketError.basketNotFullyPriced => l10n.errorNotFullyPriced,
      BasketError.extensionAlreadyUsed => l10n.errorExtensionUsed,
      BasketError.invalidEmailAddress => l10n.signInInvalidEmail,
      BasketError.invalidSignInCode => l10n.codeEntryMismatch,
      BasketError.signInCodeExpired => l10n.codeEntryExpired,
      BasketError.tooManySignInAttempts => l10n.codeEntryBurned,
    };
