-- The Day 26 report, across every household (ADR-040).
--
-- Run against the production database by the operator:
--   serverpod cloud db connection -p open-basket   # host, port, database
--   serverpod cloud db user ...                    # a temporary user
--   psql "<connection string>" -f scripts/report.sql
-- Delete the temporary user afterwards, and never commit its password.
-- The app's `stats.report` endpoint runs the first query for the caller's
-- household only. stats_test checks the first query here is the same text as
-- StatsService.headlineSql with the filter left NULL, and that every query in
-- this file runs, so edit the Dart constant and copy it here, never one alone.
--
-- Our own check households (judge-smoke, apk-check, ...) are in production
-- too. Query 2 lists every household so they can be told apart; leave them
-- out of docs/REPORT.md by hand, and never publish a household's name.

-- 1. Headline: every metric the report leads with. Meanings on
--    StatsService.headlineSql.
WITH b AS (
  SELECT *
  FROM "basket"
  WHERE (NULL::bigint IS NULL OR "householdId" = NULL::bigint)
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
FROM per_basket;

-- 2. Per household: who is actually using it.
SELECT
  h."id",
  h."name",
  (SELECT COUNT(*) FROM "household_member" m
    WHERE m."householdId" = h."id" AND m."leftAt" IS NULL) AS members_now,
  COUNT(b."id") AS baskets,
  COUNT(b."id") FILTER (WHERE b."status" = 'settled') AS settled,
  (SELECT COUNT(*) FROM "basket_item" i
    JOIN "basket" b2 ON b2."id" = i."basketId"
    WHERE b2."householdId" = h."id") AS items,
  MIN(b."openedAt") AS first_basket,
  MAX(b."openedAt") AS last_basket
FROM "household" h
LEFT JOIN "basket" b ON b."householdId" = h."id"
GROUP BY h."id", h."name"
ORDER BY baskets DESC, h."id";

-- 3. What durations people pick, before any extension.
SELECT
  ROUND(EXTRACT(EPOCH FROM "closesAt" - "openedAt") / 60.0
    - 5 * "extendCount") AS chosen_minutes,
  COUNT(*) AS baskets
FROM "basket"
GROUP BY 1
ORDER BY 1;

-- 4. Baskets per day, to show use over the weeks rather than one burst.
SELECT
  date_trunc('day', "openedAt")::date AS day,
  COUNT(*) AS baskets,
  COUNT(*) FILTER (WHERE "status" = 'settled') AS settled
FROM "basket"
GROUP BY 1
ORDER BY 1;

-- 5. Money through settled runs, per currency (minor units; never summed
--    across currencies, rule 5).
SELECT
  b."currencyCode",
  COUNT(*) AS settled_runs,
  SUM(b."receiptTotalMinor") AS receipts_minor,
  SUM((SELECT COUNT(*) FROM "settlement_line" s
    WHERE s."basketId" = b."id")) AS settlement_lines,
  SUM((SELECT COALESCE(SUM(s."amountMinor"), 0) FROM "settlement_line" s
    WHERE s."basketId" = b."id")) AS owed_minor
FROM "basket" b
WHERE b."status" = 'settled'
GROUP BY b."currencyCode"
ORDER BY settled_runs DESC;

-- 6. The analytics trail (rule 8), as a cross-check on the tables above.
SELECT "type", COUNT(*) AS events, MIN("createdAt") AS first, MAX("createdAt") AS last
FROM "analytics_event"
GROUP BY "type"
ORDER BY events DESC;
