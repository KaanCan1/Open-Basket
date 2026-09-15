---
description: Pick up today's tasks from PLAN.md and start working
---

Read `PLAN.md` and `CLAUDE.md`, then:

1. Work out which day number we are on. Day 1 = Tue 15 September 2026. If the calendar has
   slipped ahead of the checkboxes, trust the checkboxes: the first day with unticked tasks is
   the day we are actually on.
2. Run `git log --oneline -15` to see what the other developer has landed since yesterday.
3. List the unticked tasks for that day, split by owner (A = backend, B = Flutter). Say which
   ones are mine based on what I tell you, or ask if it is not obvious.
4. Flag anything that is blocked on the other person, and anything the plan marks as pair work.
5. Start on the first task that is mine: branch `feat/<short-name>` off `main`, implement, test.
6. When a task is done, tick its checkbox in `PLAN.md` in the same commit.
