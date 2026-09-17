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

## Status — Day 3, 2026-09-17

Done:

- Serverpod 4 monorepo scaffolded and flattened to the repo root as a Dart workspace
  (`open_basket_server`, `open_basket_client`, `open_basket_flutter`).
- Server runs on `localhost:8080` against the embedded Postgres, migrations applied.
- CI green: Analyze, Format, Tests. The template workflows needed a PATH fix — Dart 3.13's
  `dart install` writes to `~/.local/state/Dart/install/bin`, not `~/.pub-cache/bin`.
- `CLAUDE.md` carries the pinned toolchain and the ownership table: A owns server, generated
  client and migrations; B owns the Flutter app and `app_en.arb`; `.spy.yaml` and the docs are shared.
- `docs/ARCHITECTURE.md`: ADR-001 server owns time, ADR-002 client-side ETA, ADR-003 embedded
  Postgres for local development.
- `docs/brand/` holds the monochrome logo pack and the derived transparent and inverted variants.
- **Day 2 is done and merged**: 14 models, 9 endpoint signatures with `UnimplementedError` bodies,
  one migration applied. The generated client compiles, so B can build screens against typed calls.
  Rule 4 is not enforced yet — it needs a partial unique index added by hand on Day 8.
- `docs/DESIGN_BRIEF.md` holds the design prompt. The screen set is finished (v3, 21 screens,
  light and dark): near-monochrome on paper with a single lime signal used only as a fill, the
  brand mark integrated, and every colour pair measured — all seven published contrast ratios
  verified against WCAG AA. The addendum added the states that prove the product's central claim:
  arriving into a basket that closed itself, a household that already has one open, the stream
  reconnecting with an item queued on the phone, a rotated code, and past runs in detail.
- **The design set is the specification for product behaviour.** Where it overruled the original
  plan, `docs/ARCHITECTURE.md` ADR-004 to ADR-011 record the change and `PLAN.md` has been
  rewritten to match: emailed sign-in codes instead of passwords, marking items while the basket
  is still open, a permanent rotatable household code, the receipt gap split across every member,
  currency as a household field, one +5 min extension, per-member notification preferences, and
  offline item queueing.

Open:

- Branch protection on `main` is not enabled yet.
- Nothing in the design is outstanding: the addendum landed, so the set is 30 screens and carries
  a state inventory naming every condition it draws.
- The Flutter Day 1 tasks (Riverpod, go_router, FCM and geolocator packages, `l10n.yaml`,
  `app_en.arb`, client provider, router, screen skeletons) have not started — they are B's.
- Launcher icons are not wired up; the master is `docs/brand/open-basket-app-icon-1024.png`
  and `PLAN.md` schedules it for Day 22.

## Next

Day 2, contract first and done jointly in one session: write every `.spy.yaml` model and every
endpoint signature with `UnimplementedError` bodies, run `serverpod generate`, merge to `main`.
After that both developers work in parallel against a typed, compiling client instead of B waiting
on endpoints.
