import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/analytics_service.dart';
import '../services/authz.dart';
import '../services/basket_channels.dart';
import '../services/basket_service.dart';
import '../services/notification_service.dart';
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
          error: BasketError.storeNotFound,
          message: 'That store is not in your household.',
        );
      }
    }

    // Checked here so the common case gets the right error rather than a
    // constraint violation. The index below is what actually enforces rule 4;
    // this is only the polite answer.
    final running = await BasketService.openFor(session, member.householdId);
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
    await NotificationService.basketOpened(session, basket);
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
    await BasketChannels.publish(
      session,
      extended.id!,
      BasketEventType.timerExtended,
      basket: extended,
    );
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
    await BasketChannels.publish(
      session,
      basketId,
      BasketEventType.basketFrozen,
      basket: frozen,
    );
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
    await BasketChannels.publish(
      session,
      basketId,
      BasketEventType.basketCancelled,
      basket: cancelled,
    );
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
  ///
  /// `quantity` is nullable rather than defaulted because Serverpod turns a
  /// defaulted named parameter into a *required* one on the generated client —
  /// `int quantity = 1` here becomes `required int quantity` there, and every
  /// caller would have to spell out the common case. Null means one.
  Future<BasketItem> addItem(
    Session session,
    int basketId,
    String name, {
    int? quantity,
    ItemUnit? unit,
    String? note,
  }) async {
    final basket = await _requireVisible(session, basketId);
    final member = await Authz.requireMemberOf(session, basket.householdId);
    _requireOpenBasket(basket);
    await _requireRoomFor(session, basketId, member.id!);

    final item = await BasketItem.db.insertRow(
      session,
      BasketItem(
        basketId: basketId,
        requesterMemberId: member.id!,
        name: _requireItemName(name),
        quantity: _requireQuantity(quantity ?? 1, unit ?? ItemUnit.piece),
        unit: unit ?? ItemUnit.piece,
        note: _cleanNote(note),
        status: ItemStatus.requested,
        addedAt: ServerClock.now(),
      ),
    );

    await BasketChannels.publish(
      session,
      basketId,
      BasketEventType.itemAdded,
      item: item,
    );
    await AnalyticsService.track(
      session,
      AnalyticsType.itemAdded,
      householdId: basket.householdId,
      basketId: basketId,
      memberId: member.id,
      payload: {
        'quantity': item.quantity,
        'unit': item.unit.name,
        'hasNote': item.note != null,
      },
    );
    return item;
  }

  /// Only the member who asked for the item, and only while `open`.
  Future<BasketItem> updateItem(
    Session session,
    int itemId, {
    String? name,
    int? quantity,
    ItemUnit? unit,
    String? note,
  }) async {
    final (item, basket) = await _requireOwnItem(session, itemId);
    final newUnit = unit ?? item.unit;

    final updated = await BasketItem.db.updateRow(
      session,
      item.copyWith(
        name: name == null ? item.name : _requireItemName(name),
        // A new unit re-checks the quantity it comes with, or the one the
        // item already had: 500 is fine in grams and not in kilos.
        quantity: _requireQuantity(quantity ?? item.quantity, newUnit),
        unit: newUnit,
        // An explicit empty string clears the note; leaving the argument out
        // keeps it. copyWith cannot express "set to null", so this is written
        // out rather than folded into the call above.
        note: note == null ? item.note : _cleanNote(note),
      ),
    );

    await BasketChannels.publish(
      session,
      basket.id!,
      BasketEventType.itemUpdated,
      item: updated,
    );
    return updated;
  }

  /// Only the member who asked for it, and only while `open`.
  Future<void> removeItem(Session session, int itemId) async {
    final (item, basket) = await _requireOwnItem(session, itemId);

    await BasketItem.db.deleteRow(session, item);
    // The whole row goes out, not just the id: a client that missed the
    // itemAdded has something to reconcile against, and the removed row is
    // what the "undo" copy in the design needs.
    await BasketChannels.publish(
      session,
      basket.id!,
      BasketEventType.itemRemoved,
      item: item,
    );
  }

  /// Names this member has asked for more than once, most often first — the
  /// design's "You usually ask for" chips (screen 24). Case and surrounding
  /// space are ignored when counting; the spelling returned is the most
  /// recent one. Only the caller's own requests, only their household.
  ///
  /// Nullable `limit` for the generated-client reason noted on `addItem`.
  Future<List<String>> suggestions(Session session, {int? limit}) async {
    final member = await Authz.requireMember(session);
    final rows = await session.db.unsafeQuery(
      'SELECT (array_agg("name" ORDER BY "addedAt" DESC))[1] AS "name", '
      'COUNT(*) AS "times" '
      'FROM "basket_item" '
      'WHERE "requesterMemberId" = @member '
      'GROUP BY lower(trim("name")) '
      'HAVING COUNT(*) >= 2 '
      'ORDER BY COUNT(*) DESC, MAX("addedAt") DESC '
      'LIMIT @limit',
      parameters: QueryParameters.named({
        'member': member.id,
        'limit': (limit ?? 5).clamp(1, 12),
      }),
    );
    return [for (final row in rows) row.toColumnMap()['name'] as String];
  }

  /// Ticks an item off. Shopper only, allowed in **both** `open` and `frozen`
  /// (ADR-005) — the shopper marks things as they walk the aisles. `priceMinor`
  /// is only accepted once the basket is `frozen`, and only on a `picked`
  /// item: something that was not bought has no price.
  ///
  /// Leaving `priceMinor` out keeps the price an item already has, so tapping
  /// "Got it" again at the till does not wipe what was typed. Marking an item
  /// anything other than `picked` clears its price. `requested` is the undo.
  ///
  /// Publishes an `itemUpdated` event, so members watching see it live.
  Future<BasketItem> markItem(
    Session session,
    int itemId,
    ItemStatus status, {
    int? priceMinor,
  }) async {
    final (item, basket) = await _requireVisibleItem(session, itemId);
    await Authz.requireShopper(session, basket);
    _requireMarkable(basket);

    if (priceMinor != null) {
      if (basket.status != BasketStatus.frozen) {
        throw OpenBasketException(
          error: BasketError.basketNotFrozen,
          message: 'Prices go in once you are at the checkout.',
        );
      }
      if (status != ItemStatus.picked) {
        throw OpenBasketException(
          error: BasketError.invalidPrice,
          message: 'Only something you picked up has a price.',
        );
      }
      _requireAmount(priceMinor, allowZero: true);
    }

    final marked = await BasketItem.db.updateRow(
      session,
      item.copyWith(
        status: status,
        priceMinor: status == ItemStatus.picked
            ? priceMinor ?? item.priceMinor
            : null,
      ),
    );

    await BasketChannels.publish(
      session,
      basket.id!,
      BasketEventType.itemUpdated,
      item: marked,
    );
    await AnalyticsService.track(
      session,
      AnalyticsType.itemMarked,
      householdId: basket.householdId,
      basketId: basket.id,
      memberId: basket.shopperMemberId,
      payload: {
        'status': status.name,
        'whileOpen': basket.status == BasketStatus.open,
        'hasPrice': marked.priceMinor != null,
      },
    );
    return marked;
  }

  /// The till total, in minor units. Any difference from the item sum is split
  /// across every member at settlement (ADR-007); this only records it.
  ///
  /// Shopper only, `frozen` only. Publishes `basketUpdated` so the members
  /// watching see the same total the split will use.
  Future<Basket> setReceiptTotal(
    Session session,
    int basketId,
    int receiptTotalMinor,
  ) async {
    final basket = await _requireVisible(session, basketId);
    await Authz.requireShopper(session, basket);
    _requireFrozen(basket);
    // Zero is refused on purpose. A run where nothing was bought has no
    // receipt; recording one of zero would make every member owe a negative
    // share of the item sum.
    _requireAmount(receiptTotalMinor, allowZero: false);

    final updated = await Basket.db.updateRow(
      session,
      basket.copyWith(receiptTotalMinor: receiptTotalMinor),
    );

    await BasketChannels.publish(
      session,
      basketId,
      BasketEventType.basketUpdated,
      basket: updated,
    );
    return updated;
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
    _requireOpenBasket(basket);
    return basket;
  }

  /// An item on one of the caller's household's baskets, with that basket.
  ///
  /// An item in someone else's household must not be distinguishable from an
  /// item that never existed.
  Future<(BasketItem, Basket)> _requireVisibleItem(
    Session session,
    int itemId,
  ) async {
    final member = await Authz.requireMember(session);
    final item = await BasketItem.db.findById(session, itemId);
    final basket = item == null
        ? null
        : await Basket.db.findById(session, item.basketId);
    if (item == null ||
        basket == null ||
        basket.householdId != member.householdId) {
      throw OpenBasketException(
        error: BasketError.itemNotFound,
        message: 'That item is not on one of your baskets.',
      );
    }
    return (item, basket);
  }

  /// An item the caller asked for, in a basket that is still open, together
  /// with that basket. Update and remove both want exactly this.
  ///
  /// Rule 3 in its narrowest form: being in the household lets you add items,
  /// it does not let you edit someone else's. The shopper's own way of
  /// touching another member's item is `markItem`, which is a different
  /// verb with a different check.
  Future<(BasketItem, Basket)> _requireOwnItem(
    Session session,
    int itemId,
  ) async {
    final member = await Authz.requireMember(session);
    final (item, basket) = await _requireVisibleItem(session, itemId);
    if (item.requesterMemberId != member.id) {
      throw OpenBasketException(
        error: BasketError.notYourItem,
        message: 'Only the person who asked for it can change it.',
      );
    }
    _requireOpenBasket(basket);
    return (item, basket);
  }

  /// Marking works while the shopper walks the aisles and at the till, and
  /// stops the moment the money is split (rule 6: a settled basket is
  /// immutable).
  void _requireMarkable(Basket basket) {
    switch (basket.status) {
      case BasketStatus.open:
      case BasketStatus.frozen:
        return;
      case BasketStatus.settled:
        throw _alreadySettled();
      case BasketStatus.cancelled:
        throw OpenBasketException(
          error: BasketError.basketNotOpen,
          message: 'This basket was cancelled.',
        );
    }
  }

  void _requireFrozen(Basket basket) {
    if (basket.status == BasketStatus.settled) throw _alreadySettled();
    if (basket.status != BasketStatus.frozen) {
      throw OpenBasketException(
        error: BasketError.basketNotFrozen,
        message: 'The receipt total goes in once you are at the checkout.',
      );
    }
  }

  /// One run's money, in minor units. The ceiling is there to catch a slipped
  /// thumb — 1,000,000.00 in a two-decimal currency — not to model a budget.
  static const maxAmountMinor = 100000000;

  void _requireAmount(int minor, {required bool allowZero}) {
    if (minor < 0 || (!allowZero && minor == 0) || minor > maxAmountMinor) {
      throw OpenBasketException(
        error: BasketError.invalidPrice,
        message: 'That amount does not look right.',
      );
    }
  }

  OpenBasketException _alreadySettled() => OpenBasketException(
    error: BasketError.basketAlreadySettled,
    message: 'This basket has been settled, so it can no longer change.',
  );

  /// Rate limiting, the plan's "item spam" line. A shopping list is typed by
  /// a person: forty things from one member on one run, or more than twelve
  /// in a minute, is a stuck button or a script, and every phone in the house
  /// is receiving each of them over the stream.
  static const maxItemsPerMember = 40;
  static const maxItemsPerMinute = 12;

  Future<void> _requireRoomFor(
    Session session,
    int basketId,
    int memberId,
  ) async {
    final mine = await BasketItem.db.count(
      session,
      where: (t) =>
          t.basketId.equals(basketId) & t.requesterMemberId.equals(memberId),
    );
    final lastMinute = await BasketItem.db.count(
      session,
      where: (t) =>
          t.requesterMemberId.equals(memberId) &
          (t.addedAt > ServerClock.now().subtract(const Duration(minutes: 1))),
    );
    if (mine >= maxItemsPerMember || lastMinute >= maxItemsPerMinute) {
      throw OpenBasketException(
        error: BasketError.tooManyItems,
        message: 'That is a lot of items at once. Give it a moment.',
      );
    }
  }

  void _requireOpenBasket(Basket basket) {
    if (basket.status != BasketStatus.open) {
      throw OpenBasketException(
        error: BasketError.basketNotOpen,
        message: 'This basket has closed, so the list is final.',
      );
    }
  }

  String _requireItemName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 120) {
      throw OpenBasketException(
        error: BasketError.invalidItem,
        message: 'Give the item a name.',
      );
    }
    return trimmed;
  }

  /// The largest quantity for each unit: 99 of anything counted, 5000 of
  /// anything weighed or poured in its small unit.
  static int maxQuantity(ItemUnit unit) => switch (unit) {
    ItemUnit.g || ItemUnit.ml => 5000,
    _ => 99,
  };

  int _requireQuantity(int quantity, ItemUnit unit) {
    final max = maxQuantity(unit);
    if (quantity < 1 || quantity > max) {
      throw OpenBasketException(
        error: BasketError.invalidItem,
        message: 'Pick a quantity between 1 and $max.',
      );
    }
    return quantity;
  }

  /// Empty and whitespace-only notes become null, so the client never has to
  /// decide whether to render an empty second line.
  String? _cleanNote(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.length > 280 ? trimmed.substring(0, 280) : trimmed;
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
