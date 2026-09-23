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

**Amended on Day 9: a malformed address has its own error.** It used to share
`invalidSignInCode` with a wrong six-digit code, which meant the sign-in screen could never
show "that does not look like an email address" — every bad address became the generic
"Something went wrong", and the specific copy sat in `app_en.arb` as dead string. Found by
running the app, not by a test: both halves type-checked and both were individually
reasonable. `invalidEmailAddress` now exists precisely because the two failures are worded
differently on screen.

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

## ADR-020: A is building the screens too

B has still not committed to the repository. ADR-012 recorded A building the Flutter
skeleton once, on Day 5, with ownership reverting immediately; that has not held, because
there was nobody to revert it to. On Day 10 Kaan decided A writes the screens and B joins
later.

What this changes in practice: `CLAUDE.md`'s ownership table no longer describes reality
for `open_basket_flutter/**`. It stays in the table because it is still where B picks up,
and because the contract-first rule it exists to protect — models and endpoint signatures
frozen on day two — is what made the app buildable at all.

The order the screens are being built in follows the scoring rather than the plan's day
numbers: the hackathon puts 30% on "does it work -- the core flow completes, nothing
critical is faked", and it is also the tie-breaker. So the one loop a judge will try comes
first, and anything off it waits.

Two things found the moment the first screen ran, both from Day 5's theme:

- **Signal was being painted as a foreground.** `colorScheme.primary` is Signal, and
  Material falls back to primary for the foreground of anything it has no theme for. With
  no `outlinedButtonTheme`, "I have a code" rendered lime on paper at roughly 1.6:1 —
  against the one rule the palette has, which is that Signal is a fill and never a text
  colour. The existing contrast test passed throughout, because it measures tokens and
  every token was right. `theme_test` now also measures what Material actually resolves.
- **`surfaceContainerHighest` was never defined**, so the tonal panel behind the household
  code came out the same colour as the page. It is in the scheme now, which means a widget
  asking Material for a raised surface gets the palette's answer rather than Material's.

## ADR-021: The client corrects for clock drift, and never counts down locally

`ServerClock` holds the offset between this device and the server and hands out a
corrected now. Every countdown is `closesAt - serverNow`, recomputed on each tick, and
nothing ever counts down from a number it was handed.

Both halves matter. A phone whose clock is two minutes fast would show a basket closing
two minutes early, which looks exactly like the server losing the basket. And a phone that
sleeps for four minutes would wake up four minutes ahead of the basket if it had been
decrementing locally; recomputing means it simply shows the right number on the next frame.

The offset is seeded by the stream's first event and refreshed by every event after it,
because each one carries `serverTime` for this purpose. Nothing seeds it at startup: the
only screen with a countdown shows a spinner until that first event arrives, so the clock
is always reconciled before a countdown is drawn. Round-trip latency is not corrected for,
which makes the client run a few tens of milliseconds slow — the right direction to err,
since showing one second left is better than showing a basket closed that is still open.

## ADR-022: A basket that is not open shows no countdown at all

`closesAt` stays on a frozen basket as a record of when the run was booked to end. The
first version rendered it anyway, so checking out early left a number ticking down under
the word FROZEN — which reads as "still counting" when the list is already final. Found by
freezing a basket on the simulator and watching the digits keep moving.

Now a basket that is not open shows the label and "The list is final.", and the ticker is
cancelled rather than left running behind a widget nobody is watching.

## ADR-023: Items are not applied optimistically

An item appears when the server has accepted it and the stream has echoed it back, not
when the person taps Add. The whole promise of the product is that everyone is looking at
the same list, and a row that exists on one phone and nowhere else breaks that promise
more badly than half a second of waiting does.

The keyboard is deliberately kept up after a successful add: a shopping list is typed in
bursts, and making someone tap back into the field between "milk" and "eggs" is the
difference between adding three things and adding one.

---

# Day 10, deploy

## ADR-024: Serverpod Cloud, because it is what makes a judge able to sign in

The server runs on Serverpod Cloud, project `open-basket`, starter plan:

- api: `https://open-basket.api.serverpod.space/`
- web: `https://open-basket.serverpod.space/`
- insights: `https://open-basket.insights.serverpod.space/`

