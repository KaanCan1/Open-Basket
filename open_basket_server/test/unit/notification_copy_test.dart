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

  group('the three messages, as screen 21 has them', () {
    test('a basket opened, with and without a store', () {
      final withStore = NotificationCopy.basketOpened(
        shopper: 'Kaan',
        store: 'Migros',
        minutes: 10,
        basketId: 7,
      );
      expect(withStore.title, 'Kaan is heading to Migros');
      expect(withStore.body, 'Add what you need in the next 10 min.');
      expect(withStore.data, {'type': 'basket_opened', 'basketId': '7'});

      expect(
        NotificationCopy.basketOpened(
          shopper: 'Kaan',
          store: null,
          minutes: 8,
          basketId: 7,
        ).title,
        'Kaan is going shopping',
      );
    });

    test('two minutes left', () {
      final m = NotificationCopy.closingSoon(shopper: 'Kaan', basketId: 1);
      expect(m.title, '2 minutes left on the basket');
      expect(m.body, "Last chance to add something to Kaan's run.");
    });

    test('what you owe, and how it was reached', () {
      final m = NotificationCopy.settlementReady(
        shopper: 'Kaan',
        amountMinor: 8500,
        itemsMinor: 8450,
        receiptGapMinor: 50,
        currencyCode: 'TRY',
        basketId: 1,
      );
      expect(m.title, 'You owe Kaan ₺85.00');
      expect(m.body, '₺84.50 of items plus ₺0.50 of the receipt gap.');
    });

    test('no gap, or a receipt that came under the items', () {
      String body(int gap) => NotificationCopy.settlementReady(
        shopper: 'Kaan',
        amountMinor: 8450 + gap,
        itemsMinor: 8450,
        receiptGapMinor: gap,
        currencyCode: 'TRY',
        basketId: 1,
      ).body;
      expect(body(0), '₺84.50 of items.');
      expect(body(-50), '₺84.50 of items less ₺0.50 the receipt came under.');
    });
  });
}
