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
