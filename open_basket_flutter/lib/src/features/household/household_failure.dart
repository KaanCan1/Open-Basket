import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';

/// Turns a server error into the sentence this screen should show.
///
/// Every household screen needs the same three or four cases, and a copy of
/// this switch in each of them is how one of them ends up saying "Something
/// went wrong" for a case the others word properly — which is exactly the bug
/// the sign-in screen had.
String householdFailureMessage(AppLocalizations l10n, Object error) {
  if (error is OpenBasketException) {
    return switch (error.error) {
      BasketError.unknownHouseholdCode => l10n.joinHouseholdUnknown,
      BasketError.alreadyInAHousehold => l10n.joinHouseholdAlreadyIn,
      _ => l10n.commonSomethingWentWrong,
    };
  }
  return l10n.commonOffline;
}
