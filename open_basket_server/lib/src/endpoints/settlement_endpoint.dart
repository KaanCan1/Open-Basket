import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/analytics_service.dart';
import '../services/authz.dart';
import '../services/basket_channels.dart';
import '../services/settlement_service.dart';

/// Working out who owes whom. The arithmetic lives in
/// `services/settlement_service.dart` as a pure function so it can be tested
/// without a database.
class SettlementEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// What settling would produce, without writing anything. Lets the checkout
  /// screen show the split before the shopper commits.
  ///
  /// Any member may ask. Runs on a half-priced basket too — unpriced items
  /// count as nothing — so the numbers fill in as the shopper types. On a
  /// basket that is already settled it answers the stored lines, which is the
  /// only answer that can never disagree with `get`.
  Future<List<SettlementLine>> preview(Session session, int basketId) async {
    final basket = await _requireVisible(session, basketId);
    if (basket.status == BasketStatus.settled) {
      return _storedLines(session, basketId);
    }
    _requireFrozen(basket);
    return _compute(session, basket);
  }

  /// Writes the lines and moves the basket to `settled`. Shopper only.
  ///
  /// Each member owes their own picked items plus an even share of the gap
  /// between the receipt total and the item sum — every member, including one
  /// who asked for nothing. The remainder goes to the shopper so the lines
  /// always sum to exactly what they paid (ADR-007).
  ///
  /// Throws `basketNotFrozen` too early, `basketNotFullyPriced` while any item
  /// is neither priced nor marked not available, and `basketAlreadySettled`
  /// twice: the result is immutable.
  Future<List<SettlementLine>> settle(Session session, int basketId) async {
    final basket = await _requireVisible(session, basketId);
    await Authz.requireShopper(session, basket);
    if (basket.status == BasketStatus.settled) throw _alreadySettled();
    _requireFrozen(basket);

    final items = await _items(session, basketId);
    final unfinished = items.where(
      (i) =>
          i.status == ItemStatus.requested ||
          (i.status == ItemStatus.picked && i.priceMinor == null),
    );
    if (unfinished.isNotEmpty) {
      throw OpenBasketException(
        error: BasketError.basketNotFullyPriced,
        message:
            'Price everything you got, or mark it not available, before '
            'working out who owes what.',
      );
    }

    final lines = await _compute(session, basket, items: items);

    final saved = await session.db.transaction((transaction) async {
      // The status check and the write are one statement, so two taps on
      // "Work out who owes what" cannot both get through and write the lines
      // twice. Whichever loses sees zero rows and gets basketAlreadySettled.
      final moved = await session.db.unsafeExecute(
        'UPDATE "basket" SET "status" = @settled '
        'WHERE "id" = @id AND "status" = @frozen',
        parameters: QueryParameters.named({
          'id': basketId,
          'settled': BasketStatus.settled.name,
          'frozen': BasketStatus.frozen.name,
        }),
        transaction: transaction,
      );
      if (moved == 0) throw _alreadySettled();
      if (lines.isEmpty) return <SettlementLine>[];
      return SettlementLine.db.insert(
        session,
        lines,
        transaction: transaction,
      );
    });

    final settled = basket.copyWith(status: BasketStatus.settled);
    await BasketChannels.publish(
      session,
      basketId,
      BasketEventType.basketSettled,
      basket: settled,
    );
    await AnalyticsService.track(
      session,
      AnalyticsType.basketSettled,
      householdId: basket.householdId,
      basketId: basketId,
      memberId: basket.shopperMemberId,
      payload: {
        'lines': saved.length,
        'items': items.length,
        'hasReceiptTotal': basket.receiptTotalMinor != null,
      },
    );
    return saved;
  }

  /// The stored lines for a settled basket, and an empty list for any other.
  /// Any member may read them.
  Future<List<SettlementLine>> get(Session session, int basketId) async {
    await _requireVisible(session, basketId);
    return _storedLines(session, basketId);
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  Future<List<SettlementLine>> _compute(
    Session session,
    Basket basket, {
    List<BasketItem>? items,
  }) async {
    // Everyone in the household now, the shopper included (ADR-007): the gap
    // is split across members, not across the people who asked for things.
    final members = await HouseholdMember.db.find(
      session,
      // Former members are not split across: they have left the household
      // (ADR-036). Their items still count, and land on the shopper.
      where: (t) =>
          t.householdId.equals(basket.householdId) & t.leftAt.equals(null),
      orderBy: (t) => t.id,
    );
    return SettlementService.compute(
      basketId: basket.id!,
      shopperMemberId: basket.shopperMemberId,
      memberIds: [for (final m in members) m.id!],
      items: items ?? await _items(session, basket.id!),
      receiptTotalMinor: basket.receiptTotalMinor,
    );
  }

  Future<List<BasketItem>> _items(Session session, int basketId) =>
      BasketItem.db.find(session, where: (t) => t.basketId.equals(basketId));

  Future<List<SettlementLine>> _storedLines(Session session, int basketId) =>
      SettlementLine.db.find(
        session,
        where: (t) => t.basketId.equals(basketId),
        orderBy: (t) => t.id,
      );

  /// Same rule as the basket endpoint: an unknown id and another household's
  /// id answer the same, so the error is not an oracle.
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

  void _requireFrozen(Basket basket) {
    if (basket.status != BasketStatus.frozen) {
      throw OpenBasketException(
        error: BasketError.basketNotFrozen,
        message: 'Who owes what is worked out at the checkout.',
      );
    }
  }

  OpenBasketException _alreadySettled() => OpenBasketException(
    error: BasketError.basketAlreadySettled,
    message: 'This basket has already been settled.',
  );
}
