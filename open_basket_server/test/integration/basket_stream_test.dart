import 'dart:async';

import 'package:async/async.dart';
import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/endpoints/basket_stream_endpoint.dart';
import 'package:open_basket_server/src/future_calls/close_basket_future_call.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/basket_channels.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

final _noon = DateTime.utc(2030, 5, 1, 12);

void main() {
  withServerpod('Given a live basket', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';
    const mert = '33333333-3333-4333-8333-333333333333';

    /// Kaan owns the household, Ayşe is in it. Kaan is the shopper.
    Future<(TestSessionBuilder, TestSessionBuilder, Basket)>
    aLiveBasket() async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.open(shopper, durationMinutes: 10),
      );
      return (shopper, asUser(ayse), basket);
    }

    /// Opens a watch and waits for the snapshot, so the caller knows the
    /// subscription is live before it changes anything.
    Future<(StreamQueue<BasketEvent>, BasketEvent)> watch(
      TestSessionBuilder who,
      int basketId,
    ) async {
      final queue = StreamQueue(endpoints.basketStream.watch(who, basketId));
      final snapshot = await queue.next;
      return (queue, snapshot);
    }

    test('the channel name is the one the publisher uses', () {
      // The endpoint and the service each spell it; if they ever disagree,
      // every watcher goes quiet and nothing else fails.
      expect(BasketStreamEndpoint.channelFor(7), BasketChannels.forBasket(7));
      expect(BasketStreamEndpoint.channelFor(7), 'basket:7');
    });

    test('the first event is always a full snapshot', () async {
      final (shopper, _, basket) = await aLiveBasket();
      await endpoints.basket.addItem(shopper, basket.id!, 'Milk');

      final (queue, snapshot) = await watch(shopper, basket.id!);
      addTearDown(queue.cancel);

      expect(snapshot.type, BasketEventType.snapshot);
      expect(snapshot.basket!.id, basket.id);
      expect(snapshot.items!.map((final i) => i.name), ['Milk']);
      // Rule 1: every event carries the server's clock so the countdown can
      // keep correcting for drift without a second call.
      expect(snapshot.serverTime.isUtc, isTrue);
    });

    test('one person adds, the other sees it', () async {
      final (shopper, member, basket) = await aLiveBasket();

      // Ayşe is watching on her phone.
      final (queue, _) = await watch(member, basket.id!);
      addTearDown(queue.cancel);

      // Kaan adds something on his.
      final added = await endpoints.basket.addItem(
        shopper,
        basket.id!,
        'Eggs, 10 pack',
        quantity: 2,
        note: 'the big ones',
      );

      final event = await queue.next;
      expect(event.type, BasketEventType.itemAdded);
      expect(event.item!.id, added.id);
      expect(event.item!.name, 'Eggs, 10 pack');
      expect(event.item!.quantity, 2);
      expect(event.item!.note, 'the big ones');
    });

    test('two watchers both get the same event', () async {
      final (shopper, member, basket) = await aLiveBasket();

      final (hers, _) = await watch(member, basket.id!);
      final (his, _) = await watch(shopper, basket.id!);
      addTearDown(hers.cancel);
      addTearDown(his.cancel);

      await endpoints.basket.addItem(member, basket.id!, 'Bread');

      expect((await hers.next).item!.name, 'Bread');
      expect((await his.next).item!.name, 'Bread');
    });

    test('updating and removing an item reach the stream', () async {
      final (shopper, member, basket) = await aLiveBasket();
      final item = await endpoints.basket.addItem(member, basket.id!, 'Milk');

      final (queue, _) = await watch(shopper, basket.id!);
      addTearDown(queue.cancel);

      await endpoints.basket.updateItem(
        member,
        item.id!,
        name: 'Milk, 1L',
        quantity: 3,
      );
      final updated = await queue.next;
      expect(updated.type, BasketEventType.itemUpdated);
      expect(updated.item!.name, 'Milk, 1L');
      expect(updated.item!.quantity, 3);

      await endpoints.basket.removeItem(member, item.id!);
      final removed = await queue.next;
      expect(removed.type, BasketEventType.itemRemoved);
      // The whole row goes out, not just the id.
      expect(removed.item!.id, item.id);
      expect(removed.item!.name, 'Milk, 1L');
    });

    test('extending and freezing reach the stream', () async {
      final (shopper, member, basket) = await aLiveBasket();
      final (queue, _) = await watch(member, basket.id!);
      addTearDown(queue.cancel);

      await endpoints.basket.extend(shopper, basket.id!);
      final extended = await queue.next;
      expect(extended.type, BasketEventType.timerExtended);
      expect(
        extended.basket!.closesAt,
        basket.closesAt.add(const Duration(minutes: 5)),
      );

      await endpoints.basket.freeze(shopper, basket.id!);
      final frozen = await queue.next;
      expect(frozen.type, BasketEventType.basketFrozen);
      expect(frozen.basket!.status, BasketStatus.frozen);
    });

    test('the timer closing the basket reaches the stream', () async {
      final (shopper, member, basket) = await aLiveBasket();
      final (queue, _) = await watch(member, basket.id!);
      addTearDown(queue.cancel);

      // Nothing on anyone's phone does this. It is the future call's own
      // session posting to the channel.
      await withClock(
        Clock.fixed(basket.closesAt),
        () => CloseBasketFutureCall().close(sessionBuilder.build(), basket.id!),
      );

      final event = await queue.next;
      expect(event.type, BasketEventType.basketFrozen);
      expect(event.basket!.closedAutomatically, isTrue);
      expect(shopper, isNotNull); // keeps the tuple destructuring honest
    });

    test('a frozen basket keeps streaming; a cancelled one ends', () async {
      final (shopper, member, basket) = await aLiveBasket();

      // A plain subscription rather than a StreamQueue. Asking a StreamQueue
      // for one more event on a stream that has nothing more to say leaves a
      // request outstanding, and cancelling it in a tearDown then never
      // returns — a hung test rather than a failing one.
      final received = <BasketEvent>[];
      var ended = false;
      final sub = endpoints.basketStream
          .watch(member, basket.id!)
          .listen(received.add, onDone: () => ended = true);
      addTearDown(sub.cancel);
      await _until(() => received.isNotEmpty);

      await endpoints.basket.freeze(shopper, basket.id!);
      await _until(() => received.length >= 2);
      expect(received[1].type, BasketEventType.basketFrozen);

      // Frozen is not over: the shopper still has prices to enter and the
      // house is still watching it happen.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(
        ended,
        isFalse,
        reason: 'Freezing hung up on the watchers before prices were entered.',
      );
    });

    test(
      'cancelling ends the stream, so the client stops reconnecting',
      () async {
        final (shopper, member, basket) = await aLiveBasket();
        final (queue, _) = await watch(member, basket.id!);

        await endpoints.basket.cancel(shopper, basket.id!);

        expect((await queue.next).type, BasketEventType.basketCancelled);
        expect(
          await queue.hasNext,
          isFalse,
          reason:
              'A cancelled basket left its watchers holding an open socket.',
        );
      },
    );

    test('watching a basket that is already over gives one snapshot', () async {
      final (shopper, member, basket) = await aLiveBasket();
      await endpoints.basket.cancel(shopper, basket.id!);

      final (queue, snapshot) = await watch(member, basket.id!);
      expect(snapshot.type, BasketEventType.snapshot);
      expect(snapshot.basket!.status, BasketStatus.cancelled);
      expect(await queue.hasNext, isFalse);
    });

    test('an outsider cannot watch, and learns nothing by trying', () async {
      final (_, _, basket) = await aLiveBasket();
      final outsider = asUser(mert);
      await endpoints.household.create(outsider, 'Other house');

      await expectLater(
        endpoints.basketStream.watch(outsider, basket.id!).first,
        _fails(BasketError.basketNotFound),
      );
      await expectLater(
        endpoints.basketStream.watch(outsider, 999999).first,
        _fails(BasketError.basketNotFound),
      );
    });
  });
}

/// Waits for [condition], or gives up. Used instead of a fixed delay so a slow
/// machine does not turn into a flaky test.
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
