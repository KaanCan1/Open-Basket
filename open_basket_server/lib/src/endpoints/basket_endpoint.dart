import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/analytics_service.dart';
import '../services/authz.dart';
import '../services/basket_service.dart';
import '../util/clock.dart';

/// The basket lifecycle: open, extend, freeze, cancel, and everything that
/// happens to the items inside it.
///
/// `open -> frozen -> settled`, plus `open -> cancelled`.
class BasketEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// The server's clock, fetched on connect so the countdown can correct for
  /// drift. The client never trusts the device clock for `closesAt`.
  Future<DateTime> getServerTime(Session session) async => ServerClock.now();

  /// Opens a run. `closesAt` is `now + durationMinutes`, computed here.
  ///
  /// Throws `householdAlreadyHasOpenBasket` when one is already running — the
  /// client turns that into the "someone else already has a basket open"
  /// screen rather than an error. Two simultaneous calls must not both
  /// succeed: the partial unique index noted in `basket.spy.yaml` is the real
  /// guarantee, the transaction alone is not.
  ///
  /// Schedules the close. The "2 minutes left" reminder is Day 11-12, when
  /// there is a notification to send with it.
  Future<Basket> open(
    Session session, {
    int? storeId,
    required int durationMinutes,
  }) async {
    final member = await Authz.requireMember(session);
    final duration = _requireDuration(durationMinutes);
    final household = await Household.db.findById(
      session,
      member.householdId,
    );

    if (storeId != null) {
      final store = await Store.db.findById(session, storeId);
      if (store == null || store.householdId != member.householdId) {
        // Same reasoning as an unknown basket id: a store id that answers
        // differently depending on whose household it belongs to tells a
        // caller which ids exist elsewhere.
        throw OpenBasketException(
          error: BasketError.basketNotFound,
          message: 'That store is not in your household.',
        );
      }
    }

    // Checked here so the common case gets the right error rather than a
    // constraint violation. The index below is what actually enforces rule 4;
    // this is only the polite answer.
    final running = await BasketService.activeFor(session, member.householdId);
    if (running != null) throw _alreadyOpen();

    // One reading, used for both: two calls can land on either side of a
    // microsecond and leave closesAt - openedAt slightly short of the
    // duration the shopper actually picked.
    final now = ServerClock.now();
    final opened = Basket(
      householdId: member.householdId,
      shopperMemberId: member.id!,
      storeId: storeId,
      status: BasketStatus.open,
      openedAt: now,
      closesAt: now.add(duration),
      // Rule 5 and ADR-008: the basket keeps the code it opened with, so
      // changing the household setting later never rewrites a closed run.
      currencyCode: household?.currencyCode ?? 'TRY',
    );

    final Basket basket;
    try {
      basket = await Basket.db.insertRow(session, opened);
    } on DatabaseUniqueViolationException catch (e) {
      // Rule 4, for real. Two `open` calls that both passed the check above
      // arrive here; the partial unique index lets exactly one of them
      // through and this is the other one.
      if (e.constraintName == BasketService.openBasketIndexName) {
        throw _alreadyOpen();
      }
      rethrow;
    }

    await BasketService.scheduleClose(session, basket);
    await AnalyticsService.track(
      session,
      AnalyticsType.basketOpened,
      householdId: basket.householdId,
      basketId: basket.id,
      memberId: member.id,
      payload: {
        'durationMinutes': duration.inMinutes,
        'hasStore': storeId != null,
      },
    );
    return basket;
  }

  /// Adds five minutes, once per basket, shopper only (ADR-009). Throws
  /// `extensionAlreadyUsed` on the second attempt. Reschedules the future
  /// calls; the superseded one becomes a no-op when it fires.
  Future<Basket> extend(Session session, int basketId) async {
    final basket = await _requireOpen(session, basketId, shopperOnly: true);

    if (basket.extendCount >= 1) {
      throw OpenBasketException(
        error: BasketError.extensionAlreadyUsed,
        message: 'You have already added five minutes to this basket.',
      );
    }

    // From the current `closesAt`, not from now: extending with thirty
    // seconds left should buy five and a half minutes, not five.
    final extended = await Basket.db.updateRow(
      session,
      basket.copyWith(
        closesAt: basket.closesAt.add(BasketService.extension),
        extendCount: basket.extendCount + 1,
      ),
    );

    await BasketService.scheduleClose(session, extended);
    await AnalyticsService.track(
      session,
      AnalyticsType.basketExtended,
      householdId: extended.householdId,
      basketId: extended.id,
      memberId: extended.shopperMemberId,
    );
    return extended;
  }

  /// "At checkout" — no more items. Shopper only.
  Future<Basket> freeze(Session session, int basketId) async {
    final basket = await _requireOpen(session, basketId, shopperOnly: true);

    final frozen = await Basket.db.updateRow(
      session,
      basket.copyWith(
        status: BasketStatus.frozen,
        frozenAt: ServerClock.now(),
        // `closesAt` is left where it was on purpose. It is a record of when
        // this run was booked to end, and the history screen shows whether
        // the shopper beat the clock.
      ),
    );

    await BasketService.cancelScheduledClose(session, basketId);
    await AnalyticsService.track(
      session,
      AnalyticsType.basketFrozen,
      householdId: frozen.householdId,
      basketId: frozen.id,
      memberId: frozen.shopperMemberId,
      payload: {
        'secondsEarly': frozen.closesAt.difference(ServerClock.now()).inSeconds,
      },
    );
    return frozen;
  }

  /// Shopper only. Nothing is priced and nobody owes anybody; the run shows up
  /// in history as cancelled.
  Future<Basket> cancel(Session session, int basketId) async {
    final basket = await _requireOpen(session, basketId, shopperOnly: true);

    final cancelled = await Basket.db.updateRow(
      session,
      basket.copyWith(status: BasketStatus.cancelled),
    );

    await BasketService.cancelScheduledClose(session, basketId);
    await AnalyticsService.track(
      session,
      AnalyticsType.basketCancelled,
      householdId: cancelled.householdId,
      basketId: cancelled.id,
      memberId: cancelled.shopperMemberId,
    );
    return cancelled;
  }

  /// The household's open or frozen basket, or null. This is also what a
  /// client calls on cold start to discover that a basket closed while it was
  /// away.
  Future<Basket?> getActive(Session session) async {
    final member = await Authz.requireMember(session);
    return BasketService.activeFor(session, member.householdId);
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

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Loads a basket the caller is allowed to see.
  ///
  /// An unknown id and another household's id both answer `basketNotFound`:
  /// an endpoint that distinguishes them lets anyone enumerate which basket
  /// ids exist.
  Future<Basket> _requireVisible(Session session, int basketId) async {
    final member = await Authz.requireMember(session);
    final basket = await Basket.db.findById(session, basketId);
    if (basket == null || basket.householdId != member.householdId) {
      throw OpenBasketException(
        error: BasketError.basketNotFound,
        message: 'That basket is not one of yours.',
      );
    }
    return basket;
  }

  /// A basket that is still `open`, optionally proving the caller is the
  /// shopper. Extend, freeze and cancel all want exactly this.
  Future<Basket> _requireOpen(
    Session session,
    int basketId, {
    required bool shopperOnly,
  }) async {
    final basket = await _requireVisible(session, basketId);
    if (shopperOnly) await Authz.requireShopper(session, basket);
    if (basket.status != BasketStatus.open) {
      throw OpenBasketException(
        error: BasketError.basketNotOpen,
        message: 'This basket has already closed.',
      );
    }
    return basket;
  }

  Duration _requireDuration(int minutes) {
    final duration = Duration(minutes: minutes);
    if (duration < BasketService.minDuration ||
        duration > BasketService.maxDuration) {
      throw OpenBasketException(
        error: BasketError.invalidDuration,
        message:
            'Pick between ${BasketService.minDuration.inMinutes} and '
            '${BasketService.maxDuration.inMinutes} minutes.',
      );
    }
    return duration;
  }

  OpenBasketException _alreadyOpen() => OpenBasketException(
    error: BasketError.householdAlreadyHasOpenBasket,
    message: 'Someone in your household already has a basket open.',
  );
}
