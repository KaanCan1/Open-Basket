import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/authz.dart';
import '../util/clock.dart';

/// Past runs.
class HistoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// The household's finished runs, newest first. Settled and cancelled runs
  /// both appear; a run that is still open or frozen is not history yet and
  /// is `basket.getActive`'s to answer.
  ///
  /// `limit` is clamped to 1..[maxLimit]. It is nullable for the same reason
  /// as `addItem`'s quantity: a defaulted named parameter becomes a required
  /// one on the generated client.
  Future<List<PastRun>> list(Session session, {int? limit}) async {
    final member = await Authz.requireMember(session);
    final baskets = await Basket.db.find(
      session,
      where: (t) =>
          t.householdId.equals(member.householdId) &
          t.status.inSet({BasketStatus.settled, BasketStatus.cancelled}),
      // Newest by when the run started: a settled basket has no settledAt.
      // A frozen run can overlap the next one (ADR-025), so this is not
      // strictly finish order, but it is the order the house shopped in.
      orderBy: (t) => t.openedAt.desc(),
      limit: (limit ?? defaultLimit).clamp(1, maxLimit),
    );
    if (baskets.isEmpty) return const [];

    // One query for every row's items, not one per row.
    final items = await BasketItem.db.find(
      session,
      where: (t) => t.basketId.inSet({for (final b in baskets) b.id!}),
    );
    final byBasket = <int, List<BasketItem>>{};
    for (final item in items) {
      byBasket.putIfAbsent(item.basketId, () => []).add(item);
    }
    return [
      for (final basket in baskets)
        summarise(basket, byBasket[basket.id] ?? const []),
    ];
  }

  /// The numbers a history row shows. Public and static so it can be tested
  /// without a database.
  static PastRun summarise(Basket basket, List<BasketItem> items) {
    final itemsByMember = <int, int>{};
    var priced = 0;
    var unavailable = 0;
    for (final item in items) {
      itemsByMember[item.requesterMemberId] =
          (itemsByMember[item.requesterMemberId] ?? 0) + 1;
      if (item.status == ItemStatus.unavailable) unavailable++;
      if (item.status == ItemStatus.picked) priced += item.priceMinor ?? 0;
    }
    final settled = basket.status == BasketStatus.settled;
    return PastRun(
      basket: basket,
      totalMinor: settled ? basket.receiptTotalMinor ?? priced : 0,
      itemCount: items.length,
      unavailableCount: unavailable,
      itemsByMember: itemsByMember,
    );
  }

  static const defaultLimit = 20;
  static const maxLimit = 50;

  /// One past run in full: its items with who asked and what they cost, and
  /// its settlement lines if it has any. A cancelled run has neither prices
  /// nor lines. Read-only.
  ///
  /// Any member may read any of the household's runs; an unknown id and
  /// another household's answer the same `basketNotFound`, as everywhere.
  Future<BasketEvent> get(Session session, int basketId) async {
    final member = await Authz.requireMember(session);
    final basket = await Basket.db.findById(session, basketId);
    if (basket == null || basket.householdId != member.householdId) {
      throw OpenBasketException(
        error: BasketError.basketNotFound,
        message: 'That basket is not one of yours.',
      );
    }
    final items = await BasketItem.db.find(
      session,
      where: (t) => t.basketId.equals(basketId),
      orderBy: (t) => t.addedAt,
    );
    return BasketEvent(
      type: BasketEventType.snapshot,
      basket: basket,
      items: items,
      serverTime: ServerClock.now(),
    );
  }
}
