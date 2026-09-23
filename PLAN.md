# PLAN.md: Open Basket, 29-day build plan

**Team:** 2 people
- **A (Backend):** Serverpod, models, endpoints, future calls, push, deploy, report
- **B (Flutter):** screens, live basket, countdown, FCM client, UX, localization, demo video

Day 1 = Tue, 15 September 2026; Day 29 = Tue, 13 October 2026. If dates slip, follow the day numbers.

## Core strategy

The pitch says "we'll use it in our own homes for six weeks", but we have 29 days. So:

- **By Day 10 a usable build must be on both households' phones.** That gives about 18 days of real usage data. State this honestly in the report and the pitch.
- **The analytics table exists from Day 2.** A metric added later is data lost.
- End-to-end flow first, polish second. Open at least one real basket at home every week.
- **English only**, but every string goes through `app_en.arb` from day one.

## Milestones

| Milestone | Day | Definition |
|---|---|---|
| M0 | 2 | Monorepo, server and Flutter app running, CI green |
| M1 | 6 | Sign-in, create household, join with invite code |
| M2 | 10 | Live basket + auto-close + deploy, **real usage starts in both homes** |
| M3 | 16 | Freeze, price entry, push notifications |
| M4 | 21 | Settlement, ETA suggestion, history, resilience |
| M5 | 25 | Code freeze: bug fixes only |
| M6 | 29 | Report, demo video, README, submission |

---

## Week 1 (Days 1-7): Foundations and membership

### Day 1: Setup
- [x] **A** `serverpod create open_basket`, git repo, `.gitignore` (including `passwords.yaml`)
- [x] **A** Postgres (embedded, see ADR-003 — Docker not needed locally), first migration applied, server running
- [x] **A for B** Flutter packages: `flutter_riverpod`, `go_router`, `intl`, `flutter_localizations` (ADR-012). `firebase_messaging` and `geolocator` wait for Days 11-12 and 19-20 — both need platform config
- [x] **A for B** `l10n.yaml` + `app_en.arb`, `core/theme.dart` with the design tokens, `core/client_provider.dart`, `core/router.dart` (ADR-012)
- [x] **Both** Commit `CLAUDE.md` and `PLAN.md`; PRs from `feat/*` — **branch protection on `main` still to be enabled**

### Day 2: Models and CI
- [x] **A** Write all `.spy.yaml` models (schema below), `serverpod generate`, migration
- [x] **A** All endpoint signatures with `UnimplementedError` bodies, generated into the client — B can build against a typed, compiling client without waiting for bodies
- [x] **A** `analytics_service.dart`: `track(session, type, householdId, basketId, payload)`
- [x] **B** GitHub Actions: analyze / format / tests, all green (came with the Serverpod 4 template, PATH fixed)
- [x] **B** Design direction: the v3 screen set is finished — 21 screens, light and dark, contrast verified
- ✅ **M0**

### Days 3-4: Auth
- [x] **A** Six-digit emailed sign-in code, no passwords (ADR-004): 10-min expiry, 3 attempts, a new code kills the old one, resend rate limited. The bundled provider does not do this, so the flow is ours
- [x] **A** `authz.dart`: `requireMember(session, householdId)`, `requireShopper(session, basket)`
- [x] **A for B** `sign_in_screen.dart` + `code_entry_screen.dart` (screens 01-03), wrong-code and resend-cooldown states, persistent session, sign-out (ADR-012)
- [x] **A for B** After sign-in: route to "Create or join a household" if the user has none (ADR-020)

### Days 5-6: Households and invites
- [x] **A** `household_endpoint.dart`: `create`, `getMine`, `rotateCode` (permanent 6-char code, owner-only, old code dies instantly — ADR-006), `joinWithCode` with a distinguishable stale-code error, `listMembers`, `leave`, `rename`
- [x] **A** Household has a `currencyCode` setting, ISO 4217, default `TRY`, with a minor-unit count per currency (ADR-008)
- [x] **A** Integration test: a non-member cannot read another household's data
- [x] **A for B** `create_household_screen`, `join_household_screen` and the member list on the home screen (screens 04, 05, 17) — ADR-020. The code is copied to the clipboard rather than shared through the share sheet; **rotate_code_screen (18) and the share sheet are still open**
- ✅ **M1**

