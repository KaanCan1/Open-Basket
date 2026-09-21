# Architecture decisions

Short entries, newest last. Write one the moment a decision is made — the other developer's
Claude session cannot see anything that is not committed.

## ADR-001: Server owns time

`closesAt` is stored and enforced on the server. The client fetches server time on connect and
renders `closesAt - serverNow`, so a wrong device clock cannot change when a basket closes.

## ADR-002: ETA is computed on the client

The shopper's device reads location once to suggest a duration. The server only ever receives the
chosen store and a number of minutes. Location is never sent, stored or logged.

## ADR-003: Local development uses Serverpod's embedded PostgreSQL, not Docker

`config/development.yaml` ships with `dataPath: .serverpod/development/pgdata`, so Serverpod starts
and manages its own PostgreSQL 16 for local development. Running the server is one command and
neither developer needs Docker Desktop, which is what unblocked Day 1 when Docker would not start
on the first machine.

Docker is still used where it makes sense: `docker-compose.yaml` stays in the repo for CI (the
tests workflow starts real Postgres and Redis containers) and for production deployment. Only the
local development database changed.

**Amended on Day 5: the *test* database is a real PostgreSQL again.** `config/test.yaml` had
`dataPath` too, and with more than one integration test file every run failed with "Another
process is using the local database" — including from a clean slate with the data directory
deleted and no postgres process alive, so it is not a stale lock we can clear. `config/test.yaml`
now has no `dataPath`, which points it at the container `docker-compose.yaml` already starts on
port 9090, exactly where CI runs it.

**Amended again on Day 8: the cause is known, and local integration tests work again.**
The failure is not a stale lock. `serverpod_test` brings the embedded postmaster up twice per
test group — once in `EphemeralTestDatabase.create` to make the group's database, once when the
pod itself starts — and the second attempt cannot attach to the first, because
`embedded_postgres_resolver.dart` starts it with `detach: false` and `AttachedSupervisor.tryAttach`
then refuses. The second start finds the live `postmaster.pid` and reports "Another process is
using the local database". It is a framework limitation in Serverpod 4.0.0, not something this
project can configure around, and it is why `config/test.yaml` has no `dataPath`.

What we did instead is `scripts/local_test_db.sh`: a PostgreSQL 16 cluster of our own, under the
gitignored `.serverpod/`, listening on port 9090 — the port `config/test.yaml` already names, so
**nothing in the committed configuration changes**. `./scripts/local_test_db.sh start` and
`dart test` runs the whole suite on a machine with no Docker. CI is untouched and still uses the
container from `docker-compose.yaml` on the same port.

Two things worth knowing if it ever has to be rebuilt: PostgreSQL must be **15 or newer**, because
Serverpod 4 reads `pg_index.indnullsnotdistinct` while applying migrations and PostgreSQL 14 fails
with `column "indnullsnotdistinct" does not exist`; and `initdb` needs `LC_ALL=C` on macOS or the
postmaster dies at startup with "postmaster became multithreaded during startup". The script sets
both.

---

# Decisions taken from the design set (v3)

The screen set published on Day 2 settled several product rules that the original plan had left
open or had decided differently. We adapted the spec to the design rather than redrawing the
screens. ADR-004 to ADR-010 record what changed; where they contradict the original `PLAN.md`
wording, these win.

## ADR-004: Sign-in is a six-digit emailed code, not a password

There is no password anywhere in the product. The user types an email address, receives a six
digit code, and enters it.

- A code expires **10 minutes** after it is issued.
- A user gets **3 attempts** per code. After the third failure the code is burned and a new one
  must be requested.
- Requesting a new code invalidates the previous one immediately.
- Resend is rate limited; the design shows a 24-second cooldown on the button.

**Checked on Day 2: the bundled provider does not do this, so the flow is ours to write.**
`serverpod_auth_idp_server` 4.0.0's email provider is password-based — `login(email, password)`,
with codes appearing only in `startRegistration` / `verifyRegistrationCode` and in password reset.
There is no passwordless code login.

