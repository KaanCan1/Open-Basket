import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/endpoints/history_endpoint.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

void main() {
  withServerpod('Given a household with past runs', (
    sessionBuilder,
    endpoints,
  ) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';
    const mert = '33333333-3333-4333-8333-333333333333';

    /// Opens a run at [at], adds nothing, and ends it the way [end] says.
    Future<Basket> aRun(
      TestSessionBuilder shopper,
      DateTime at,
      Future<void> Function(int basketId) end,
    ) async {
      final basket = await withClock(
        Clock.fixed(at),
        () => endpoints.basket.open(shopper, durationMinutes: 10),
      );
      await end(basket.id!);
      return basket;
    }

    Future<void> settle(TestSessionBuilder shopper, int id) async {
      await endpoints.basket.freeze(shopper, id);
      await endpoints.settlement.settle(shopper, id);
    }

    test('finished runs come back newest first', () async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);

      final first = await aRun(
        shopper,
        DateTime.utc(2030, 5, 1, 9),
        (id) => settle(shopper, id),
      );
      final second = await aRun(
        shopper,
        DateTime.utc(2030, 5, 2, 9),
        (id) => endpoints.basket.cancel(shopper, id),
      );
      final third = await aRun(
        shopper,
        DateTime.utc(2030, 5, 3, 9),
        (id) => settle(shopper, id),
      );

      // Any member reads it, not only whoever shopped.
      final runs = await endpoints.history.list(asUser(ayse));

      expect(runs.map((r) => r.basket.id), [third.id, second.id, first.id]);
      expect(runs.map((r) => r.basket.status), [
        BasketStatus.settled,
        BasketStatus.cancelled,
        BasketStatus.settled,
      ]);
    });

    test('a run still open or at the checkout is not history yet', () async {
      final shopper = asUser(kaan);
      await endpoints.household.create(shopper, 'Kaya');
      final frozen = await endpoints.basket.open(shopper, durationMinutes: 10);
      await endpoints.basket.freeze(shopper, frozen.id!);
      await endpoints.basket.open(shopper, durationMinutes: 10);

      expect(await endpoints.history.list(shopper), isEmpty);
    });

    test('another household\'s runs never show up', () async {
      final shopper = asUser(kaan);
      await endpoints.household.create(shopper, 'Kaya');
      await aRun(
        shopper,
        DateTime.utc(2030, 5, 1, 9),
        (id) => endpoints.basket.cancel(shopper, id),
      );

      final outsider = asUser(mert);
      await endpoints.household.create(outsider, 'Other house');

      expect(await endpoints.history.list(outsider), isEmpty);
    });

    test('limit is honoured and clamped', () async {
      final shopper = asUser(kaan);
      await endpoints.household.create(shopper, 'Kaya');
      for (var day = 1; day <= 3; day++) {
        await aRun(
          shopper,
          DateTime.utc(2030, 5, day, 9),
          (id) => endpoints.basket.cancel(shopper, id),
        );
      }

      expect(await endpoints.history.list(shopper, limit: 1), hasLength(1));
      // Zero or less still answers something rather than nothing.
      expect(await endpoints.history.list(shopper, limit: 0), hasLength(1));
      expect(HistoryEndpoint.maxLimit, lessThanOrEqualTo(50));
    });

    test('each row carries its total and who asked for what', () async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await endpoints.basket.open(shopper, durationMinutes: 10);
      final milk = await endpoints.basket.addItem(
        asUser(ayse),
        basket.id!,
        'Milk',
      );
      final eggs = await endpoints.basket.addItem(
        asUser(ayse),
        basket.id!,
        'Eggs',
      );
      final bread = await endpoints.basket.addItem(
        shopper,
        basket.id!,
        'Bread',
      );
      await endpoints.basket.freeze(shopper, basket.id!);
      await endpoints.basket.markItem(
        shopper,
        milk.id!,
        ItemStatus.picked,
        priceMinor: 4250,
      );
      await endpoints.basket.markItem(
        shopper,
        eggs.id!,
        ItemStatus.unavailable,
      );
      await endpoints.basket.markItem(
        shopper,
        bread.id!,
        ItemStatus.picked,
        priceMinor: 1500,
      );
      await endpoints.settlement.settle(shopper, basket.id!);

      final run = (await endpoints.history.list(shopper)).single;

      // No receipt total entered: the priced items are what it cost.
      expect(run.totalMinor, 5750);
      expect(run.itemCount, 3);
      expect(run.unavailableCount, 1);
      expect(run.itemsByMember.values.toList()..sort(), [1, 2]);
    });

    test(
      'a receipt total wins over the item sum, and cancelled costs nothing',
      () {
        final settled = Basket(
          householdId: 1,
          shopperMemberId: 1,
          status: BasketStatus.settled,
          openedAt: DateTime.utc(2030),
          closesAt: DateTime.utc(2030),
          receiptTotalMinor: 6000,
        );
        final item = BasketItem(
          basketId: 1,
          requesterMemberId: 2,
          name: 'Milk',
          quantity: 1,
          status: ItemStatus.picked,
          priceMinor: 4250,
          addedAt: DateTime.utc(2030),
        );

        expect(HistoryEndpoint.summarise(settled, [item]).totalMinor, 6000);
        expect(
          HistoryEndpoint.summarise(
            settled.copyWith(status: BasketStatus.cancelled),
            [item],
          ).totalMinor,
          0,
        );
      },
    );

    test('one run comes back in full, to any member', () async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await endpoints.basket.open(shopper, durationMinutes: 10);
      await endpoints.basket.addItem(asUser(ayse), basket.id!, 'Milk');
      await endpoints.basket.cancel(shopper, basket.id!);

      final run = await endpoints.history.get(asUser(ayse), basket.id!);

      expect(run.basket!.status, BasketStatus.cancelled);
      expect(run.items!.map((i) => i.name), ['Milk']);
    });

    test('an outsider cannot read one run', () async {
      final shopper = asUser(kaan);
      await endpoints.household.create(shopper, 'Kaya');
      final basket = await endpoints.basket.open(shopper, durationMinutes: 10);
      final outsider = asUser(mert);
      await endpoints.household.create(outsider, 'Other house');

      await expectLater(
        endpoints.history.get(outsider, basket.id!),
        _fails(BasketError.basketNotFound),
      );
    });

    test('someone with no household is refused', () async {
      await expectLater(
        endpoints.history.list(asUser(mert)),
        _fails(BasketError.notAMember),
      );
    });
  });
}
