import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../util/clock.dart';
import 'notification_copy.dart';
import 'push_sender.dart';

/// Who is told what, and when (plan, Days 11-12; ADR-043).
///
/// Every decision about recipients is made here, on the server, including
/// each member's own switches (ADR-010): a phone that turned something off is
/// never sent it, rather than sent it and asked to hide it.
///
/// Never throws. A push is a courtesy on top of something that already
/// happened — the basket opened, the lines were written — and a Firebase
/// outage must not turn that into an error for the shopper.
abstract final class NotificationService {
  /// How long before the close "2 minutes left" goes out.
  static const closingSoonLead = Duration(minutes: 2);

  /// A reminder that fires this much later than planned still goes out; any
  /// later and the basket has been extended since it was scheduled, and the
  /// rescheduled one will do the job.
  static const _closingSoonSlack = Duration(seconds: 30);

  /// Everyone in the house but the shopper, if they want to hear about it.
  static Future<void> basketOpened(Session session, Basket basket) async {
    await _guard(session, 'basket_opened', basket.id!, () async {
      final members = await _activeMembers(session, basket.householdId);
      final shopper = _byId(members, basket.shopperMemberId);
      final store = basket.storeId == null
          ? null
          : await Store.db.findById(session, basket.storeId!);
      final message = NotificationCopy.basketOpened(
        household: await _householdName(session, basket.householdId),
        shopper: shopper?.displayName ?? '',
        store: store?.name,
        minutes: basket.closesAt.difference(basket.openedAt).inMinutes,
        basketId: basket.id!,
      );
      await _deliver(session, {
        for (final m in members)
          if (m.id != basket.shopperMemberId && m.notifyBasketOpened)
            m: message,
      });
    });
  }

  /// Fired by `ClosingSoonFutureCall`. Idempotent in the way closing is
  /// (rule 2): reloads the basket and does nothing unless it is still open
  /// and genuinely about two minutes from closing. Tells only the members who
  /// have not added anything yet — the ones the nudge is for.
  ///
  /// Returns whether it sent the reminder, for tests.
  static Future<bool> closingSoon(Session session, int basketId) async {
    var sent = false;
    await _guard(session, 'closing_soon', basketId, () async {
      final basket = await Basket.db.findById(session, basketId);
      if (basket == null || basket.status != BasketStatus.open) return;
      final left = basket.closesAt.difference(ServerClock.now());
      if (left <= Duration.zero || left > closingSoonLead + _closingSoonSlack) {
        return;
      }

      final members = await _activeMembers(session, basket.householdId);
      final items = await BasketItem.db.find(
        session,
        where: (t) => t.basketId.equals(basketId),
      );
      final asked = {for (final item in items) item.requesterMemberId};
      final message = NotificationCopy.closingSoon(
        household: await _householdName(session, basket.householdId),
        basketId: basketId,
      );
      await _deliver(session, {
        for (final m in members)
          if (m.id != basket.shopperMemberId &&
              m.notifyClosingSoon &&
              !asked.contains(m.id))
            m: message,
      });
      sent = true;
    });
    return sent;
  }

  /// Each member who owes something, told how much and to whom.
  static Future<void> settlementReady(
    Session session,
    Basket basket,
    List<SettlementLine> lines,
  ) async {
    if (lines.isEmpty) return;
    await _guard(session, 'settlement_ready', basket.id!, () async {
      // Everyone on a line, including anyone who has left since: they were
      // in the house for this run and still owe what it says.
      final members = await HouseholdMember.db.find(
        session,
        where: (t) => t.householdId.equals(basket.householdId),
      );
      final household = await _householdName(session, basket.householdId);
      await _deliver(session, {
        for (final line in lines)
          if (_byId(members, line.fromMemberId) case final debtor?)
            if (debtor.leftAt == null && debtor.notifySettlementReady)
              debtor: NotificationCopy.settlementReady(
                household: household,
                shopper: _byId(members, line.toMemberId)?.displayName ?? '',
                amountMinor: line.amountMinor,
                currencyCode: basket.currencyCode,
                basketId: basket.id!,
              ),
      });
    });
  }

  // ---------------------------------------------------------------- helpers

  static Future<void> _deliver(
    Session session,
    Map<HouseholdMember, PushMessage> messages,
  ) async {
    if (messages.isEmpty) return;
    final byUser = {for (final m in messages.keys) m.userId: messages[m]!};
    final tokens = await DeviceToken.db.find(
      session,
      where: (t) => t.userId.inSet(byUser.keys.toSet()),
    );
    if (tokens.isEmpty) return;

    final sender = PushSenders.forSession(session);
    final outcomes = await Future.wait([
      for (final token in tokens)
        sender.send(session, token.token, byUser[token.userId]!),
    ]);

    final gone = [
      for (var i = 0; i < tokens.length; i++)
        if (outcomes[i] == PushOutcome.tokenGone) tokens[i],
    ];
    if (gone.isNotEmpty) await DeviceToken.db.delete(session, gone);
  }

  static Future<void> _guard(
    Session session,
    String type,
    int basketId,
    Future<void> Function() work,
  ) async {
    try {
      await work();
    } catch (e, stackTrace) {
      session.log(
        'could not send $type for basket $basketId',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<List<HouseholdMember>> _activeMembers(
    Session session,
    int householdId,
  ) => HouseholdMember.db.find(
    session,
    where: (t) => t.householdId.equals(householdId) & t.leftAt.equals(null),
  );

  static HouseholdMember? _byId(List<HouseholdMember> members, int id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  static Future<String> _householdName(Session session, int id) async =>
      (await Household.db.findById(session, id))?.name ?? 'Open Basket';
}