### Day 7: Stores + buffer
- [x] **A** `store_endpoint.dart`: add/list household stores (name, lat, lng). This is only the store's fixed location. Plus `remove`; a repeated name returns the existing store (ADR-034)
- [x] **A for B** `stores_screen.dart`: simple form, no map; "Use my current location for this store" button
- [ ] Weekly review, catch up on slipped tasks

---

## Week 2 (Days 8-14): Live basket and auto-close

### Day 8: Basket lifecycle
- [x] **A** `basket_endpoint.dart`
  - `open(householdId, storeId?, durationMinutes)` → error if the household already has an open basket; `closesAt = now + duration`; schedule future calls
  - `extend(basketId)` → shopper only, exactly one +5 min extension per basket (ADR-009)
  - `freeze(basketId)` → "At checkout"
  - `cancel(basketId)`
  - `getActive(householdId)`, `getServerTime()`
- [x] **A** Partial unique index `basket ("householdId") WHERE status = 'open'`, added by hand to the migration — `.spy.yaml` cannot express it and the transaction alone does not stop a race
- [x] **A** `close_basket_future_call.dart` + registration in `server.dart` + **startup sweep**
- [x] **A** `auto_close_test.dart`: a short basket becomes `frozen` on time; an extended basket does not close early

### Day 9: Streaming
- [x] **A** `basket_stream_endpoint.dart`: `Stream<BasketEvent> watch(basketId)`
  - On connect, send a full `snapshot` first, then forward events
  - Events are published to the `basket:<id>` channel via `basket_channels.dart`
  - Event types: `snapshot`, `itemAdded`, `itemUpdated`, `itemRemoved`, `timerExtended`, `basketFrozen`, `basketSettled`, `basketCancelled`
- [x] **A** `addItem`, `updateItem` (only the requester, only while `open`), `removeItem`
- [x] **A for B** `live_basket_controller.dart`: subscribe, apply events to state, reconnect with exponential backoff and resync from snapshot (ADR-020)

### Day 10: Live screen + deploy
- [x] **A for B** `live_basket_screen.dart`, `add_item_bar.dart` (name + note; **quantity is not in the bar yet**), requester chip in that member's tone on each item
- [x] **A for B** `countdown_banner.dart`: based on server time, Signal fill in the last 2 minutes, and no ticking number once `frozen`
- [x] **A for B** `open_basket_sheet.dart`: quick picks 5 / 10 / 15 / 20 min + custom
- [x] **A** Deploy (Serverpod Cloud or VPS + Docker), production config, HTTPS — Serverpod Cloud, `open-basket` project (ADR-024)
- [ ] **A for B** Ship the build to both homes. **APK ready and verified against production** (ADR-027); installing it on the actual phones is still to do, and iPhones need a cable install that expires every 7 days
- ✅ **M2: real usage starts.** Keep notes in `docs/usage_log.md`

### Days 11-12: Push notifications
- [ ] **A** `device_endpoint.dart`: register/remove FCM tokens; per-member notification preferences for the three types, checked server-side before sending (ADR-010)
- [ ] **A** `notification_service.dart`: send via FCM HTTP v1 (service account key in `passwords.yaml`)
  - Basket opened → all members except shopper: "Kaan is heading to Migros. Add what you need in the next 10 min."
  - 2 minutes left → members who haven't added anything yet (`closing_soon_future_call.dart`, same idempotency rule)
  - Settlement ready → members who owe money: "You owe Kaan ₺84.50 for today's run."
- [ ] **A** Notification text is built on the server in English; keep templates in one file so they can be localized later
- [ ] **B** `fcm_service.dart`: permission prompt, token upload, tap → deep link to the live basket

### Days 13-14: Resilience
- [x] **A** Race between two simultaneous `open` calls: the partial unique index guarantees a single basket (done early on Day 8, with the index — ADR-013)
- [x] **A** `basket_stream_test.dart`: two clients, one adds, the other sees it (done early on Day 9, with the endpoint)
- [x] **A for B** Resync when returning from background, airplane mode test — resubscribes on resume; offline tested by stopping the server under a live simulator (ADR-032)
- [x] **A for B** Items added offline are queued on the device and replayed on reconnect (ADR-011) — in memory, so a queue does not survive the app being killed (ADR-032)
- [x] **A for B** Reconnecting state on the live basket (ADR-032), and the "this basket closed while you were away" arrival state (ADR-033)
- [x] **A for B** Second `open` on a household that already has one: clear error, and the screen that shows it — not an error at all: it lands in the running basket (ADR-033)
- [ ] **Both** Fix the top 3 issues from the first week of real use

