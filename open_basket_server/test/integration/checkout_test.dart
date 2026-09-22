import 'dart:async';

import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

final _noon = DateTime.utc(2030, 5, 1, 12);

void main() {
  withServerpod('Given a shopper at the checkout', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';
    const mert = '33333333-3333-4333-8333-333333333333';

    /// Kaan is shopping, Ayşe has asked for milk.
    Future<(TestSessionBuilder, TestSessionBuilder, Basket, BasketItem)>
    aBasketWithMilk() async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.open(shopper, durationMinutes: 10),
      );
      final milk = await endpoints.basket.addItem(
        asUser(ayse),
        basket.id!,
        'Milk',
      );
      return (shopper, asUser(ayse), basket, milk);
    }

    group('marking an item', () {
      test(
        'the shopper ticks it off while the basket is open (ADR-005)',
        () async {
          final (shopper, _, _, milk) = await aBasketWithMilk();

          final picked = await endpoints.basket.markItem(
            shopper,
            milk.id!,
            ItemStatus.picked,
          );

          expect(picked.status, ItemStatus.picked);
          expect(picked.priceMinor, isNull);
        },
      );

      test('only the shopper marks, even on your own item', () async {
        final (_, member, _, milk) = await aBasketWithMilk();

        await expectLater(
          endpoints.basket.markItem(member, milk.id!, ItemStatus.picked),
          _fails(BasketError.notTheShopper),
        );
      });

      test('an outsider learns nothing about the item', () async {
        final (_, _, _, milk) = await aBasketWithMilk();
        final outsider = asUser(mert);
        await endpoints.household.create(outsider, 'Other house');

        await expectLater(
          endpoints.basket.markItem(outsider, milk.id!, ItemStatus.picked),
          _fails(BasketError.itemNotFound),
        );
        await expectLater(
          endpoints.basket.markItem(outsider, 999999, ItemStatus.picked),
          _fails(BasketError.itemNotFound),
        );
      });

      test('prices wait for the checkout', () async {
        final (shopper, _, _, milk) = await aBasketWithMilk();

        await expectLater(
          endpoints.basket.markItem(
            shopper,
            milk.id!,
            ItemStatus.picked,
            priceMinor: 4250,
          ),
          _fails(BasketError.basketNotFrozen),
        );
      });

      test('at the checkout a picked item takes a price', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);

        final priced = await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.picked,
          priceMinor: 4250,
        );

        expect(priced.status, ItemStatus.picked);
        expect(priced.priceMinor, 4250);
      });

      test('something that was not bought has no price', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);

        for (final status in [ItemStatus.unavailable, ItemStatus.requested]) {
          await expectLater(
            endpoints.basket.markItem(
              shopper,
              milk.id!,
              status,
              priceMinor: 100,
            ),
            _fails(BasketError.invalidPrice),
            reason: '$status took a price',
          );
        }
      });

      test('a negative or absurd price is refused; zero is free', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);

        for (final price in [-1, 100000001]) {
          await expectLater(
            endpoints.basket.markItem(
              shopper,
              milk.id!,
              ItemStatus.picked,
              priceMinor: price,
            ),
            _fails(BasketError.invalidPrice),
            reason: '$price was accepted',
          );
        }

        // A free sample is a real thing to have picked up.
        final free = await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.picked,
          priceMinor: 0,
        );
        expect(free.priceMinor, 0);
      });

      test('tapping "Got it" again keeps the price already typed', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);
        await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.picked,
          priceMinor: 4250,
        );

        final again = await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.picked,
        );

        expect(again.priceMinor, 4250);
      });

      test('marking it not available clears the price', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);
        await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.picked,
          priceMinor: 4250,
        );

        final gone = await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.unavailable,
        );
        expect(gone.status, ItemStatus.unavailable);
        expect(gone.priceMinor, isNull);

        // And putting it back does not resurrect the old price.
        final back = await endpoints.basket.markItem(
          shopper,
          milk.id!,
          ItemStatus.picked,
        );
        expect(back.priceMinor, isNull);
      });

      test('a cancelled basket cannot be marked', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await endpoints.basket.cancel(shopper, basket.id!);

        await expectLater(
          endpoints.basket.markItem(shopper, milk.id!, ItemStatus.picked),
          _fails(BasketError.basketNotOpen),
        );
      });

      test('a settled basket cannot be marked (rule 6)', () async {
        final (shopper, _, basket, milk) = await aBasketWithMilk();
        await _settleBehindTheEndpointsBack(sessionBuilder, basket.id!);

        await expectLater(
          endpoints.basket.markItem(shopper, milk.id!, ItemStatus.unavailable),
          _fails(BasketError.basketAlreadySettled),
        );
      });

      test('the house sees it ticked off live', () async {
        final (shopper, member, basket, milk) = await aBasketWithMilk();
        final received = <BasketEvent>[];
        final sub = endpoints.basketStream
            .watch(member, basket.id!)
            .listen(received.add);
        addTearDown(sub.cancel);
        await _until(() => received.isNotEmpty);

        await endpoints.basket.markItem(shopper, milk.id!, ItemStatus.picked);

        await _until(() => received.length >= 2);
        expect(received[1].type, BasketEventType.itemUpdated);
        expect(received[1].item!.id, milk.id);
        expect(received[1].item!.status, ItemStatus.picked);
      });
    });

    group('the receipt total', () {
      test('goes in at the checkout, and the house sees it', () async {
        final (shopper, member, basket, _) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);
        final received = <BasketEvent>[];
        final sub = endpoints.basketStream
            .watch(member, basket.id!)
            .listen(received.add);
        addTearDown(sub.cancel);
        await _until(() => received.isNotEmpty);

        final updated = await endpoints.basket.setReceiptTotal(
          shopper,
          basket.id!,
          12790,
        );

        expect(updated.receiptTotalMinor, 12790);
        await _until(() => received.length >= 2);
        expect(received[1].type, BasketEventType.basketUpdated);
        expect(received[1].basket!.receiptTotalMinor, 12790);
      });

      test('waits for the checkout', () async {
        final (shopper, _, basket, _) = await aBasketWithMilk();

        await expectLater(
          endpoints.basket.setReceiptTotal(shopper, basket.id!, 12790),
          _fails(BasketError.basketNotFrozen),
        );
      });

      test('is the shopper\'s to enter', () async {
        final (shopper, member, basket, _) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);

        await expectLater(
          endpoints.basket.setReceiptTotal(member, basket.id!, 12790),
          _fails(BasketError.notTheShopper),
        );
      });

      test('cannot be zero, negative or absurd', () async {
        final (shopper, _, basket, _) = await aBasketWithMilk();
        await endpoints.basket.freeze(shopper, basket.id!);

        for (final total in [0, -1, 100000001]) {
          await expectLater(
            endpoints.basket.setReceiptTotal(shopper, basket.id!, total),
            _fails(BasketError.invalidPrice),
            reason: '$total was accepted',
          );
        }
      });

      test('cannot change once the basket is settled (rule 6)', () async {
        final (shopper, _, basket, _) = await aBasketWithMilk();
        await _settleBehindTheEndpointsBack(sessionBuilder, basket.id!);

        await expectLater(
          endpoints.basket.setReceiptTotal(shopper, basket.id!, 12790),
          _fails(BasketError.basketAlreadySettled),
        );
      });
    });
  });
}

/// Settling has its own endpoint (Days 17-18). These tests only need a basket
/// in that state, so they put it there directly.
Future<void> _settleBehindTheEndpointsBack(
  TestSessionBuilder sessionBuilder,
  int basketId,
) async {
  final session = sessionBuilder.build();
  final basket = await Basket.db.findById(session, basketId);
  await Basket.db.updateRow(
    session,
    basket!.copyWith(status: BasketStatus.settled),
  );
}

/// Waits for [condition], or gives up.
Future<void> _until(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Timed out waiting for the stream');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
