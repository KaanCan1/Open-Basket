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

## Status — Day 10, 2026-09-22 — **deployed**

Backend, Days 1-6, all merged:

- Serverpod 4 workspace; 14 models; migrations applied. `main` holds 96 server tests and 27
  Flutter tests, all green.
- **Sign-in** (ADR-004): six digits by email, no passwords. The bundled provider is password-only,
  so the flow is ours — `SignInService` for the policy, `SignInCodePolicy` for the hashing and
  normalisation, `SignInEmailSender` for delivery (console in development).
- **Households**: create, join by code, rotate the code, members, rename, currency, per-member
  notification preferences, leave. An owner who leaves hands the household to the longest-standing
  member. A non-member cannot read another household — tested.
- Services in place: `Authz`, `AnalyticsService`, `Money.splitEvenly` (ADR-007's arithmetic,
  property-tested), `HouseholdCode`.

Flutter, the skeleton A built for B (ADR-012):

- Riverpod, go_router, l10n, the design tokens as a real theme, the client behind a provider.
- Screens 01-03 wired to the real endpoints, **verified end to end against a running server** by
  an `integration_test` suite that found two bugs a screenshot could not: the session token was
  never adopted after a correct code, and both auth screens overflowed.

Design: finished. 30 screens, light and dark, every contrast ratio measured and verified.

Basket lifecycle, Day 8:

- `BasketEndpoint`: `open`, `extend`, `freeze`, `cancel`, `getActive`, `getServerTime`. Every one
  checks authorization; extend, freeze and cancel are shopper-only. An unknown basket id and
  another household's basket id give the same error, so nothing can be enumerated.
- **Rule 4 is enforced by a partial unique index** written by hand into the migration (ADR-013),
  not by the transaction check alone. A real two-caller race is tested, and so is the index itself
  — including the constraint name `open` matches on to turn a violation back into a friendly error.
- **`CloseBasketFutureCall` closes a basket on the server**, whether or not any phone is awake.
  Idempotent (rule 2), plus a startup sweep in `server.dart` for calls lost to a restart.
- `ServerClock` over `package:clock` (ADR-014), so "a five minute basket closes on time" is a test
  that runs in milliseconds rather than five minutes.

The live basket, Day 9:

- `BasketStreamEndpoint.watch(basketId)` — a WebSocket whose first event is always a full
  snapshot, so a reconnect resyncs from the stream itself and never needs a second call
  (ADR-016). The stream ends itself once the basket is `settled` or `cancelled` (ADR-017).
- `addItem` / `updateItem` / `removeItem`. Anyone in the household may add while the basket
  is open; only the person who asked for an item may change or remove it.
- Every mutation publishes to `basket:<id>`, including the **future call's own auto-close** —
  the house watches the basket lock itself with nothing running on any phone.
- Publishing is best-effort and never fails the action behind it (ADR-018). Delivery is
  local to one server process until Redis is enabled.

**Submission rules read on Day 9** (`docs/SUBMISSION.md`): the deadline is 2026-10-14 23:59
CEST with no extensions, the demo video must be under **two** minutes rather than the three
the BuilderBase page shows, AI-tool use must be disclosed in the description, and judges
must be able to run the app free of charge until 2026-10-20 17:00.

The app, Day 10 (A is writing the screens; B has still not committed — ADR-020):

- **The core loop runs end to end on a phone.** Sign in, create or join a household, open a
  basket for a chosen duration, add items, watch them arrive over the stream, extend once,
  check out. Walked on the simulator, not inferred from tests.
- `ServerClock` corrects for device clock drift from the stream's own `serverTime`, and the
  countdown is always recomputed rather than decremented locally (ADR-021).
- A basket that is not open shows no countdown at all, because a ticking number under the
  word FROZEN reads as "still counting" (ADR-022).
- Items are not applied optimistically: a row appears when the stream echoes it back
  (ADR-023).

Deployed (ADR-024):

- Serverpod Cloud, project `open-basket`, starter plan. API at
  `https://open-basket.api.serverpod.space/`, web at `https://open-basket.serverpod.space/`.
- **Judges can sign in.** Serverpod Cloud manages `scloudAuthEmailKey`, so the six-digit
  code goes out as a real email — the single biggest submission risk, now closed.
- Every auth password is platform-managed; none is set by hand or stored anywhere.
- The CLI cannot deploy from a path with a space in it, so deploys run from a clone at a
  space-free path until the checkout is renamed. Deploy from `main`, after merging, so
  what is live is what is on `main`.

Verified on production, 2026-09-22, on the iOS simulator:

- The emailed code arrives and signs in.
- **A basket closes itself on Serverpod Cloud** with the app in the background — twice. The
  pod had not restarted, so it was the future call and not the startup sweep.
- The stream works through Cloud's ingress: an added item comes back over the WebSocket.
- Not yet on production: two clients watching one basket (covered by `basket_stream_test`).

That walk found three bugs, all fixed and deployed: a frozen basket locked the household out
of ever opening another (ADR-025), the home screen went stale after a freeze, and a server
slower than two seconds left the app on a permanent white screen (ADR-026).

Open:

- ~~Return in the web build's email field does not send a code~~ — **not a bug.** The
  browser automation used for testing delivers Enter as a trusted keydown with `keyCode: 0`,
  and Flutter web submits on `keyCode == 13`, which every real keyboard sends. A synthetic
  event with keyCode 13 submits normally. Recorded so nobody chases it again.
- The web build is a secondary, no-install way to try the app; **the product is the phone
  app** (decided 2026-09-22).
- Branch protection on `main` still not enabled.
- Day 7 (stores) not started. Not on the critical path — a basket can open without a store — but
  the ETA suggestion depends on it.
- **Everything B owns past the skeleton is unstarted**, and B has not worked on the repo yet.
- Marking items, prices and settlement are not built, so the run ends at "At checkout".
- Push notifications are not built, so "everyone is told" is currently only true for
  whoever has the app open.
- The Claude simulator panel only offers iOS 26.5 devices; anything booted on iOS 27 is invisible
  to it. The app runs on the iPhone 17 it can see.

## Next

**Day 10 is the critical path, and it is now entirely client-side plus a deploy.** Both halves of
what justifies Serverpod are built and tested on the server: a basket that closes itself, and a
stream that puts an item on every phone at once. Neither is reachable from the app.

The official judging puts 30% on "does it work — the core flow completes, nothing critical is
faked", and it is also the tie-breaker. That argues for finishing the one loop end to end —
open, add, watch it close, settle — over starting anything new.

`CLAUDE.md` calls Days 8-10 pair work for a reason: `basket_stream_endpoint` and
`live_basket_controller` share event types, snapshot ordering and reconnect behaviour.

Day 10 is M2 — deploy plus real usage in both homes — and it buys the ~18 days of data the report
rests on. It is the one date that cannot slip.
