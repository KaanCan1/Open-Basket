import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/authz.dart';
import '../services/basket_channels.dart';
import '../util/clock.dart';

/// The live basket.
///
/// This is the half of the product that a request/response API cannot do: an
/// item typed on one phone appears on every other phone in the house before
/// the person who typed it has put their phone down.
class BasketStreamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Channel name for a basket's events. Kept here as well as on
  /// `BasketChannels` because it is part of this endpoint's contract, and
  /// asserted equal to it in `basket_stream_test`.
  static String channelFor(int basketId) => BasketChannels.forBasket(basketId);

  /// Watches one basket.
  ///
  /// The first event is always a `snapshot` carrying the basket and all of its
  /// items, so a client that dropped its connection resyncs from the stream
  /// itself and never needs a second call. Every event carries `serverTime`.
  ///
  /// Throws `notAMember` before yielding anything.
  ///
  /// **Events can arrive out of order with respect to the snapshot.** The
  /// subscription opens before the snapshot is read, on purpose — the other
  /// order would silently drop anything that happened while the read was in
  /// flight. So an `itemAdded` for a row the snapshot already contains is
  /// normal, and the client must apply events by item id rather than by
  /// appending. Dropping events is unrecoverable; applying one twice is not.
  ///
  /// The stream completes on its own once the basket reaches a state nothing
  /// more can happen in — `settled` or `cancelled`. A client that sees
  /// `onDone` should go back to the household screen, not reconnect.
  Stream<BasketEvent> watch(Session session, int basketId) async* {
    final member = await Authz.requireMember(session);
    final basket = await Basket.db.findById(session, basketId);
    if (basket == null || basket.householdId != member.householdId) {
      throw OpenBasketException(
        error: BasketError.basketNotFound,
        message: 'That basket is not one of yours.',
      );
    }

    // Subscribe first. Anything published between here and the snapshot below
    // is queued rather than lost.
    final events = session.messages.createStream<BasketEvent>(
      channelFor(basketId),
    );

    yield BasketEvent(
      type: BasketEventType.snapshot,
      basket: basket,
      items: await BasketItem.db.find(
        session,
        where: (final t) => t.basketId.equals(basketId),
        orderBy: (final t) => t.addedAt,
      ),
      serverTime: ServerClock.now(),
    );

    if (_isOver(basket.status)) return;

    await for (final event in events) {
      yield event;
      if (event.basket != null && _isOver(event.basket!.status)) return;
    }
  }

  /// `frozen` is not over: the shopper is still marking items and entering
  /// prices, and every member watching wants to see that happen.
  bool _isOver(BasketStatus status) =>
      status == BasketStatus.settled || status == BasketStatus.cancelled;
}