The deciding reason was not convenience. Sign-in is a six-digit code by email, and in
development the code only reaches the server console — so on a self-hosted box nobody
without shell access could get past the first screen, including a hackathon judge. The
rules require a working project judges can use free of charge until the judging period
ends, and Serverpod Cloud manages `scloudAuthEmailKey` itself, which is exactly the
password `SignInEmailSender` reaches for outside development. Deploying there turned the
biggest submission risk into a solved problem without writing an email integration.

Everything else auth needs is platform-managed too — `database`, `serviceSecret`,
`emailSecretHashPepper`, `jwtHmacSha512PrivateKey`, `jwtRefreshTokenHashPepper` — so no
secret is set by hand and none of them live anywhere near the repository.

The Flutter app points at an environment rather than a constant:

```bash
flutter run --dart-define=SERVER_URL=https://open-basket.api.serverpod.space/
```

`getServerUrl()` reads `SERVER_URL` first and falls back to localhost, so a debug build
against the laptop and a build for a judge differ only by that flag.

**The CLI cannot deploy from a path containing a space.** This repository lives at
`/Users/kaancankurt/dev/Open Basket`, and `serverpod cloud deploy` walks the workspace
root, prints it as `Open%20Basket` and finds nothing to upload — it fails with "No files
to upload", which reads like a `.gitignore` problem and is not one. A symlink does not
help; the CLI resolves the physical path. Until the directory is renamed, deploy from a
clone at a space-free path. Worth reporting upstream, and on the feedback list in
`docs/SUBMISSION.md`.

**A warning on every boot says the index is missing. It is not.** Startup logs:

> WARNING: The database does not match the target database: Table "basket" ... Missing
> Index "basket_one_open_per_household_idx".

The live database was queried directly and the index is there, partial predicate and all.
The comparison is against the migration's `definition.json`, which cannot describe a
partial index and therefore does not list it — so the mismatch is the hand-written index
of ADR-013 being invisible to the migration system, exactly as predicted. The wording
points the wrong way. `basket_lifecycle_test` is what actually guards this, and it passes.

## ADR-025: A frozen basket does not block the next run

Rule 4 is one **open** basket per household, and the partial unique index enforces exactly
that. The check at the top of `open()` counted frozen baskets as well, which was stricter
than the rule — and with settlement not built yet and cancel only allowed while a basket is
open, it meant **the first run to freeze locked the household out of ever opening another.**

Found on the deployed server, not by a test: a one-minute basket closed itself in the
background exactly as designed, and then the household could not start a second one. A
judge following `docs/TESTING.md` would have hit it on their second basket; both test homes
would have hit it after their first shop.

`open()` now asks `BasketService.openFor`, which counts only open baskets. `activeFor` still
answers with an open-or-frozen basket for the home screen, but prefers the open one and
otherwise returns the most recent frozen one — it used to have no ordering at all, so with
two frozen baskets which one came back was the database's choice.

The product reading is the same as the rule's: Tuesday's run should not wait for Monday's
receipt. The home screen now shows a frozen basket as "at checkout" with *Open a basket*
underneath it.

A second bug surfaced in the same walk: the home screen kept saying "a basket is open" after
the basket had frozen, because it reads through its own provider, fetched once. The live
controller now invalidates it on every basket-level event.

## ADR-026: The first frame never waits on the network

`createClient` used to await `client.auth.initialize()` before `runApp`. That call asks the
server to validate the stored session with a two-second timeout — and although its own
documentation says a timeout returns false without signing anyone out, it only catches
`ServerpodClientException`, so the `TimeoutException` escapes. A server that took longer
than two seconds to answer left an unhandled exception in `main`; `runApp` never ran and the
app was a **white screen for good**.

That is exactly what a freshly deployed or long-idle server does, which makes it the first
thing a judge would see after the project sat quiet for a day. Found by relaunching against
production a minute after a deploy.

Now `createClient` only restores the stored session from the device and returns; validation
runs in the background with a longer timeout and swallows failure. Offline, a cold server
and a timeout all keep the stored session. If the session really has expired, validation
signs the device out, the auth listenable fires, and the router sends the user to sign in —
the same path as before, just not in front of the first frame.

## ADR-027: The debug build was hiding four release problems

