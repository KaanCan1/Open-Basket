import 'package:serverpod/serverpod.dart';

import '../generated/future_calls.dart';
import '../generated/protocol.dart';
import '../util/clock.dart';
import 'analytics_service.dart';
import 'basket_channels.dart';
import 'notification_service.dart';

/// The basket lifecycle, in one place.
///
/// The endpoint decides who is allowed to do what; this decides what happens.
/// The future call and the startup sweep come in through here too, so that a
/// basket closed by the timer and a basket closed by the shopper travel the
/// same code path and cannot drift apart.
abstract final class BasketService {
  /// How long a run may be booked for. The floor keeps a zero-minute basket
  /// from closing before the notification arrives; the ceiling is there so a
  /// typo cannot pin a household's only basket slot open for a week.
  static const minDuration = Duration(minutes: 1);
  static const maxDuration = Duration(minutes: 120);

  /// ADR-009: one extension, five minutes, shopper only.
  static const extension = Duration(minutes: 5);

  /// The name the partial unique index carries in the migration. Postgres
  /// hands it back on a conflict and it is how `open` tells rule 4 apart from
  /// every other unique constraint on the table.
  static const openBasketIndexName = 'basket_one_open_per_household_idx';

  /// Identifies the scheduled close so extending can cancel and replace it.
  /// One basket, one pending close.
  static String closeIdentifier(int basketId) => 'basket-close-$basketId';

  /// The "2 minutes left" reminder that goes with each close (ADR-043).
  static String closingSoonIdentifier(int basketId) =>
      'basket-closing-soon-$basketId';

  /// The household's basket that is still going: `open`, or `frozen` and
  /// waiting for prices. A `settled` or `cancelled` one is history.
  ///
  /// Prefers the open one. A household can have one open basket and any
  /// number of frozen ones waiting to be settled — Tuesday's run should not
  /// have to wait for Monday's receipt — so when there is no open basket this
  /// answers with the most recent frozen one, which is the one the home screen
  /// shows as "at checkout". Without the ordering, which frozen basket came
  /// back was up to the database.
  static Future<Basket?> activeFor(
    Session session,
    int householdId, {
    Transaction? transaction,
  }) async {
    return await openFor(session, householdId, transaction: transaction) ??
        await Basket.db.findFirstRow(
          session,
          where: (final t) =>
              t.householdId.equals(householdId) &
              t.status.equals(BasketStatus.frozen),
          // Serverpod 4 dropped `orderDescending`; direction is on the
          // column now.
          orderBy: (final t) => t.openedAt.desc(),
          transaction: transaction,
        );
  }

  /// The household's open basket, or null. This — not [activeFor] — is what
  /// gates opening a new one.
  ///
  /// Rule 4 is one **open** basket per household, and the partial unique
  /// index enforces exactly that. The check used to count frozen baskets too,
  /// which was stricter than the rule: with settlement not yet built and
  /// cancel only allowed while open, the first run to freeze locked the
  /// household out of ever opening another. Found on the deployed server,
  /// by opening a second basket after the first closed itself.
  static Future<Basket?> openFor(
    Session session,
    int householdId, {
    Transaction? transaction,
  }) {
    return Basket.db.findFirstRow(
      session,
      where: (final t) =>
          t.householdId.equals(householdId) &
          t.status.equals(BasketStatus.open),
      transaction: transaction,
    );
  }

