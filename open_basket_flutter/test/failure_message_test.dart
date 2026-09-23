import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:open_basket_flutter/l10n/app_localizations.dart';
import 'package:open_basket_flutter/src/core/failure_message.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  OpenBasketException refused(BasketError error) =>
      OpenBasketException(error: error, message: 'server wording');

  test('a refusal is worded by the app, never by the server', () {
    for (final error in BasketError.values) {
      final message = failureMessage(l10n, refused(error));
      expect(message, isNot('server wording'), reason: error.name);
      expect(message, isNot(l10n.commonSomethingWentWrong), reason: error.name);
    }
  });

  test('the codes a person actually meets say what happened', () {
    expect(
      failureMessage(l10n, refused(BasketError.basketNotFullyPriced)),
      l10n.errorNotFullyPriced,
    );
    expect(
      failureMessage(l10n, refused(BasketError.notTheShopper)),
      'Only the shopper can do that.',
    );
  });

  test('no connection says so; a server crash does not blame the network', () {
    expect(
      failureMessage(l10n, const ServerpodClientNetworkException('down')),
      l10n.commonOffline,
    );
    expect(
      failureMessage(l10n, TimeoutException('slow')),
      l10n.commonOffline,
    );
    expect(
      failureMessage(l10n, const ServerpodClientUnknownException('500')),
      l10n.commonSomethingWentWrong,
    );
  });
}
