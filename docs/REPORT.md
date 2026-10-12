# Usage report

> **The short version: there was no real household use.** The plan was three weeks of two homes
> using the app and this report measuring them. That did not happen — the app was finished late
> and never left our own phones for daily use. The numbers below are real, read from the
> production database on 2026-10-12 with `scripts/report.sql`, but they are our own test runs on
> Serverpod Cloud, not a household's shopping. They show the measuring works; they do not show
> the product works for anyone. We would rather say that than dress them up.

## What we measured, and why

Open Basket's claim is that a shopping run becomes something the whole house takes part in,
not a list one person carries. So the headline is not how many baskets were opened but whether
**anyone other than the shopper** added to them — "shared attention".

Every figure is computed on the server from what the app already stores (`basket`,
`basket_item`, `household_member`), with `analytics_event` as the audit trail (rule 8). Two
things read the same query: the app's `stats.report` endpoint, which answers for the caller's
own household only, and `scripts/report.sql`, which the operator runs across every household.
A test keeps the two identical (ADR-040).

Our own check households (the accounts used to test sign-in on production) are left out by
hand, and no household is named.

| Metric | Meaning |
|---|---|
| Baskets | Runs opened |
| Items per basket | Items added, over every run including empty ones |
| Others joined | Finished runs in which someone other than the shopper added an item, in houses of two or more |
| Member share | Per finished run, members who asked for something over members in the house; averaged |
| Time to first item | Median seconds from open to the first item, and to the first item from someone else |
| Chosen duration | What the shopper picked, before any extension |
| Extension rate | Runs extended (at most once, ADR-009) |
| How runs ended | Closed by the timer on the server / frozen by hand / cancelled |

## Results

Production, 2026-09-21 to 2026-10-12. **One household, one member** (ours). Every run was a
check made while building, by the same person, on the deployed server.

| Metric | Value |
|---|---|
| Baskets | 10 |
| Items (per basket) | 4 (0.4) |
| **Others joined** | — no second member, so it cannot be measured |
| Member share | 0.3 |
| Median time to first item | 15 s |
| Median time to first item from someone else | — |
| Average chosen duration | 6.6 min |
| Extension rate | 20 % (2 of 10) |

| Chosen duration | Baskets |
|---|---|
| 1 min | 1 |
| 5 min | 6 |
| 10 min | 2 |
| 15 min | 1 |

| How the open phase ended | Runs |
|---|---|
| Closed by the timer, on the server | 5 |
| Frozen by hand at the till | 4 |
| Cancelled | 1 |

| Where runs ended up | Runs |
|---|---|
| Settled | 2 |
| Frozen, never settled | 7 |

What these do show, because they happened on the deployed server rather than on a laptop:

- **The basket closes itself on Serverpod Cloud.** Five of the ten runs were closed by the
  future call at their deadline (`basket_auto_closed` in `analytics_event`), including runs where
  the app had been put in the background.
- **Every state change left its analytics row**: 10 `basket_opened`, 5 `basket_auto_closed`,
  4 `basket_frozen`, 2 `basket_extended`, 2 `basket_settled`, 1 `basket_cancelled`, 4
  `item_added`, 1 `item_marked`, matching the basket table one for one.
- **Seven runs were frozen and never settled.** For checks that is expected — most stopped once
  the close had been seen. In real use it would be the number to watch: it is the step that asks
  the shopper for effort after the shopping is over.

The two-person run in the demo video (Kaan and Ayşe, four members, a ₺1 receipt gap split four
ways) was recorded against a local Serverpod server, not production, so it is not in these
numbers.

## What didn't work


- **Nobody is told a basket opened.** Push notifications (plan Days 11-12) are not built, so
  "everyone adds" only happens for whoever opens the app. This is the product's central
  promise, and every "others joined" figure above is measured without it.
- **Getting the app onto phones was the bottleneck, not the code.** A free Apple developer
  account installs by cable and expires every seven days, and cannot receive pushes at all.
- **Real use never started.** The build was feature-complete before a single real run, and the
  last weeks went into the design set rather than into two homes using it. So the question this
  report was meant to answer — does anyone other than the shopper add to the basket? — is still
  open.
- **A session refresh takes 3-4 seconds on Serverpod Cloud** (ADR-039). Access tokens now last
  an hour, so a run stalls at most once — but the first action after a long pause still waits.
