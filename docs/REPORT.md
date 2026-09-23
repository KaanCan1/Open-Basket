# Usage report

> **Draft.** The tables are empty on purpose: real household use has not started, and every
> number here will come from `scripts/report.sql` run against production, not from memory or
> estimates. Fill them in on Day 26 and delete this note.

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

Period: — to —. Households: —. Members: —.

| Metric | Value |
|---|---|
| Baskets | — |
| Items (per basket) | — (—) |
| **Others joined** | — |
| Member share | — |
| Median time to first item | — s |
| Median time to first item from someone else | — s |
| Average chosen duration | — min |
| Extension rate | — |

| How the open phase ended | Runs |
|---|---|
| Closed by the timer, on the server | — |
| Frozen by hand at the till | — |
| Cancelled | — |

| Where runs ended up | Runs |
|---|---|
| Settled | — |
| Frozen, never settled | — |

## What didn't work

Known before the numbers are in; extend with what the usage log shows.

- **Nobody is told a basket opened.** Push notifications (plan Days 11-12) are not built, so
  "everyone adds" only happens for whoever opens the app. This is the product's central
  promise, and every "others joined" figure above is measured without it.
- **Getting the app onto phones was the bottleneck, not the code.** A free Apple developer
  account installs by cable and expires every seven days, and cannot receive pushes at all.
- **Real use started late.** The build was feature-complete before a single real run, so this
  report covers — days, not the three weeks the plan intended.
- **A session refresh takes 3-4 seconds on Serverpod Cloud** (ADR-039). Access tokens now last
  an hour, so a run stalls at most once — but the first action after a long pause still waits.