---

## Week 3 (Days 15-21): Checkout and settlement

### Days 15-16: Checkout flow
- [x] **A** Shopper-only `markItem(itemId, status: picked | unavailable, priceMinor?)`, allowed in **both** `open` and `frozen`; prices only in `frozen` (ADR-005). Marking publishes an item event on the stream. Also `requested` as the undo; ADR-028
- [x] **A** Optional "receipt total" field; the difference from the item sum is split evenly across every member (ADR-007), shown before settling. `setReceiptTotal` records it and publishes `basketUpdated`; the split itself is `settlement_service` on Days 17-18
- [x] **A for B** `checkout_screen.dart`: items grouped by person, price field per row, "Not available" button. Also ticking items off on the live basket while it is open (ADR-030)
- ✅ **M3**

### Days 17-18: Settlement
- [x] **A** `settlement_service.dart` (pure Dart function, testable without DB)
  - The shopper paid
  - Each member owes the sum of their own `picked` items, plus an even share of the receipt gap
  - Members who asked for nothing still owe their share of the gap
  - The remainder after dividing goes to the shopper, so the lines sum exactly to what they paid
  - The shopper's own items create no debt
  - Everything is already in minor units, so no rounding
- [x] **A** `settlement_endpoint.dart`: `settle(basketId)` → writes `SettlementLine` rows + `status = settled`, errors if called twice; `getSettlement(basketId)`. Plus `preview`; settle refuses a basket with unpriced items (ADR-029)
- [x] **A** `settlement_calc_test.dart`: single member, three members, nothing picked, shopper's own items, a member with no items at all, a gap that does not divide evenly, a zero-decimal currency
- [x] **A for B** `settlement_screen.dart`: "Ayşe owes Kaan ₺84.50", shareable text summary (copied to the clipboard; the share sheet is not wired). A member reaches it from the "last run" card on the home screen (ADR-031)

### Days 19-20: ETA suggestion
- [x] **A for B** In `open_basket_sheet.dart`: pick store → read location once → "Estimated 12 min" suggestion, user can change it
- [x] **A for B** Formula (in a shared, tested Dart file): haversine distance × 1.3 road factor / walking or driving speed + shopping buffer (e.g. 5 min), rounded to minutes. **Computed on the client**, so location never reaches the server. Record this decision in `docs/ARCHITECTURE.md`.
- [x] **A for B** If location permission is denied, fall back silently to manual duration

### Day 21: History + review
- [x] **A** `getHistory(householdId, limit)` — `history.list` (now one `PastRun` summary per row) and `history.get` (ADR-031, ADR-035)
- [x] **A for B** `history_screen.dart`: past baskets, totals, who asked for what, plus the detail view for one past run (screens 29-30)
- [ ] **Both** Review usage notes; the last big change decision is made here
- ✅ **M4**

---

## Week 4 (Days 22-29): Polish, report, submission

### Days 22-23: UX polish
- [x] **A for B** Empty states, loading skeletons, clear English error messages (all from ARB) — every `BasketError` worded; skeletons skipped (ADR-039)
- [x] **A for B** Small animation when an item lands on another device, haptic in the last minute
- [x] **A for B** Suggestion chips from the household's frequent items (simple server query) — per member: "You usually ask for"
- [x] **A for B** `settings_screen.dart` and `currency_screen.dart` (screens 19-20), including sign out and leave household. Leaving no longer deletes history (ADR-036); notification switches wait for push
- [ ] **B** Final app name, launcher icons from `docs/brand/open-basket-app-icon-1024.png`, store-style screenshots
- [x] **A** Rate limiting (item spam), input validation (name length, quantity range) — 12 a minute and 40 per run per member

### Days 24-25: Testing and code freeze
- [x] **A** All integration tests green, scan production logs for errors — slow token refresh, see ADR-039
- [x] **A for B** Small screens and dark mode check, at least one iOS run if possible — SE-sized frame, dark; iPhone install on Day 10
- [x] **A for B** Grep for hardcoded strings: `grep -rn "Text('" lib/` should return nothing user-facing
- ✅ **M5: no new features after Day 25**