Every run until Day 10 was a debug build on a simulator, which never exercises the things a
phone in someone's hand depends on. Before handing an APK to the test households:

- **The release Android manifest had no `INTERNET` permission.** The Flutter template only
  grants it in the debug and profile manifests, so the first APK built for the households
  could not reach the server at all — sign-in would simply have failed. Found by reading the
  manifests before handing the APK over, then confirmed by installing the rebuilt APK on an
  Android 10 emulator and requesting a code from production.
- **The app was called `open_basket_flutter` on Android and "Open Basket Flutter" on iOS.**
- **The launcher icon was Flutter's default.** Generated now from
  `docs/brand/open-basket-app-icon-1024.png` by `flutter_launcher_icons`; Android gets an
  adaptive icon with the mark inset so the launcher mask never clips it. The logo is the ink
  mark on Signal (`#0F0F0E` on `#E2FB33`, the theme's own tokens), chosen by Kaan on
  2026-09-22; it replaced a white-on-black first cut the same day.
- **The app id was `com.example.…`**, a placeholder Apple does not register for installing on
  a physical iPhone. It is `com.kaancankurt.openbasket` on both platforms now — changed
  before anyone installed it, so nobody loses a session to the rename.

Distribution, given what is available: Android households get the APK directly. iPhones are
installed over a cable from this Mac with a **free** Apple Development identity, which means
the app **stops launching after seven days** and has to be reinstalled — at least twice over
the usage period. No TestFlight without the paid program.

## ADR-028: What marking an item may and may not do to its price

`markItem` has one price rule per case, so the checkout screen never has to guess:

- A price is only accepted on a `picked` item in a `frozen` basket. Anything else is
  `invalidPrice` or `basketNotFrozen`; something that was not bought has no price.
- Leaving `priceMinor` out **keeps** the price the item already has. Tapping "Got it" again at the
  till must not wipe what was typed a second ago.
- Marking an item `unavailable` or `requested` **clears** its price, and marking it `picked` again
  does not bring the old one back. `requested` is the undo for a mis-tap.
- Zero is a valid price (a free sample was still picked up); a receipt total of zero is not, because
  it would make every member owe a negative share of the item sum.
- Both amounts are capped at 100,000,000 minor units. That catches a slipped thumb, not a budget.

Marking is refused once the basket is `settled` (`basketAlreadySettled`, rule 6) or `cancelled`.

Entering the receipt total publishes a new `basketUpdated` event carrying the basket, so every member
sees the same total the split will use. It is a new event type rather than a reuse of
`timerExtended`: an event whose name lies about what happened is the kind of thing the next
person to touch the reducer gets wrong.

## ADR-029: Settling is strict, previewing is not

`settle` refuses (`basketNotFullyPriced`) while any item is still `requested`, or `picked` without a
price. Counting those as zero would quietly make somebody's shopping free, and a settled basket can
never be corrected (rule 6). The checkout screen keeps its button disabled until every row is priced
or marked not available, so the error is a backstop, not a flow.

`preview` runs on a half-priced basket and counts the gaps as zero, so the numbers fill in as the
shopper types. On a settled basket it returns the stored lines rather than recomputing, so the two
can never disagree after a member joins or leaves.

The split is across the household's members **at the moment of settling**, shopper included. A
member whose total comes out at zero gets no line. A member whose total comes out negative — a till
discount bigger than their items — is owed money, so their line runs from the shopper to them with
every figure negated; `amountMinor` is always positive and always equals `itemsMinor +
receiptGapMinor`.

Two taps on "Work out who owes what" cannot write the lines twice: the status check and the move to
`settled` are one conditional `UPDATE` inside the transaction that inserts the lines, and the loser
sees `basketAlreadySettled`. `settlement_test` races two calls to prove it.

## ADR-030: The checkout, as it behaved on two simulators

Decisions made while building screens 14 and 15, and the bugs that forced some of them:

- **Marking is an iOS action sheet**, not buttons on every row: tapping an item on the live basket
  (shopper, while open) offers Got it / Not available / Put it back. On the checkout, tapping an
  item's name offers Not available; its price field is on the right.
- **A price saves when the field is left**, not on every keystroke, and a price arriving from the
  stream never overwrites a field someone is typing in. iOS's decimal pad has no return key, so a
  tap outside the field is what leaves it. A comma is accepted as the decimal mark.
- **The totals panel steps aside while the keyboard is up for an item's price.** Pinned, it rode up
  on the keyboard and hid every row but one.
- **Cupertino widgets are tinted ink.** They take their tint from Material's primary, which is
  Signal, so the first action sheet read lime on white — the same fallback that broke screen 04's
  buttons. `theme_test` now checks what the action sheet actually resolves to.
- **The member list refreshes itself.** It was fetched once, so a phone that was open when someone
  joined never learned about them — and the checkout, grouping by member, would have hidden the new
  member's items, left them unpriced and kept the settle button disabled with nothing on screen to
  fix. The live basket now refetches members when an item arrives from a requester it does not
  know, the checkout groups by requester id so an unknown requester still gets rows, and the home
  screen refetches on resume and on pull-down (which now refetches the basket too).
- **The gap line on the checkout is display arithmetic** with the same truncating division the
  server uses; the stored lines are the only numbers anybody owes (rule 6).

Still open: once a run is settled the home screen no longer shows it, so a member who was not
watching the live basket has no way to their settlement. `history.list` (Day 21) or the Day 11-12
"settlement is ready" push closes it.

## ADR-031: The last settled run stays on the home screen

Once a run was settled, `getActive` stopped returning it, and a member who was not watching the
live basket at that moment had no way to learn what they owed — the settlement screen existed but
nothing led to it. Found by settling on one simulator and opening the app on the other.

The home screen now shows a "last run · settled" card when no basket is open or frozen: "You owe
Kaan ₺60.15", "Ayşe owes you …", or "You don't owe anything on this one", with the way to the
full settlement. It reads `history.list(limit: 1)` — pulled forward from Day 21 — and the stored
lines. A cancelled last run shows nothing, because it owes nobody anything. The card gives way to
the open basket as soon as the next run starts; older runs belong to the history screen.

`history.list` returns settled and cancelled runs only, newest first by `openedAt`. Open and frozen
runs are `getActive`'s. There is no `settledAt`, and a frozen run can overlap the next (ADR-025), so
this is shopping order rather than strict finish order — the order the house thinks in.

This is the pull half. The Day 11-12 "settlement is ready" push is the other half, for a member
who does not open the app.

## ADR-032: Offline on the live basket

- **Coming back to the app always resubscribes.** iOS suspends a backgrounded app and its socket
  dies with it, often without an error reaching the stream, so a phone taken out of a pocket could
  show a list that looked live and was minutes old. `AppLifecycleListener.onResume` drops the
  subscription and opens a new one straight away, skipping any pending backoff; the snapshot that
  opens every subscription does the resync (ADR-016).
- **Reconnecting is shown, not hidden in the app bar** (screen 25): an ink strip under the
  countdown — "The countdown is right — the server keeps the clock, not this phone" — with the
  time of the last event. The countdown keeps full strength because it is the server's time.
- **Items added offline are queued** (ADR-011, screens 25–26). The add bar queues instead of failing
  when the stream is down, or when a send fails for any reason other than the server refusing it.
  A queued item is a greyed row that says "Queued on this phone", never a normal row, so nobody
  mistakes it for being on everyone's list. On the next snapshot the queue is sent in order; a
  strip says "Back online · N items sent" for eight seconds. If the basket closed meanwhile the
  server refuses them, and the strip names what could not be sent instead of retrying forever.
- **Limits, on purpose:** the queue lives in memory. It survives leaving the screen (the controller
  keeps itself alive while anything is queued) and backgrounding, but not the app being killed.
  A queued item gets the server's time when it lands, not the time it was typed — the design's
  "it kept the time you added it" would need the client to send a timestamp the server then
  trusts, which rule 1 argues against.
- **The live screen compacts while the keyboard is up.** Full countdown card, reconnect strip,
  shopper buttons and add bar overflowed the screen by 55 px and left the list no height; now the
  countdown drops to one line, the strip loses its explanation and the shopper buttons step aside
  until the keyboard goes.

Tested by stopping the local server under a live simulator: strip appears, "Butter" is queued,
the server comes back, Butter lands as an ordinary row.

## ADR-033: Arriving at a basket you did not see happen

- **Someone else already has one open (screen 24).** Opening a basket while another member's run
  is open is not an error. The sheet catches `householdAlreadyHasOpenBasket`, fetches the running
  basket and hands it back; the home screen sees that the shopper is someone else and opens the
  live basket with a strip: "Ayşe opened one at 08:06 — One basket at a time in a household — so
  here's that run instead." The add bar is right there. Only if the running basket cannot be
  fetched does the old sentence appear in the sheet.
- **Closed while you were away (screens 22–23).** A basket that is no longer open says how it ended
  instead of a bare "frozen": "Closed on time — The basket closed itself at 23:32 — It ran the full
  10 minutes and shut on the server" when the future call closed it, "Kaan closed it at 23:30" when
  the shopper did, and "Kaan cancelled this run — Nothing was priced and nobody owes anybody" for a
  cancelled one. It is the question someone opening the app after a run is actually asking, and
  the server already knew the answer (`closedAutomatically`, `frozenAt`).

Both walked on two simulators against a local server: a basket that auto-closed overnight showed
the screen 23 header, and opening a basket on one phone while the other had one open landed in
that run with the strip.

## ADR-034: Stores and the duration suggestion

- **A store's location is pinned once, by whoever adds it**, with "Use my current location" — the
  design's screen 07. It is the store's fixed position, not a person's, and it is the only
  coordinate the server ever holds. A store without one is fine: its baskets just get no
  suggestion.
- **Any member adds or removes a store.** It is the household's shared list. Adding a name the
  household already has (ignoring case and surrounding space) returns the existing store rather
  than a second chip with the same name. Removing one keeps its baskets (`onDelete=SetNull`).
- **The suggestion is computed on the phone (ADR-002, rule 7).** Picking a pinned store in the open
  sheet reads the shopper's position once, computes, and drops it; the server receives the store id
  and the minutes. `core/eta.dart` is the formula, unit-tested: great-circle distance × 1.3 road
  factor; walking at 5 km/h up to 1.5 km by road, otherwise 25 km/h city driving; plus 5 minutes in
  the aisles; rounded up and clamped to 5–120. It is the way *to* the checkout, because that is
  when the basket closes. The suggestion becomes the selection, so the common case is one tap.
- **Every location failure is quiet.** Services off, permission refused, no fix in ten seconds:
  the sheet says "No estimate for Şok, so pick a time" and the quick picks carry on.
- **Accuracy is `medium`.** A store is a building and a run is minutes; best accuracy costs time and
  battery for nothing.
- **`storeNotFound`** replaces `basketNotFound` for a store id that is unknown or another
  household's, in both `store.remove` and `basket.open`.

Until the settings screen exists, the stores list is reached from a "Stores" row on the home screen
and from "Add a store" in the open sheet. The live basket and the home card name the store.

## ADR-035: History is one call per screen

- **`history.list` returns `PastRun` summaries, not bare baskets.** A row on screen 16 shows the
  total and how many items each member asked for; returning baskets would have meant one more call
  per row. `PastRun` is a non-table model — the basket, `totalMinor` (the receipt if entered, else
  the priced items, zero for a cancelled run), item and unavailable counts, and member → item
  count. The items for every row come from one `inSet` query. The header's "N runs · ₺X through
  the house" is over the rows returned (up to 50), which covers the usage period many times over.
- **`history.get` returns a `BasketEvent` snapshot**, the same shape the live stream opens with, so
  one past run is one call and no socket: a finished run does not change.
- **Screens 29 and 30** group items by requester with prices, list "Ayşe → Kaan ₺85.00" and the
  per-head share of the receipt gap for a settled run, and what was dropped for a cancelled one.
  There is no cancel timestamp on `Basket`, so a cancelled run says when it opened and for how long
  it was booked, not how long it actually ran.

Found while walking it, and fixed here:
- History did not refresh when a run settled or was cancelled — it kept the list it had. The
  lifecycle events and the controller's cancel/settle now invalidate it.
- Cancelling with a few seconds left raced the auto-close: the basket closed, the shopper buttons
  left the screen, and the cancel then touched `ref` after unmount and threw, with nothing shown.
  Shopper actions now read everything before the first await and report a refusal. The confirm is
  a Cupertino alert, like the other iOS sheets.
- The closed-basket footer said "It closed while you were away" to the shopper who had just
  cancelled it. The header already says how it ended (ADR-033); the footer is now just Back.

## ADR-036: Leaving a household marks the member, it does not delete them

`household.leave` used to delete the `household_member` row. Every relation to a member is
`onDelete=Cascade`, so leaving silently deleted the member's items, their settlement lines, and
**every basket they had shopped** — the immutable history of rule 6, and the data the report is
built from. Found while building the settings screen that exposes the button.

Now the row stays and `leftAt` is set:
- `Authz.currentMember` only counts a membership with no `leftAt`, so a former member is outside
  every endpoint exactly as before, and free to create or join another household.
- The settlement split is across current members only; a former member's items still count and
  land on the shopper (ADR-029's rule for a requester who is gone).
- `listMembers(includeFormer: true)` returns everyone, so history, settlements and item rows can
  still name who asked and who paid. The app's `membersProvider` asks for everyone;
  `activeMembersProvider` is the household as it is now, for counts and the member list.
- Rejoining the same household reactivates the old row (the unique index is per household and
  user), so the person's history is theirs again.
- The shopper of a basket that is still open or at the checkout cannot leave
  (`shopperCannotLeave`): nobody else may extend, price or settle it.
- An owner who leaves still hands ownership to the longest-standing current member.

The migration `20260923071920244` adds the column and re-adds the rule 4 partial index by hand
(ADR-013). Two wrong error codes were fixed on the way: a bad currency answered `notTheOwner` and a
bad household name `notAMember`; they are now `invalidCurrency` and `invalidHouseholdName`.

Screens 19 and 20 (settings, currency) are built on this. The design's notification switches are
left out until pushes exist — a switch that turns off nothing is a promise the app does not keep.
Sign out moved from the home screen into settings, reached by a gear on home.

## ADR-037: The local development database runs without the rule 4 index

In development run mode Serverpod 4.0.0 verifies the database against the latest migration's
`definition.json` on every start, and if they differ it throws `ExitException(1)` — the process
exits with code 1 and prints nothing after the "does not match target state" warning. Production
only warns. `definition.json` cannot describe a partial index (ADR-013), so once the hand-written
`basket_one_open_per_household_idx` exists in the local database, the dev server can never start.

It did not bite until 2026-09-23: the earlier migration had been applied locally before the index
was added to it by hand, so the local database never had the index. The next migration's
`CREATE INDEX IF NOT EXISTS` created it, and every start after that died silently. Found with a
verbose run and by reading `serverpod.dart`; a zone guard showed no uncaught error, which is what
pointed at a deliberate exit.

The options were: teach `definition.json` about the index (it has no predicate field, and the next
`create-migration` would then emit a `DROP INDEX` against production — not acceptable for the one
rule with no other enforcement), run locally in another mode, or drop the index from the local
development database only. `scripts/dev_db_unblock.sh` does the last. Rule 4 stays enforced in
production and in `dart test`, whose database is built from `definition.sql` and asserted by
`basket_lifecycle_test`; locally, `basket.open`'s transaction check still gives the right answer
outside a true two-phone race. Reported as Serverpod feedback finding 7 (`docs/SUBMISSION.md`).

## ADR-038: Polish from Days 22-23

- **Rate limits on `addItem`:** twelve a minute and forty per run, per member (`tooManyItems`).
  A list is typed by a person; more is a stuck button or a script, and every phone in the house
  receives each item over the stream. Per member, so one person's burst never blocks another's.
- **"You usually ask for" (screen 24):** `basket.suggestions` returns the names this member has
  asked for at least twice, most often first, counting case- and space-insensitively and returning
  the latest spelling. The add bar shows them as chips when the field is empty and the keyboard is
  down, minus anything already on this run; a tap adds it.
- **Arrival animation:** a row someone else added in the last four seconds slides and fades in;
  your own rows just appear.
- **Last-minute haptic:** one firm tap when the countdown actually crosses into its last minute —
  not when a screen is opened already inside it.

## ADR-039: Code freeze checks (Days 24-25)

- **Every refusal is worded by the app.** `core/failure_message.dart` maps each `BasketError` to
  an `app_en.arb` sentence in a switch with no default, so a new server code does not compile
  until someone words it. Before, each screen mapped the one or two codes it expected and showed
  "Something went wrong" for the rest — settling an unpriced basket said "That didn't save" — and
  the stores screen showed the server's English message, which rule 11 forbids. A dropped
  connection says "Can't reach the basket"; a server that answered with a crash does not.
- **Access tokens last an hour, refresh tokens ninety days (sliding).** The production log showed
  `jwtRefresh` at 3-4.5 s on every call, and the client makes the next request wait for it; with
  the default ten minutes, a run longer than that stalled mid-add. Two Argon2id hashes per
  refresh cost about 60 ms on a laptop, and `JwtConfig` cannot tune them (Serverpod feedback
  finding 8), so the lever left is how often it happens. The cost: a signed-out session stays
  usable for up to an hour. Ninety days, because a household that shops fortnightly should not
  be signed out between runs.
- **Empty states.** A checkout nobody added to says so and how to close it; a settled empty run
  is a valid result, with any receipt total split evenly (rule 6, now tested). A closed basket no
  longer says "No items yet".
- **Dark mode** gets its own destructive red: the light one was 3.4:1 on ink (now 8.3:1, tested).
- **Small screens**: walked in dark mode inside a 375 x 667 frame (iPhone SE) — sign-in, home, the
  open sheet, the live basket with the keyboard up, checkout, settlement, history, settings. No
  overflow. The frame is a local patch to `main.dart`, never committed.
- **Loading skeletons: not built.** Every list here returns in well under a second on a warm
  connection; a skeleton would flash. The spinner stays.
- **Production log scan**: besides the slow refresh, only `.test` addresses failing to receive
  email (our own checks) and `WebSocketConnectionClosed` logged at ERROR on ordinary disconnects
  (Serverpod feedback finding 9). No error from our code.

## ADR-040: The report reads the tables, and only the operator sees every household

- **Source.** The Day 26 figures come from `basket`, `basket_item` and `household_member`, which
  already record how each run ended (`closedAutomatically`, `frozenAt`, `extendCount`) and who
  asked for what and when. `analytics_event` stays the audit trail (rule 8) and a cross-check,
  not the source: counting events would double-count a retried write and miss one that failed,
  which `AnalyticsService.track` is allowed to do.
- **One query, two readers.** `StatsService.headlineSql` takes an optional household. The
  `stats.report` endpoint always passes the caller's; `scripts/report.sql` carries the same text
  with the filter set to NULL. `stats_test` fails if the two differ, and runs every query in the
  script, so the report cannot quietly drift from what the app computes.
- **Scope.** The endpoint never answers for all households. Any signed-in account — a judge's
  included — could otherwise count the houses using the app and see how they shop. Every
  household at once is an operator's question, answered with `psql` and a temporary database
  user that is deleted afterwards.
- **Definitions** that make a figure honest rather than flattering: shares and the join rate
  leave out a run that is still open (its answer is not in yet) and one-person houses (nobody
  else could have joined); chosen duration excludes the five-minute extension; "members" means
  the members in the house when the run opened, which soft leave (ADR-036) makes possible.
- **`docs/REPORT.md`** is drafted with definitions and empty tables. No number goes in until it
  comes out of `report.sql` against production, after real use.

## ADR-041: People name themselves

Found on Day 28 while preparing screenshots: a member's name was the local part of their email,
with no way to change it. On production that puts "kaancan368368 owes ayse.kaya.1990" on a
settlement — the one screen whose whole job is to be read at a glance — and it made the demo
script's "Ayşe owes Kaan" impossible to film. A defect, so fixed after the Day 25 freeze.

- **A better first guess.** `DisplayName.fromEmail`: the first word of the local part, without
  digits, capitalised — "kaancan368368" becomes "Kaancan", "ayse.kaya" becomes "Ayse". A
  provider-supplied full name still wins. Existing members keep the name they have until they
  change it.
- **`household.setMyName`**, any member, 1 to 40 characters, whitespace collapsed; a new
  `invalidMemberName` error. Settings gets a "You" section with the one row.
- **Names are looked up, never copied.** Settlement lines and items store member ids, so a new
  name shows everywhere at once, past runs included. That is the intent: "who owes whom" should
  name the person as the house knows them now.
- Not asked for at sign-up or join: one more field on the first screen costs more than a
  passable default that can be fixed later.

