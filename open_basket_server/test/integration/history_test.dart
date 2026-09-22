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

      expect(runs.map((b) => b.id), [third.id, second.id, first.id]);
      expect(runs.map((b) => b.status), [
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

    test('someone with no household is refused', () async {
      await expectLater(
        endpoints.history.list(asUser(mert)),
        _fails(BasketError.notAMember),
      );
    });
  });
}
