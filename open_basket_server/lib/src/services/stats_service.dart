import 'package:serverpod/serverpod.dart';

/// The Day 26 report's numbers, computed from the tables the app already
/// keeps rather than from `analytics_event` alone: `basket` records how each
/// run ended (`closedAutomatically`, `frozenAt`, `extendCount`), and
/// `basket_item` records who asked for what and when. The analytics events
/// stay the audit trail (rule 8); these are the source of truth.
///
/// `scripts/report.sql` runs [headlineSql] with the household filter left
/// null, across every household. `stats_test` checks the two agree, so the
/// report and the app cannot drift apart.
abstract final class StatsService {
  /// One row. Every ratio is a fraction (0.5, not 50), and every figure that
  /// needs a finished run — shares, the join rate — leaves out a basket that
  /// is still open, because its answer is not in yet.
  ///
  /// - `chosen_minutes`: what the shopper picked, before any extension.
  /// - `member_share`: per run, the members who asked for at least one thing,
  ///   over the members in the house when it opened; averaged over runs.
  /// - `others_joined_rate`: runs where someone other than the shopper added
  ///   an item, in houses of more than one. The headline: "shared attention".
  /// - `median_first_item_s` / `median_first_other_s`: seconds from open to
  ///   the first item, and to the first item from someone else.
  static const headlineSql = '''
WITH b AS (
  SELECT *
  FROM "basket"
  WHERE (@household::bigint IS NULL OR "householdId" = @household::bigint)
),
per_basket AS (
  SELECT
    b."id", b."householdId", b."status", b."closedAutomatically",
    b."frozenAt", b."extendCount",
    EXTRACT(EPOCH FROM b."closesAt" - b."openedAt") / 60.0
      - 5 * b."extendCount" AS chosen_minutes,
    (SELECT COUNT(*) FROM "basket_item" i WHERE i."basketId" = b."id")
      AS items,
    (SELECT COUNT(DISTINCT i."requesterMemberId") FROM "basket_item" i
      WHERE i."basketId" = b."id") AS askers,
    (SELECT COUNT(*) FROM "basket_item" i
      WHERE i."basketId" = b."id"
        AND i."requesterMemberId" <> b."shopperMemberId") AS others_items,
    (SELECT COUNT(*) FROM "household_member" m
      WHERE m."householdId" = b."householdId"
        AND m."joinedAt" <= b."openedAt"
        AND (m."leftAt" IS NULL OR m."leftAt" > b."openedAt")) AS members,
    (SELECT EXTRACT(EPOCH FROM MIN(i."addedAt") - b."openedAt")
      FROM "basket_item" i WHERE i."basketId" = b."id") AS first_item_s,
    (SELECT EXTRACT(EPOCH FROM MIN(i."addedAt") - b."openedAt")
      FROM "basket_item" i
      WHERE i."basketId" = b."id"
        AND i."requesterMemberId" <> b."shopperMemberId") AS first_other_s
  FROM b
)
SELECT
  COUNT(*) AS baskets,
  COUNT(DISTINCT "householdId") AS households,
  COALESCE(SUM(items), 0) AS items,
  AVG(items)::float8 AS items_per_basket,
  COUNT(*) FILTER (WHERE "closedAutomatically") AS auto_closed,
  COUNT(*) FILTER (WHERE "frozenAt" IS NOT NULL AND NOT "closedAutomatically")
    AS frozen_by_hand,
  COUNT(*) FILTER (WHERE "status" = 'cancelled') AS cancelled,
  COUNT(*) FILTER (WHERE "status" = 'open') AS still_open,
  COUNT(*) FILTER (WHERE "status" = 'settled') AS settled,
  COUNT(*) FILTER (WHERE "status" = 'frozen') AS awaiting_settlement,
  AVG(chosen_minutes)::float8 AS avg_chosen_minutes,
  AVG(CASE WHEN "extendCount" > 0 THEN 1.0 ELSE 0.0 END)::float8
    AS extension_rate,
  (AVG(askers::float8 / NULLIF(members, 0))
    FILTER (WHERE "status" <> 'open'))::float8 AS member_share,
  (AVG(CASE WHEN others_items > 0 THEN 1.0 ELSE 0.0 END)
    FILTER (WHERE "status" <> 'open' AND members > 1))::float8
    AS others_joined_rate,
  (percentile_cont(0.5) WITHIN GROUP (ORDER BY first_item_s))::float8
    AS median_first_item_s,
  (percentile_cont(0.5) WITHIN GROUP (ORDER BY first_other_s))::float8
    AS median_first_other_s
FROM per_basket''';

  /// [householdId] null means every household: the operator's report. The
  /// endpoint never passes null — a member sees their own house only.
  static Future<Map<String, num?>> headline(
    Session session, {
    int? householdId,
  }) async {
    final rows = await session.db.unsafeQuery(
      headlineSql,
      parameters: QueryParameters.named({'household': householdId}),
    );
    return {
      for (final entry in rows.single.toColumnMap().entries)
        entry.key: _plain(entry.value),
    };
  }

  /// `unsafeQuery` hands every value back as text ('4', '12.5'), and the
  /// report wants numbers. Nothing in the headline is anything but a number
  /// or null, so parse, and round the floats to what a table can print.
  static num? _plain(Object? value) {
    final number = switch (value) {
      null => null,
      final num n => n,
      _ => num.tryParse('$value'),
    };
    if (number is double) return double.parse(number.toStringAsFixed(4));
    return number;
  }
}
