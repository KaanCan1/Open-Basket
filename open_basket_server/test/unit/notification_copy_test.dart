import 'package:open_basket_server/src/services/notification_copy.dart';
import 'package:open_basket_server/src/util/money.dart';
import 'package:test/test.dart';

void main() {
  group('money in a push reads like money in the app', () {
    test('lira with kuruş, grouped', () {
      expect(Money.format(8450, 'TRY'), '₺84.50');
      expect(Money.format(120400, 'USD'), r'$1,204.00');
    });

    test('yen has no minor unit', () {
      expect(Money.format(1003, 'JPY'), '¥1,003');
    });
  });

  group('the three messages, word for word (plan, Days 11-12)', () {
    test('a basket opened, with and without a store', () {
      final withStore = NotificationCopy.basketOpened(
        household: 'Kaya household',
        shopper: 'Kaan',
        store: 'Migros',
        minutes: 10,
        basketId: 7,
      );
      expect(withStore.title, 'Kaya household');
      expect(
        withStore.body,
        'Kaan is heading to Migros. Add what you need in the next 10 min.',
      );
      expect(withStore.data, {'type': 'basket_opened', 'basketId': '7'});

      final noStore = NotificationCopy.basketOpened(
        household: 'Kaya household',
        shopper: 'Kaan',
        store: null,
        minutes: 8,
        basketId: 7,
      );
      expect(
        noStore.body,
        'Kaan is going shopping. Add what you need in the next 8 min.',
      );
    });

    test('two minutes left', () {
      expect(
        NotificationCopy.closingSoon(household: 'H', basketId: 1).body,
        '2 minutes left on the basket.',
      );
    });

    test('what you owe, in the basket\'s currency', () {
      expect(
        NotificationCopy.settlementReady(
          household: 'H',
          shopper: 'Kaan',
          amountMinor: 8450,
          currencyCode: 'TRY',
          basketId: 1,
        ).body,
        "You owe Kaan ₺84.50 for today's run.",
      );
    });
  });
}
