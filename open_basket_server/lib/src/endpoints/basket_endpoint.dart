import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// The basket lifecycle: open, extend, freeze, cancel, and everything that
/// happens to the items inside it.
///
/// `open -> frozen -> settled`, plus `open -> cancelled`.
class BasketEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// The server's clock, fetched on connect so the countdown can correct for
  /// drift. The client never trusts the device clock for `closesAt`.
  Future<DateTime> getServerTime(Session session) async {
    throw UnimplementedError('Day 8');
  }

  /// Opens a run. `closesAt` is `now + durationMinutes`, computed here.
  ///
  /// Throws `householdAlreadyHasOpenBasket` when one is already running — the
  /// client turns that into the "someone else already has a basket open"
  /// screen rather than an error. Two simultaneous calls must not both
  /// succeed: the partial unique index noted in `basket.spy.yaml` is the real
  /// guarantee, the transaction alone is not.
  ///
  /// Schedules the close and the "2 minutes left" future calls.
  Future<Basket> open(
    Session session, {
    int? storeId,
    required int durationMinutes,
  }) async {
    throw UnimplementedError('Day 8');
  }

  /// Adds five minutes, once per basket, shopper only (ADR-009). Throws
  /// `extensionAlreadyUsed` on the second attempt. Reschedules the future
  /// calls; the superseded one becomes a no-op when it fires.
  Future<Basket> extend(Session session, int basketId) async {
    throw UnimplementedError('Day 8');
  }

  /// "At checkout" — no more items. Shopper only.
  Future<Basket> freeze(Session session, int basketId) async {
    throw UnimplementedError('Day 8');
  }

  /// Shopper only. Nothing is priced and nobody owes anybody; the run shows up
  /// in history as cancelled.
  Future<Basket> cancel(Session session, int basketId) async {
    throw UnimplementedError('Day 8');
  }

  /// The household's open or frozen basket, or null. This is also what a
  /// client calls on cold start to discover that a basket closed while it was
  /// away.
  Future<Basket?> getActive(Session session) async {
    throw UnimplementedError('Day 8');
  }

  /// Any member, while the basket is `open`.
  Future<BasketItem> addItem(
    Session session,
    int basketId,
    String name, {
    int quantity = 1,
    String? note,
  }) async {
    throw UnimplementedError('Day 9');
  }

  /// Only the member who asked for the item, and only while `open`.
  Future<BasketItem> updateItem(
    Session session,
    int itemId, {
    String? name,
    int? quantity,
    String? note,
  }) async {
    throw UnimplementedError('Day 9');
  }

  /// Only the member who asked for it, and only while `open`.
  Future<void> removeItem(Session session, int itemId) async {
    throw UnimplementedError('Day 9');
  }

  /// Ticks an item off. Shopper only, allowed in **both** `open` and `frozen`
  /// (ADR-005) — the shopper marks things as they walk the aisles. `priceMinor`
  /// is only accepted once the basket is `frozen`.
  ///
  /// Publishes an `itemUpdated` event, so members watching see it live.
  Future<BasketItem> markItem(
    Session session,
    int itemId,
    ItemStatus status, {
    int? priceMinor,
  }) async {
    throw UnimplementedError('Day 15-16');
  }

  /// The till total, in minor units. Any difference from the item sum is split
  /// across every member at settlement (ADR-007); this only records it.
  Future<Basket> setReceiptTotal(
    Session session,
    int basketId,
    int receiptTotalMinor,
  ) async {
    throw UnimplementedError('Day 15-16');
  }
}