What makes a custom flow cheap rather than alarming:
`ServerSideSessions.createSession(session, authUserId:, method:, scopes:, expiresAt:)` in
`serverpod_auth_core_server` mints a session for any `AuthUser`. So `AuthEndpoint` finds or creates
the `AuthUser` for the address, emails a code, and calls `createSession` once the code checks out.
`SignInCode` is the server-only table holding the hashed code, its expiry and the attempts left.

Budget Day 3-4 accordingly: this is real work, not configuration, and M1 depends on it.

**Built on Day 5.** `SignInService` holds the policy, `SignInCodePolicy` the parts worth testing
on their own (generation, hashing, comparison, normalisation), `SignInEmailSender` the delivery.
Decisions worth knowing:

- The hash pepper reuses `emailSecretHashPepper`, which the template already defines in every run
  mode — one less secret to distribute. A missing pepper throws rather than falling back to a
  constant, because a fallback would look like it worked while removing the protection.
- Accounts are created on the first **successful** code, never on request. Otherwise typing a
  stranger's address would create an account for them.
- Inside the 24-second resend cooldown the endpoint does nothing and returns: the code already in
  flight stays valid. That is what the countdown on the resend button enforces, and it stops the
  endpoint being used to send somebody a stream of email.
- `requestSignInCode` answers identically whether or not the address has an account, and delivery
  failures are logged rather than propagated — otherwise the difference between a sent and an
  unsent code would reveal who has signed up.
- Codes are consumed before the session is minted, so two requests arriving together cannot
  redeem the same code twice.

## ADR-005: The shopper marks items while the basket is still open

`markItem(itemId, status: picked | unavailable, priceMinor?)` is allowed in **both** `open` and
`frozen` state, shopper-only in both. The shopper ticks items off as they walk the aisles rather
than doing the whole basket at the till.

Prices are still only entered in `frozen`. Marking an item in `open` publishes an item event on
the stream like any other change, so members watching see "Kaan has it" live.

This replaces the original rule that `markItem` was frozen-only.

## ADR-006: The household code is permanent and rotatable

A household has **one** code, six characters, with no expiry. It works until an owner rotates it,
and rotating invalidates the old code the same instant.

- Rotation is owner-only.
- Existing members are unaffected; only new joins are.
- Nothing in history changes.

This replaces the original 48-hour `HouseholdInvite`. The model keeps a `code` on the household
(or a single invite row per household) and the endpoint offers `rotateCode` instead of
`createInvite` with a TTL. Joining with a stale code must fail with a clear, distinguishable
error — that path gets more common now that rotation kills old codes instantly.

## ADR-007: The receipt gap is split evenly across every member

When the shopper enters a receipt total that differs from the sum of the priced items, the
difference is divided evenly across **all** household members, including members who asked for
nothing.

- $2.00 over four members is $0.50 each. A member who requested nothing owes $0.50, not $0.00.
- The remainder after dividing goes to the shopper, so the settlement lines always sum exactly to
  what the shopper paid. In zero-decimal currencies the remainder is a whole unit.
- The shopper carries their own share plus that remainder.

This replaces "the receipt total is a warning, not a blocker" and "each member owes the sum of
their own picked items". The second half still holds for the item portion; the gap is a separate
term added on top. `settlement_service.dart` therefore takes the member list, not just the items,
and `settlement_calc_test.dart` needs cases for a member with no items and for a remainder that
does not divide evenly.

## ADR-008: Currency is a household field with an explicit minor-unit count

The household stores an ISO 4217 code. Every price, settlement and shared summary uses it.

- Each currency carries its minor-unit count: 2 for USD, EUR, GBP and TRY; 0 for JPY. Amounts stay
  integer minor units, so a zero-decimal currency stores whole units.
- Formatting follows the currency, not the phone locale: `$1,234.50`, `€1.234,50`, `1.234,50 ₺`,
  `¥1,234`.
- A settled basket keeps the code it closed with. Changing the household setting never rewrites
  history and never converts.

