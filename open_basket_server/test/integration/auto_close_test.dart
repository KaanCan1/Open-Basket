import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/future_calls/close_basket_future_call.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/analytics_service.dart';
import 'package:open_basket_server/src/services/basket_service.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Far enough ahead that the test server's real future call manager never
/// fires anything we schedule while the test is running.
final _noon = DateTime.utc(2030, 5, 1, 12);

void main() {
  withServerpod('Given a basket whose time runs out', (
    sessionBuilder,
    endpoints,
  ) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';

    Future<TestSessionBuilder> aHousehold() async {
      final owner = asUser(kaan);
      await endpoints.household.create(owner, 'Kaya');
      return owner;
    }

    /// Opens a basket at [_noon] for [minutes], the way the shopper would.
    Future<Basket> openAtNoon(
      TestSessionBuilder owner, {
      int minutes = 5,
    }) {
      return withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.open(owner, durationMinutes: minutes),
      );
    }

    /// Fires the future call exactly as Serverpod would, at [at].
    Future<void> fireCloseAt(DateTime at, int basketId) {
      return withClock(
        Clock.fixed(at),
        () => CloseBasketFutureCall().close(sessionBuilder.build(), basketId),
      );
    }

    test('it freezes on time, without anyone\'s phone being awake', () async {
      final owner = await aHousehold();
      final basket = await openAtNoon(owner);

      await fireCloseAt(basket.closesAt, basket.id!);

      final closed = (await endpoints.basket.getActive(owner))!;
      expect(closed.status, BasketStatus.frozen);
      expect(closed.frozenAt, basket.closesAt);
      // This is what tells the history screen "the timer did it", and what
      // the settlement screen uses to word the summary.
      expect(closed.closedAutomatically, isTrue);
    });

    test('a call that fires early does nothing (rule 2)', () async {
      final owner = await aHousehold();
      final basket = await openAtNoon(owner, minutes: 5);

      await fireCloseAt(_noon.add(const Duration(minutes: 4)), basket.id!);

      final still = (await endpoints.basket.getActive(owner))!;
      expect(still.status, BasketStatus.open);
      expect(still.frozenAt, isNull);
    });

    test('an extended basket does not close at the old deadline', () async {
      final owner = await aHousehold();
      final basket = await openAtNoon(owner, minutes: 5);

      await withClock(
        Clock.fixed(_noon.add(const Duration(minutes: 3))),
        () => endpoints.basket.extend(owner, basket.id!),
      );

      // The superseded call still fires — Serverpod scheduled it before the
      // extension and we do not depend on the cancel having landed.
      await fireCloseAt(basket.closesAt, basket.id!);

      expect(
        (await endpoints.basket.getActive(owner))!.status,
        BasketStatus.open,
        reason: 'The old future call closed a basket that had been extended.',
      );

      // And it does close, five minutes later.
      await fireCloseAt(
        basket.closesAt.add(const Duration(minutes: 5)),
        basket.id!,
      );
      expect(
        (await endpoints.basket.getActive(owner))!.status,
        BasketStatus.frozen,
      );
    });

    test('firing twice closes it once (rule 2)', () async {
      final owner = await aHousehold();
      final basket = await openAtNoon(owner);

      await fireCloseAt(basket.closesAt, basket.id!);
      final first = (await endpoints.basket.getActive(owner))!;

      // A retry, a duplicate delivery, or the sweep racing the future call.
      await fireCloseAt(
        basket.closesAt.add(const Duration(minutes: 1)),
        basket.id!,
      );
      final second = (await endpoints.basket.getActive(owner))!;

      expect(second.frozenAt, first.frozenAt);

      final autoClosed = await AnalyticsEvent.db.find(
        sessionBuilder.build(),
        where: (final t) =>
            t.basketId.equals(basket.id) &
            t.type.equals(AnalyticsType.basketAutoClosed),
      );
      expect(
        autoClosed,
        hasLength(1),
        reason: 'A second firing wrote a second basket_auto_closed row.',
      );
    });

    test('a basket the shopper already froze is left alone', () async {
      final owner = await aHousehold();
      final basket = await openAtNoon(owner);

      final frozen = await withClock(
        Clock.fixed(_noon.add(const Duration(minutes: 2))),
        () => endpoints.basket.freeze(owner, basket.id!),
      );

      await fireCloseAt(basket.closesAt, basket.id!);

      final after = (await endpoints.basket.getActive(owner))!;
      expect(after.frozenAt, frozen.frozenAt);
      expect(
        after.closedAutomatically,
        isFalse,
        reason: 'The timer took credit for a checkout the shopper did.',
      );
    });

    test('a cancelled basket is never reopened as frozen', () async {
      final owner = await aHousehold();
      final basket = await openAtNoon(owner);
      await endpoints.basket.cancel(owner, basket.id!);

      await fireCloseAt(basket.closesAt, basket.id!);

      final reloaded = await Basket.db.findById(
        sessionBuilder.build(),
        basket.id!,
      );
      expect(reloaded!.status, BasketStatus.cancelled);
    });

    test('a call for a basket that no longer exists is harmless', () async {
      await expectLater(
        fireCloseAt(_noon, 999999),
        completes,
      );
    });

    test('the startup sweep closes what the future calls missed', () async {
      final owner = await aHousehold();
      final overdue = await openAtNoon(owner, minutes: 5);

      // The server was down when this one was due. Nothing is waiting on it.
      final closed = await withClock(
        Clock.fixed(_noon.add(const Duration(minutes: 30))),
        () => BasketService.sweepExpired(sessionBuilder.build()),
      );

      expect(closed, 1);
      final swept = (await endpoints.basket.getActive(owner))!;
      expect(swept.id, overdue.id);
      expect(swept.status, BasketStatus.frozen);
      expect(swept.closedAutomatically, isTrue);
    });

    test('the sweep leaves a basket that is still running', () async {
      final owner = await aHousehold();
      await openAtNoon(owner, minutes: 30);

      final closed = await withClock(
        Clock.fixed(_noon.add(const Duration(minutes: 10))),
        () => BasketService.sweepExpired(sessionBuilder.build()),
      );

      expect(closed, 0);
      expect(
        (await endpoints.basket.getActive(owner))!.status,
        BasketStatus.open,
      );
    });

    test('the sweep is safe to run when there is nothing to do', () async {
      expect(await BasketService.sweepExpired(sessionBuilder.build()), 0);
    });
  });
}
