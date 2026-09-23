# Project context

A one-page briefing for a fresh session or an outside model. `CLAUDE.md` holds the rules we work
by and `PLAN.md` the day-by-day tasks; this file is the short version of both plus where we are.

Keep the status section current — it is the first thing a cold session reads.

## Product

A live, time-boxed shared shopping basket for families and housemates. The shopper opens a basket
and sets a duration ("checkout in 8 minutes"). Everyone in the household gets a push notification
and adds items; items appear instantly on all devices. When the timer expires the basket closes
**on the server**, so it works even if the app was killed. At the till the basket freezes, the
shopper marks items picked or unavailable and enters prices, and the server computes who owes whom.

The only thing shared is the remaining time. Live location never reaches the server.

## Team and timeline

Two people, 29 days. Day 1 = 2026-09-15, Day 29 = 2026-10-13. Hackathon submission.
A (Kaan) is backend and Serverpod; B (Yeşim) is Flutter and UX. Each works through a separate
Claude Code session, so **the repository is the only channel between them** — decisions have to be
committed, not chatted.

Repo: https://github.com/KaanCan1/Open-Basket (public)

## Stack, pinned

- Serverpod 4.0.0 (Dart backend), PostgreSQL 16, Redis optional (only needed for multiple instances)
- Flutter 3.47.4 / Dart 3.13.3 — Serverpod 4 requires Dart >= 3.10.3, which is why the floor is this high
- Riverpod, go_router, firebase_messaging (FCM HTTP v1, sent from the server), geolocator, intl
- Local development uses Serverpod's **embedded PostgreSQL** (`dataPath` in `config/development.yaml`),
  so neither developer needs Docker. `docker-compose.yaml` stays for CI and production.

## Hard rules

1. The server owns time. `closesAt` lives server-side; the client renders `closesAt - serverNow`.
2. Auto-close is idempotent: the future call reloads the basket and does nothing if `status != open`.
   Extending schedules a new future call. Server startup sweeps expired open baskets.
3. Every endpoint checks authorization. Extend, freeze, price entry and settle are shopper-only.
4. At most one open basket per household, enforced in a DB transaction.
5. Money is `int` in minor units. No `double`. Currency is an ISO 4217 code on the household, default `TRY`, with a minor-unit count per currency (2 for TRY/USD, 0 for JPY).
6. Settlement is computed on the server: own picked items plus an even share of the receipt gap, every member included, remainder to the shopper. Settled baskets and their `SettlementLine` rows are immutable.
7. Location is read once, on the shopper's phone only, to suggest an ETA. The server receives only
   the store and a number of minutes. Never logged.
8. Every key event is written to `analytics_event` — the final report depends on it.
9. Never hand-edit `open_basket_client` or `*.g.dart`. Run `serverpod generate` / `create-migration`.
10. No passwords: sign-in is a six-digit emailed code (10-min expiry, 3 attempts).
11. Everything in English: UI, notifications, errors, code, commits, docs. No hardcoded UI strings;
    everything goes through `app_en.arb` so Turkish can be added later without refactoring.

## State machine

```
open ──(timer expires / shopper taps "At checkout")──> frozen ──(prices entered, settle)──> settled
  └──(shopper cancels)──> cancelled
```

## Data model

```
Household(name, currencyCode, createdAt)
HouseholdMember(householdId, userId, displayName, role, joinedAt, 3 notification prefs)
                                                                   unique: householdId + userId
Household.code is permanent and owner-rotatable — there is no invite row with a TTL
Store(householdId, name, lat, lng)
Basket(householdId, shopperMemberId, storeId?, status, openedAt, closesAt, frozenAt?,
       closedAutomatically, extendCount, receiptTotalMinor?)
BasketItem(basketId, requesterMemberId, name, quantity, note?, status, priceMinor?, addedAt)
BasketEvent  -- stream only, no table: snapshot | itemAdded | itemUpdated | itemRemoved |
                timerExtended | basketFrozen | basketSettled | basketCancelled
SettlementLine(basketId, fromMemberId, toMemberId, amountMinor)
DeviceToken(...)
AnalyticsEvent(type, householdId?, basketId?, memberId?, payload /* JSON */, createdAt)
```

## Milestones