**Default is `TRY`, not the `USD` the design shows.** Both test households are Turkish and every
basket in our 18 days of real usage will be in lira; a USD default would either force a settings
trip before the first run or silently produce a report in the wrong currency. The picker stays.

## ADR-009: One extension per basket, five minutes, shopper only

The original cap ("up to 60 minutes total") is replaced by exactly one `+5 min` extension per
basket. Once used, the control stays visible in a spent state rather than disappearing, and the
timer bar shows the added time as a separate hatched segment so members can see where it came
from. `Basket.extendCount` still models this fine.

## ADR-010: Notification preferences are per member

Members can independently switch off each of the three notification types: basket opened, two
minutes left, and settlement ready. The server checks the preference before sending, so this is a
persisted field on the member, not a client-side filter.

The design set did not flag this in its own backend-contract list; it appears only on the settings
screen. It is easy to miss and cheap to add now.

## ADR-011: Items added offline are queued on the device

The error state promises "Your items are saved on this phone and will sync the moment you're
back." That is a commitment to optimistic local queueing, not just a reassuring sentence: an item
added without a connection is held on the device and replayed when the stream reconnects.

If we decide not to build it, the copy has to change in the same PR — a promise in an error
message is still a promise. Scope it on Day 13-14 with the rest of the resilience work.


## ADR-012: A built the Flutter skeleton, once

On Day 5 the Flutter app was still the untouched Serverpod template while the backend had Days
1-4 behind it. M2 — deploy plus real usage in both homes — is Day 10, and it is what buys the
roughly 18 days of data the final report rests on. B starting from an empty app on Day 7 would not
have got there.

So A built the skeleton: packages, `l10n.yaml` and `app_en.arb`, the design tokens and theme,
the Riverpod client provider, the `go_router` setup, and screens 01-03 wired to the real
endpoints. That deliberately crosses the ownership line in `CLAUDE.md`, which is why it is written
down: B picks up a system that runs and signs in, rather than a blank `main.dart`.

Ownership reverts immediately. Everything after this is B's, and A does not touch
`open_basket_flutter/` again without another entry here.

Two things fell out of doing it:

- **`AuthEndpoint` became `SignInEndpoint`.** Our endpoint was generating `client.auth`, which
  shadowed the Serverpod auth module's own `client.auth` — the session manager, `isAuthenticated`,
  sign-out. Ours is `client.signIn` now. Caught by the analyzer the first time the client provider
  tried to call `client.auth.initialize()`; it would have been much more confusing later.
- **CI now covers the Flutter app.** It only ever ran `dart analyze`, `dart format` and `dart test`
  against `open_basket_server`, so the half of the codebase B owns was completely unchecked.
  Analyze, format and `flutter test` now run against both.

---

# Day 8

## ADR-013: Rule 4 is enforced by a hand-written partial unique index

A household gets one open basket at a time. The check at the top of `BasketEndpoint.open` is only
the polite answer: two calls can both read "no open basket" before either inserts, and the
transaction does not stop that. The guarantee is

```sql
CREATE UNIQUE INDEX "basket_one_open_per_household_idx"
    ON "basket" ("householdId")
    WHERE "status" = 'open';
```

`.spy.yaml` cannot express a partial index, and a plain unique index on `householdId` would give a
household one basket *ever*. So it is written by hand into the migration, and `open` catches
`DatabaseUniqueViolationException` and converts it back into `householdAlreadyHasOpenBasket` by
matching on the constraint name — the loser of a race sees the same friendly error as someone who
simply tapped too late.

**This needs re-adding by hand to every new migration.** A fresh database is built from the latest
migration's `definition.sql`, not from the `migration.sql` files, so the index has to live in
*both*; and `serverpod create-migration` regenerates `definition.sql` from the models, which know
nothing about it. Two tests guard this: one asserts the index exists in the live database and
fails with instructions when it does not, and one asserts that a second open basket is refused
with exactly the constraint name `open` matches on. If those two drift apart, a real race reaches
the shopper as a 500 instead of a sentence.