### Day 26: Report data
- [x] **A** `stats_endpoint.dart` and `scripts/report.sql` (ADR-040; the endpoint answers for the caller's household only):
  - Total baskets opened, per household
  - Total items, average items per basket
  - Outcome breakdown (auto-closed / manually frozen / cancelled / settled)
  - Average chosen duration, extension rate
  - Share of members who added at least one item (the key metric: "shared attention")
  - Median time from open to first item
- [ ] **A** Write results as tables in `docs/REPORT.md`, with an honest "what didn't work" section

### Day 27: Demo
- [x] **A for B** `docs/DEMO_SCRIPT.md` (without the notification beat until push exists): two phones side by side, basket opens → notification → item lands instantly → app is force-killed → basket still closes on time → checkout → settlement
- [ ] **B** Record and edit a 2-3 minute video (English narration or captions)

### Day 28: Documentation
- [x] **A** `README.md`: problem, solution, where and why we used Serverpod (streaming, future calls, auth, server-side settlement), setup, architecture diagram
- [ ] **B** Screenshots, APK link

### Day 29: Submission
- [ ] Check every field of the hackathon submission form (repo link, video, description, team)
- [ ] Repo is public; `passwords.yaml` and keys are really not in the repo
- [ ] Submit, then open one more basket and celebrate

---

## Data model draft

```yaml
# household.spy.yaml
class: Household
table: household
fields:
  name: String
  currencyCode: String   # ISO 4217, default TRY (ADR-008)
  code: String           # permanent 6-char join code, rotatable (ADR-006)
  createdAt: DateTime

# household_member.spy.yaml
class: HouseholdMember
table: household_member
fields:
  householdId: int
  userId: int            # user from the auth module
  displayName: String
  role: String           # owner | member
  notifyBasketOpened: bool
  notifyClosingSoon: bool
  notifySettlementReady: bool
  joinedAt: DateTime
indexes:
  member_unique_idx:
    fields: householdId, userId
    unique: true

# store.spy.yaml
class: Store
table: store
fields:
  householdId: int
  name: String
  lat: double
  lng: double

# basket.spy.yaml
class: Basket
table: basket
fields:
  householdId: int
  shopperMemberId: int
  storeId: int?
  status: BasketStatus   # open | frozen | settled | cancelled
  openedAt: DateTime
  closesAt: DateTime
  frozenAt: DateTime?
  closedAutomatically: bool
  extendCount: int
  receiptTotalMinor: int?

# basket_item.spy.yaml
class: BasketItem
table: basket_item
fields:
  basketId: int
  requesterMemberId: int
  name: String
  quantity: int
  note: String?
  status: ItemStatus     # requested | picked | unavailable
  priceMinor: int?
  addedAt: DateTime

# basket_event.spy.yaml  (no table, stream only)
class: BasketEvent
fields:
  type: BasketEventType
  basket: Basket?
  items: List<BasketItem>?
  item: BasketItem?
  serverTime: DateTime

# settlement_line.spy.yaml
class: SettlementLine
table: settlement_line
fields:
  basketId: int
  fromMemberId: int
  toMemberId: int
  amountMinor: int

# analytics_event.spy.yaml
class: AnalyticsEvent
table: analytics_event
fields:
  type: String
  householdId: int?
  basketId: int?
  memberId: int?
  payload: String?       # JSON
  createdAt: DateTime
```

> Verify field types and relation syntax against the installed Serverpod version.

## Out of scope (only if time allows)

- Reading prices from a receipt photo (OCR)
- Multiple simultaneous baskets (different stores)
- Countdown in iOS Live Activities / Android ongoing notification
- Web client
- Turkish localization (`app_tr.arb`), cheap to add later thanks to ARB

## Risks

| Risk | Mitigation |
|---|---|
| Usage period is ~18 days, not 6 weeks | Don't miss the Day 10 deploy; say it honestly in the report |
| Future call lost during a server restart | Startup sweep + idempotent close |
| Push notification arrives late | Push is a hint; stream + snapshot is the source of truth |
| Client clock is wrong | Countdown uses server time |
| One of two people gets blocked | 15-min daily sync, PRs reviewed within 24h |
| Test households are Turkish speakers using an English UI | Keep copy very simple; note any confusion in `usage_log.md` |
