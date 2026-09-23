# Submission materials

Draft for the BuilderBase submission form. Deadline **14 October 2026, 23:59 CEST**
(00:59 on 15 October in Istanbul). No extensions. Judging runs 15-20 October, so the
project must stay reachable and working until **20 October 17:00 CEST**.

Keep this file in step with what actually ships. Every sentence below is a claim a
judge can check.

---

## Project description

> Paste into the "Project description" field. Rich text is supported.

### Open Basket

**One person shops. Everyone adds.**

Someone is already at the supermarket when the messages start: one in the family
group, one in a private chat, one as a phone call while they are at the till. Something
always gets forgotten, and nobody remembers who paid for what.

Open Basket replaces that with a **basket that is open for a few minutes and then closes
by itself.**

The shopper opens a basket, picks a store and a duration — "checkout in 10 minutes".
Everyone in the household is notified and adds what they need, with a note if it matters
("the glass bottle one"). Items appear on every phone the moment they are added. Two minutes
before the end everyone is told, and the shopper can buy one more five-minute extension.
Then the list is final. At the till the shopper marks what they found and enters the
receipt total, and the server works out who owes whom.

The only thing shared is the remaining time. **Live location is never sent to the server
or stored.** The walking-time estimate is computed on the phone; the server is told the
store and a number of minutes, nothing else.

### How it uses Serverpod

Serverpod is doing the work here, not hosting a form.

- **Future calls close the basket.** When a basket opens, the server schedules a future
  call for its deadline. The basket closes on time whether or not anyone's phone is
  awake, in a tunnel, or switched off — which no client-side timer can promise. Closing
  is idempotent: the call reloads the basket and does nothing unless it is still open
  and genuinely overdue, so a call left over from before an extension fires harmlessly.
  A sweep at startup closes anything a restart lost.
- **Streaming is the live basket.** `Stream<BasketEvent> watch(basketId)` opens a
  WebSocket, subscribes to a `basket:<id>` channel, and sends a full snapshot as its
  first event — so a client that dropped its connection resyncs from the stream itself
  and never needs a second call. Every mutation posts to the channel through
  `session.messages`. Every event carries the server's clock, so the countdown keeps
  correcting for device clock drift.
- **The database schema is the model layer.** Seventeen `.spy.yaml` models generate the
  ORM, the migrations and a fully typed Dart client. Endpoint signatures landed on the
  main branch on day two with `UnimplementedError` bodies, so the Flutter side could be
  built against a compiling, typed client before a single endpoint existed.
- **Settlement is computed on the server**, never on a phone. Money is stored as integer
  minor units with the currency's own minor-unit count — no floating point anywhere near
  a price.
- **Serverpod's auth module** backs a passwordless sign-in: a six-digit code by email,
  ten-minute expiry, three attempts, and requesting a new code kills the old one.
- **Every state change writes an analytics row** from the server, from day two, because
  the usage report at the end is built from that table and a metric added in week three
  has no history behind it.

### How it uses Flutter

One codebase, Android and iOS. Riverpod for state, `go_router` for navigation driven by
the auth state, and every user-facing string through an ARB file so a second language is
a translation rather than a refactor. The design is a system rather than a set of
screens: one paper/ink palette with a single signal colour used only as fill, a
monospace face for every number so countdowns and prices do not jitter as digits change,
and a countdown rendered from server time rather than the device's.

### Details we took seriously

- **The server owns time.** `closesAt` is set and compared on the server, in UTC. The
  client renders `closesAt - serverNow` and nothing else.
- **One open basket per household** is enforced by a partial unique index
  (`WHERE status = 'open'`), not by a read-then-write check — two people tapping at the
  same moment can both read "no open basket" before either inserts. The endpoint
  converts the constraint violation back into the same friendly message someone gets for
  simply tapping too late. There is a test for the race.
- **Authorization on every endpoint.** An unknown basket id and another household's
  basket id return the same error, so nothing can be enumerated. Extending, freezing and
  pricing are shopper-only; editing an item belongs to the person who asked for it.
- **The receipt is the truth.** Item prices are estimates; any gap between them and the
  receipt total is split evenly across every member of the house, with the remainder
  going to the shopper, so the settlement lines always add up to exactly what was paid.

### How it was built

Two developers over four weeks, each working with Claude Code in a separate session that
could not see the other. The repository was the only channel between them: a shared
`CLAUDE.md` holding the product rules, a `PLAN.md` used as the status board, and an
architecture decision record for anything the two sides had to agree on. All endpoint
signatures and data models were frozen on day two so the two halves could be built in
parallel.