## ADR-014: The server's clock is `package:clock`, not a global of ours

Rule 1 says the server owns time, which means tests have to be able to say what time it is —
otherwise "a five minute basket closes on time" is a test that takes five minutes. `ServerClock` in
`util/clock.dart` is a one-line wrapper over `package:clock`, so a test uses `withClock` and the
override is scoped to the zone it wraps. A mutable global of our own would have done the same job
until the first test forgot its `tearDown` and quietly poisoned the rest of the suite.

The wrapper is there so the UTC rule lives in one place: `closesAt` is stored and compared in UTC,
and a server answering `getServerTime` in local time would hand the client a drift correction
wrong by the timezone offset.

One practical consequence in tests: the frozen clock is set to **2030**, deliberately far ahead of
real time. The test server's future call manager is real, and a basket scheduled to close in the
real past would fire in the background halfway through an assertion.

## ADR-015: Auto-close freezes; it does not settle

When the timer runs out the basket becomes `frozen`, not `settled` — the same state the shopper
reaches by tapping "At checkout". The run is not over at that point: the shopper still has to mark
what they found and enter what it cost. `closedAutomatically` records which of the two got there
first, so the history screen can say "the timer closed this" and the settlement screen can word
itself accordingly.

Closing is idempotent (rule 2): `closeIfDue` reloads the basket and does nothing unless it is
still `open` and genuinely overdue. That one guard covers every way it gets called twice — a
future call superseded by an extension, a call firing while the shopper is tapping "At checkout",
and the startup sweep racing a future call that is already handling the same basket. Extending
therefore does not need the old call to be cancelled to be correct; cancelling it is tidiness, and
the startup sweep is the safety net for the case where scheduling failed altogether.

---

# Day 9

## ADR-016: The stream subscribes before it reads the snapshot

`watch` opens the `basket:<id>` subscription *first*, then reads the basket and its items
and yields them as the first event. The other order looks tidier and is wrong: anything
published while the snapshot query is in flight would be published to nobody and lost for
good.

The cost is that an event can arrive that the snapshot already contains — an `itemAdded`
for a row that is already in the list. So **the client must apply events by item id, not
by appending**. Applying an event twice is recoverable; missing one is not, and a live
basket that is quietly short one item is worse than one that flickers.

Everything a client needs to recover is in the stream itself. A reconnect yields a fresh
snapshot as its first event, so there is no second "catch me up" call and no window where
the client is connected but wrong.

## ADR-017: The stream ends itself when the basket is over

`settled` and `cancelled` are terminal, and `watch` completes after emitting them. A
client that sees `onDone` should go back to the household screen rather than reconnect;
without this it would hold a socket open on a basket nothing can ever happen to, and the
reconnect-with-backoff logic would fight a server that is behaving correctly.

`frozen` is deliberately **not** terminal. The shopper is still marking items and entering
prices, and the rest of the household wants to watch that happen.

## ADR-018: Publishing an event may fail; the action may not

`BasketChannels.publish` logs and swallows. A member who misses an event has a briefly
stale screen and the next reconnect fixes it. A shopper whose `freeze` threw because a
message could not be posted is a shopper stuck at the till. The stream is a convenience
over the database, never the record.

**Delivery is local to one server process.** `MessageScope.auto` upgrades to Redis when
Redis is enabled, and it is not. One instance is the plan for the Day 10 deploy, so this
is correct today — and it is the first thing that has to change before a second instance
exists, because two servers would each see only their own half of a household.

## ADR-019: A defaulted endpoint parameter becomes required on the client

`addItem` takes `int? quantity` rather than `int quantity = 1`, and treats null as one.
This is not a preference: Serverpod's generator turns a defaulted named parameter into a
**required** one on the generated client, so `int quantity = 1` here produces
`required int quantity` there and every caller has to spell out the common case. Nullable
is the only shape that survives the client boundary as optional.

Worth reporting upstream — see the feedback list in `docs/SUBMISSION.md`.
