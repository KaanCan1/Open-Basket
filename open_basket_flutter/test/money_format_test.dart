import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_flutter/src/core/formatters.dart';

void main() {
  group('format', () {
    test('uses the currency, not the phone', () {
      expect(MoneyFormat.format(8450, 'TRY'), '₺84.50');
      expect(MoneyFormat.format(120400, 'USD'), r'$1,204.00');
    });

    test('a zero-decimal currency has no cents', () {
      expect(MoneyFormat.format(1003, 'JPY'), '¥1,003');
    });

    test('a three-decimal currency keeps all three', () {
      expect(MoneyFormat.format(1500, 'KWD'), contains('1.500'));
    });

    test('small and zero amounts keep their leading zero', () {
      expect(MoneyFormat.format(5, 'TRY'), '₺0.05');
      expect(MoneyFormat.format(0, 'TRY'), '₺0.00');
    });
  });

  group('plain', () {
    test('is what goes back into a price field', () {
      expect(MoneyFormat.plain(8450, 'TRY'), '84.50');
      expect(MoneyFormat.plain(5, 'TRY'), '0.05');
      expect(MoneyFormat.plain(1003, 'JPY'), '1003');
      expect(MoneyFormat.plain(-50, 'TRY'), '-0.50');
    });
  });

  group('parse', () {
    test('reads what a shopper types off a receipt', () {
      expect(MoneyFormat.parse('84.50', 'TRY'), 8450);
      expect(MoneyFormat.parse('84,50', 'TRY'), 8450);
      expect(MoneyFormat.parse('84', 'TRY'), 8400);
      expect(MoneyFormat.parse('84.5', 'TRY'), 8450);
      expect(MoneyFormat.parse(' 84. ', 'TRY'), 8400);
      expect(MoneyFormat.parse('0', 'TRY'), 0);
    });

    test('round-trips with plain', () {
      for (final minor in [0, 1, 9, 10, 99, 100, 5980, 1234567]) {
        expect(
          MoneyFormat.parse(MoneyFormat.plain(minor, 'TRY'), 'TRY'),
          minor,
        );
      }
    });

    test('a zero-decimal currency takes whole units only', () {
      expect(MoneyFormat.parse('1003', 'JPY'), 1003);
      expect(MoneyFormat.parse('10.5', 'JPY'), isNull);
    });

    test('refuses what is not a price', () {
      for (final text in ['', 'abc', '1.234', '-5', '1.2.3', '₺5', '.50']) {
        expect(MoneyFormat.parse(text, 'TRY'), isNull, reason: text);
      }
    });

    test('never goes through a double', () {
      // 0.29 * 100 is 28.999999999999996 in floating point.
      expect(MoneyFormat.parse('0.29', 'TRY'), 29);
      expect(MoneyFormat.parse('1.15', 'TRY'), 115);
    });
  });
}
