import '../generated/protocol.dart';
import '../util/money.dart';

/// Who owes whom after a run (rule 6, ADR-007). Pure: no session, no
/// database, so every rule below is a unit test away.
///
/// - The shopper paid the whole receipt.
/// - Each member owes the sum of their own `picked` items, plus an even share
///   of the gap between the receipt total and the item sum — every member,
///   including one who asked for nothing.
/// - The remainder of that division stays with the shopper, so the shopper's
///   own share plus the lines always add up to exactly what they paid.
/// - The shopper's own items create no debt; nobody owes themselves.
/// - Everything is in minor units already, so nothing is ever rounded.
abstract final class SettlementService {
  /// The lines for [items] in basket [basketId], split across [memberIds]
  /// (every member of the household, the shopper included).
  ///
  /// Items that are not `picked`, and picked items without a price, count as
  /// nothing. `settle` refuses to run until every item is one or the other;
  /// `preview` runs on a half-priced basket so the shopper can watch the
  /// numbers fill in.
  ///
  /// A [receiptTotalMinor] of null means "the receipt matched the items".
  ///
  /// A member whose total is zero gets no line. A member whose total comes
  /// out negative — a receipt discount bigger than their items — is owed
  /// money instead, so their line runs from the shopper to them with every
  /// figure negated, and `amountMinor` is always positive.
  static List<SettlementLine> compute({
    required int basketId,
    required int shopperMemberId,
    required List<int> memberIds,
    required List<BasketItem> items,
    int? receiptTotalMinor,
  }) {
    final members = memberIds.toSet();
    if (!members.contains(shopperMemberId)) {
      throw ArgumentError.value(
        shopperMemberId,
        'shopperMemberId',
        'The shopper has to be one of the members the gap is split across.',
      );
    }

    final itemsByMember = <int, int>{for (final id in members) id: 0};
    var itemSum = 0;
    for (final item in items) {
      final price = item.priceMinor;
      if (item.status != ItemStatus.picked || price == null) continue;
      itemSum += price;
      // A requester who is no longer in the household has nobody left to owe
      // it. It stays in the item sum, so the gap is not inflated by it, and
      // the shopper simply carries it.
      if (itemsByMember.containsKey(item.requesterMemberId)) {
        itemsByMember[item.requesterMemberId] =
            itemsByMember[item.requesterMemberId]! + price;
      }
    }

    final gap = (receiptTotalMinor ?? itemSum) - itemSum;
    final order = members.toList();
    final shares = Money.splitEvenly(
      gap,
      order.length,
      remainderIndex: order.indexOf(shopperMemberId),
    );

    final lines = <SettlementLine>[];
    for (var i = 0; i < order.length; i++) {
      final memberId = order[i];
      if (memberId == shopperMemberId) continue;
      final own = itemsByMember[memberId]!;
      final share = shares[i];
      final amount = own + share;
      if (amount == 0) continue;
      final owesShopper = amount > 0;
      lines.add(
        SettlementLine(
          basketId: basketId,
          fromMemberId: owesShopper ? memberId : shopperMemberId,
          toMemberId: owesShopper ? shopperMemberId : memberId,
          amountMinor: owesShopper ? amount : -amount,
          itemsMinor: owesShopper ? own : -own,
          receiptGapMinor: owesShopper ? share : -share,
        ),
      );
    }
    return lines;
  }
}