| | Day | Definition |
|---|---|---|
| M0 | 2 | Monorepo and CI green |
| M1 | 6 | Auth, create household, join with invite code |
| M2 | 10 | Live basket + auto-close + deploy — **real household usage starts** |
| M3 | 16 | Freeze, price entry, push notifications |
| M4 | 21 | Settlement, ETA suggestion, history, resilience |
| M5 | 25 | Code freeze |
| M6 | 29 | Report, demo video, README, submission |

The pitch promised six weeks of home usage but there are 29 days, so the Day 10 deploy is what
buys roughly 18 days of real data — and the report says that honestly. `analytics_event` has to
exist from Day 2, because a metric added later is data already lost. End-to-end flow first,
polish second.

## Status — 2026-09-23 (calendar Day 9) — plan Days 1-25 done, deployed

The plan ran ahead of the calendar: everything through the Day 24-25 code freeze is merged and
live on Serverpod Cloud. B has still not committed; A wrote every screen (ADR-012, ADR-020).

What works, walked on simulators and deployed:

- **Sign-in** by a six-digit emailed code, no passwords (ADR-004). Judges can sign in on
  production: Serverpod Cloud delivers the email.
- **Households**: create, join by code, rotate it, rename, currency (TRY/EUR/GBP/USD/CHF/JPY),
  leave. Leaving marks the member, it never deletes history (ADR-036).
- **The whole run**: open a basket for N minutes at a store, with a duration suggested from a
  one-off location read (ADR-034); everyone adds items over the stream; the basket **closes
  itself on the server** (future call, verified on Cloud with the app backgrounded); the shopper
  marks items and enters prices; the server settles who owes whom (ADR-028/029/030).
- **History** of every settled or cancelled run, and each run in full (ADR-035).
- **Resilience**: offline adds queue and flush on reconnect; resync on resume (ADR-032).
- **Polish**: usual-item chips, rate limits, arrival animation, last-minute haptic (ADR-038);
  every server refusal worded by the app, not the server (ADR-039).
- **Names**: people set their own in Settings; the default is a guess from the email (ADR-041).
- **Report tooling**: `stats.report` for your own house, `scripts/report.sql` for all (ADR-040);
  `docs/REPORT.md` drafted with empty tables until real use.
- **Submission docs**: README with the Serverpod table and a diagram, `docs/TESTING.md` for the
  shipped flow, `docs/DEMO_SCRIPT.md`, seven screenshots in `docs/screenshots`.
- A release APK from `main` is verified against production; not published yet.
- Checked on an iPhone SE-sized frame in dark mode (ADR-039). Installed on Kaan's iPhone by
  cable; the free provisioning profile expires 2026-09-29 22:05 Turkey time.

Tests: 210 server, 61 Flutter, CI on every PR to `main`.

Open:

- **Push notifications: the server half is built** (ADR-043) and off until a Firebase service account is set; the app half is not built (Days 11-12). A free Apple account cannot push to an
  iPhone; the decision — a paid developer account, or Android-only push — is Kaan's.
- **Real household use has not started**, and the report (Day 26) depends on it.
- A refresh of the session token takes 3-4 s on Cloud (Serverpod feedback finding 8); access
  tokens now last an hour so it happens once a run at most.
- Rule 4's partial index makes the local dev server exit silently; `scripts/dev_db_unblock.sh`
  (ADR-037).
- Deploys run from a space-free clone: the Cloud CLI cannot handle `Open Basket` (ADR-024).
- The web build is only a no-install trial; **the product is the phone app**. Its Return key
  "not submitting" under browser automation is a synthetic-event artefact, not a bug.
- Branch protection on `main` is not enabled.
- The Claude simulator panel only offers devices the user has granted.

## Next

M5 is reached: no new features. What is left is the submission:

1. Day 26 — `stats_endpoint.dart`, `scripts/report.sql`, `docs/REPORT.md` from real use.
2. Day 27 — the demo script and a video **under two minutes**.
3. Day 28 — `README.md`, screenshots.
4. Day 29 — submit by **2026-10-14 23:59 CEST**, with the AI-use disclosure.
5. The two side prizes: Most Valuable Feedback (nine findings in `docs/SUBMISSION.md`) and Best
   Hackathon Post, both due the same day.
