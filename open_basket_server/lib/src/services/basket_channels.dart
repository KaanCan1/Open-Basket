import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../util/clock.dart';

/// The live basket channel: one per basket, `basket:<id>`.
///
/// Everything that changes a basket posts here, and every watcher reads from
/// here. Keeping the name and the event shape in one place is what stops a
/// publisher and a subscriber drifting apart — the bug that would show up as
/// "it works on my phone but not hers", which is the hardest kind to find in
/// a household of two testers.
abstract final class BasketChannels {
  static String forBasket(int basketId) => 'basket:$basketId';

  /// Posts an event to everyone watching [basketId].
  ///
  /// Never throws. A member who misses an event is a member whose screen is
  /// briefly stale; a shopper whose `freeze` failed because a notification
  /// could not be posted is a shopper standing at the till. The stream is a
  /// convenience over the database, and the client resyncs from a fresh
  /// `snapshot` whenever it reconnects.
  ///
  /// Delivery is local to this server process. `MessageScope.auto` upgrades
  /// to Redis when it is enabled; it is not, so **a second server instance
  /// would not see these events**. That is fine for the Day 10 deploy, which
  /// is one instance, and is the first thing to change before a second.
  static Future<void> publish(
    Session session,
    int basketId,
    BasketEventType type, {
    Basket? basket,
    BasketItem? item,
    List<BasketItem>? items,
  }) async {
    try {
      await session.messages.postMessage(
        forBasket(basketId),
        BasketEvent(
          type: type,
          basket: basket,
          item: item,
          items: items,
          serverTime: ServerClock.now(),
        ),
      );
    } catch (e, stackTrace) {
      session.log(
        'could not publish $type on ${forBasket(basketId)}',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }
}
