import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Event names. Strings rather than an enum because the Day 26 report reads
/// them straight out of SQL, and because a typo in one place should not stop a
/// basket from opening.
abstract final class AnalyticsType {
  static const basketOpened = 'basket_opened';
  static const itemAdded = 'item_added';
  static const itemMarked = 'item_marked';
  static const basketExtended = 'basket_extended';
  static const basketFrozen = 'basket_frozen';
  static const basketAutoClosed = 'basket_auto_closed';
  static const basketSettled = 'basket_settled';
  static const basketCancelled = 'basket_cancelled';
  static const householdCreated = 'household_created';
  static const memberJoined = 'member_joined';
}

/// Writes the events the Day 26 report is built from.
///
/// This exists from Day 2 on purpose: a metric added in week three has no
/// history behind it, and the report is the deliverable. Call it from every
/// endpoint that changes something, not from the client — a client can lie, and
/// a client that crashed never reports at all.
abstract final class AnalyticsService {
  /// Never throws. An analytics write must not be able to fail a basket: if
  /// the insert goes wrong we log it and carry on, because losing one row is a
  /// far smaller problem than losing the shopper's run.
  static Future<void> track(
    Session session,
    String type, {
    int? householdId,
    int? basketId,
    int? memberId,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await AnalyticsEvent.db.insertRow(
        session,
        AnalyticsEvent(
          type: type,
          householdId: householdId,
          basketId: basketId,
          memberId: memberId,
          payload: payload == null ? null : jsonEncode(payload),
        ),
      );
    } catch (e, stackTrace) {
      session.log(
        'analytics write failed for "$type"',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }
}
