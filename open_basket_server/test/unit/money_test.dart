import 'package:open_basket_server/src/util/money.dart';
import 'package:test/test.dart';

void main() {
  group('minorUnitDigits', () {
    test('defaults to 2', () {
      expect(Money.minorUnitDigits('TRY'), 2);
      expect(Money.minorUnitDigits('USD'), 2);
      expect(Money.minorUnitDigits('EUR'), 2);
      expect(Money.minorUnitDigits('ZZZ'), 2);
    });

    test('knows the zero-decimal currencies', () {
      expect(Money.minorUnitDigits('JPY'), 0);
      expect(Money.minorUnitDigits('KRW'), 0);
    });

    test('knows the three-decimal currencies', () {
      expect(Money.minorUnitDigits('KWD'), 3);
    });

    test('is case-insensitive', () {
      expect(Money.minorUnitDigits('jpy'), 0);
    });
  });

  group('splitEvenly', () {
    test('divides a gap that comes out exact', () {
      // The design's own example: ₺2.00 over four members is ₺0.50 each.
      expect(
        Money.splitEvenly(200, 4, remainderIndex: 0),
        [50, 50, 50, 50],
      );
    });

    test('gives the remainder to the shopper, not the members', () {
      // 201 over 4 is 50 each with 1 kuruş left. The shopper absorbs it.
      expect(
        Money.splitEvenly(201, 4, remainderIndex: 2),
        [50, 50, 51, 50],
      );
    });

    test('always sums back to the total', () {
      for (var total = -13; total <= 13; total++) {
        for (var count = 1; count <= 5; count++) {
          for (var idx = 0; idx < count; idx++) {
            final shares = Money.splitEvenly(total, count, remainderIndex: idx);
            expect(
              shares.reduce((a, b) => a + b),
              total,
              reason: 'total $total across $count, remainder at $idx',
            );
            expect(shares, hasLength(count));
          }
        }
      }
    });

    test('a single member takes the whole gap', () {
      expect(Money.splitEvenly(7, 1, remainderIndex: 0), [7]);
    });

    test('no gap means nobody owes anything extra', () {
      expect(Money.splitEvenly(0, 3, remainderIndex: 1), [0, 0, 0]);
    });

    test('a till that charged less is a credit, not a debt', () {
      // Every share is negative and they still close on the total.
      final shares = Money.splitEvenly(-200, 4, remainderIndex: 0);
      expect(shares, [-50, -50, -50, -50]);
      expect(shares.reduce((a, b) => a + b), -200);
    });

    test('a negative remainder also lands on the shopper', () {
      final shares = Money.splitEvenly(-201, 4, remainderIndex: 3);
      expect(shares.reduce((a, b) => a + b), -201);
      expect(shares[3], lessThan(shares[0]));
    });

    test('rejects nonsense', () {
      expect(
        () => Money.splitEvenly(100, 0, remainderIndex: 0),
        throwsArgumentError,
      );
      expect(
        () => Money.splitEvenly(100, 3, remainderIndex: 3),
        throwsArgumentError,
      );
    });
  });
}