**AI disclosure:** this project was built with heavy use of Claude Code (Anthropic) as a
coding assistant, for implementation, review and documentation, and Claude Design for the
interface design. All architectural decisions, the product rules and the final code are
the team's own and were reviewed by us.

**Try it in a browser:** https://open-basket.serverpod.space — no install, no password.
Sign in with any address you can read mail at. Full walkthrough in `docs/TESTING.md`.

Source: https://github.com/KaanCan1/Open-Basket

---

## Checklist before submitting

- [ ] **Demo video under 2:00.** The official rules say "less than two (2) minutes";
      the BuilderBase page says three. Rules section 11: where they disagree, the
      Official Rules prevail. Public on YouTube or Vimeo. No copyrighted music.
- [x] **A judge can actually sign in.** Deployed to Serverpod Cloud on 2026-09-22, which
      manages `scloudAuthEmailKey`, so the six-digit code is delivered by real email.
      Verified end to end against production.
- [x] **Testing instructions written** — `docs/TESTING.md`. Paste it, or its link, into
      the submission's testing field. It leads with the browser build, so a judge needs
      nothing installed.
- [x] **Build and run instructions in the repository.** In `README.md`, including how to
      point a build at production.
- [ ] GitHub repository description filled in (currently empty).
- [ ] Project description above updated to match what actually shipped.
- [ ] **Most Valuable Feedback submission** ($500 cash + $500 credits, one per entrant),
      through the feedback form on BuilderBase. Nine findings so far, all hit in this
      build and all reproducible:
      1. `serverpod_test` 4.0.0 starts the embedded postmaster twice per test group and
         the second attempt cannot attach, because `embedded_postgres_resolver.dart`
         hardcodes `detach: false`. Integration tests are therefore impossible with
         `database.dataPath`, and the failure is reported as the misleading "Another
         process is using the local database" (ADR-003).
      2. `serverpod cloud deploy` cannot handle a project path containing a space. It
         prints the root as `Open%20Basket` and fails with "No files to upload", which
         reads like a `.gitignore` problem (ADR-024).
      3. A defaulted named endpoint parameter (`int quantity = 1`) becomes
         `required int quantity` on the generated client — the default is lost at the
         client boundary (ADR-019).
      4. `.spy.yaml` cannot express a partial index, so a rule like "one open basket per
         household" has to be hand-written into the migration and re-added after every
         regeneration (ADR-013).
      5. The startup schema check reports a hand-written index as **Missing** when the
         live database is the side that has it. The wording points the wrong way and sends
         you looking for a migration that did not fail (ADR-024).
      6. `ClientAuthSessionManager.initialize()` documents that a timeout "returns false
         but does not sign out the user", yet only catches `ServerpodClientException`. The
         `TimeoutException` from its own `.timeout()` escapes, so awaiting it before
         `runApp` — the obvious way to use it — turns a slow server into a permanently
         white app (ADR-026).
      7. In **development** run mode the same schema check is fatal and silent:
         `_applyMigrations` throws `ExitException(1)` when the database does not match,
         with no message after the warning. So a project that follows finding 4's
         workaround — a hand-written partial index, which `definition.json` cannot
         describe — cannot start its dev server at all once that index exists locally.
         Production only warns. It took a verbose run and reading `serverpod.dart` to
         find; a one-line "refusing to start because…" would have saved an afternoon
         (ADR-037).
      8. On Serverpod Cloud, `jwtRefresh.refreshAccessToken` takes 3.0–4.5 s every time
         (production session log, `slow=true`, 11 of 11 calls) and `verifySignInCode`
         about 1.6 s. Each refresh runs two Argon2id hashes in pure Dart; the same
         `Argon2HashUtil` takes about 30 ms per hash on a laptop, so the container's CPU
         is doing the damage. `JwtConfig` offers no way to tune it — `Jwt` builds its
         `Argon2HashUtil` without `parameters` — and the client makes the next call wait
         for the refresh, so with the default ten-minute access token a shopping run
         stalls for seconds halfway through. We lengthened the access token instead
         (ADR-039).
      9. When a client goes away with a stream open — a phone locking its screen —
         Serverpod logs `WebSocketConnectionClosed` at **ERROR** with a nine-frame stack
         trace, from trying to send the close-stream message over the socket that just
         closed. Five in one evening of normal use; in `serverpod cloud log` they bury
         the errors that matter.
- [ ] A public post about the project, tagging Serverpod, during the event period
      (Best Hackathon Post, $500 in credits).