  /// Books the close. Replaces any close already pending for this basket, so
  /// an extended basket has exactly one future call waiting rather than two
  /// where the earlier one happens to be harmless.
  ///
  /// Never throws: a basket that opened but failed to schedule is still a
  /// basket, and the startup sweep closes it if nothing else does. Failing the
  /// shopper's `open` call over it would be the worse trade.
  static Future<void> scheduleClose(Session session, Basket basket) async {
    final id = basket.id!;
    try {
      await session.serverpod.futureCalls.cancel(closeIdentifier(id));
      await session.serverpod.futureCalls
          .callAtTime(basket.closesAt, identifier: closeIdentifier(id))
          .closeBasket
          .close(id);
    } catch (e, stackTrace) {
      session.log(
        'could not schedule the close for basket $id; the startup sweep is '
        'the fallback',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
    await _scheduleClosingSoon(session, basket);
  }

  /// A reminder that would land at or before now — a basket of two minutes
  /// or less — is not scheduled at all. Never throws, for the same reason as
  /// the close; a missing reminder costs a nudge, nothing more.
  static Future<void> _scheduleClosingSoon(
    Session session,
    Basket basket,
  ) async {
    final id = basket.id!;
    try {
      await session.serverpod.futureCalls.cancel(closingSoonIdentifier(id));
      final at = basket.closesAt.subtract(NotificationService.closingSoonLead);
      if (!at.isAfter(ServerClock.now())) return;
      await session.serverpod.futureCalls
          .callAtTime(at, identifier: closingSoonIdentifier(id))
          .closingSoon
          .remind(id);
    } catch (e, stackTrace) {
      session.log(
        'could not schedule the closing-soon reminder for basket $id',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Drops a pending close. Used when the shopper freezes or cancels early —
  /// the call would be a no-op anyway, but leaving rows behind for every
  /// basket ever opened is untidy in a table we have to read during the demo.
  static Future<void> cancelScheduledClose(
    Session session,
    int basketId,
  ) async {
    try {
      await session.serverpod.futureCalls.cancel(closeIdentifier(basketId));
      await session.serverpod.futureCalls.cancel(
        closingSoonIdentifier(basketId),
      );
    } catch (e, stackTrace) {
      session.log(
        'could not cancel the scheduled close for basket $basketId',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Rule 2: closing is idempotent.
  ///
  /// Reloads the basket and does nothing unless it is still `open` and its
  /// time has actually run out. That covers all three ways this gets called
  /// twice: a superseded future call from before an extension, a future call
  /// that fires while the shopper is tapping "At checkout", and the startup
  /// sweep running over a basket a future call is already handling.
  ///
  /// Returns the basket it closed, or null when there was nothing to do.
  static Future<Basket?> closeIfDue(Session session, int basketId) async {
    final basket = await Basket.db.findById(session, basketId);
    if (basket == null) return null;
    if (basket.status != BasketStatus.open) return null;
    if (basket.closesAt.isAfter(ServerClock.now())) return null;

    final closed = await Basket.db.updateRow(
      session,
      basket.copyWith(
        status: BasketStatus.frozen,
        frozenAt: ServerClock.now(),
        closedAutomatically: true,
      ),
    );

    // Anyone watching sees the basket lock itself, with no polling and no
    // push notification involved. This is posted from the future call's own
    // session, which is the point: nothing on anyone's phone made it happen.
    await BasketChannels.publish(
      session,
      basketId,
      BasketEventType.basketFrozen,
      basket: closed,
    );
    await AnalyticsService.track(
      session,
      AnalyticsType.basketAutoClosed,
      householdId: closed.householdId,
      basketId: closed.id,
      memberId: closed.shopperMemberId,
      payload: {
        'extendCount': closed.extendCount,
        'lateBySeconds': ServerClock.now()
            .difference(closed.closesAt)
            .inSeconds,
      },
    );
    return closed;
  }

  /// Closes every `open` basket whose time has passed.
  ///
  /// Runs once at startup, because a future call scheduled by a server that
  /// then went down is a future call nobody is waiting on. Serverpod persists
  /// them, so most survive; this is for the ones that do not, and for baskets
  /// opened during a window when scheduling itself failed.
  ///
  /// Returns how many it closed, so the boot log says something useful.
  static Future<int> sweepExpired(Session session) async {
    final overdue = await Basket.db.find(
      session,
      where: (final t) =>
          t.status.equals(BasketStatus.open) &
          (t.closesAt <= ServerClock.now()),
    );

    var closed = 0;
    for (final basket in overdue) {
      try {
        if (await closeIfDue(session, basket.id!) != null) closed++;
      } catch (e, stackTrace) {
        session.log(
          'startup sweep could not close basket ${basket.id}',
          level: LogLevel.error,
          exception: e,
          stackTrace: stackTrace,
        );
      }
    }
    return closed;
  }
}
