# Design brief

The prompt below is what we feed to Claude Design to generate the screen set. Keep it in sync
with `CLAUDE.md`: if a screen decision changes here, the rule changes there too.

---

Design the screen set for **Open Basket**, an Android-first Flutter app (Material 3, but do not
let it look like stock Material — give it a real visual identity).

**The product.** A live, time-boxed shared shopping basket for families and housemates. One person
is at the store. They open a basket and set a duration — "checkout in 8 minutes". Everyone else in
the household gets a push notification and adds what they need. Items appear instantly on every
device. When the timer runs out the basket closes on the server, even if the app was killed. At
the till the shopper marks what they got, types the prices, and the app works out who owes whom.

The emotional core is a **shared countdown**: a few people briefly paying attention to the same
thing at the same time. The countdown is the hero element of the whole app, not a detail.

**Artboards to produce** (one screen each, phone size, ~390x844):

1. **Sign in** — email sign-in, quiet, gets out of the way.
2. **Create or join a household** — a fork for a brand-new user: create one, or enter a 6-character
   invite code.
3. **Household home, idle** — no basket open. Dominated by one primary action: "Open a basket".
   Shows household name, members, a hint of recent history.
4. **Open basket sheet** — bottom sheet. Pick a store, then duration as quick chips
   (5 / 10 / 15 / 20 min) plus custom. Shows an ETA suggestion the user can override:
   "Estimated 12 min based on your distance to Migros."
5. **Live basket, shopper's view** — the countdown banner at the top ("Checkout in 8:00"), the item
   list below, each row showing who asked for it (small avatar), quantity and an optional note.
   The shopper has an "Extend" control and an "At checkout" button.
6. **Live basket, member's view** — same basket seen by someone at home. No extend, no freeze; has
   the add-item bar (name, quantity, note) pinned at the bottom.
7. **Live basket, final 2 minutes** — the urgent state of screen 5. The countdown shifts colour;
   show how the screen changes tone without turning into an alarm.
8. **Live basket, empty** — basket just opened, nothing added yet. This is the moment that decides
   whether the app works socially, so make the empty state do real work.
9. **Checkout (frozen)** — no new items. Items grouped by the person who asked. Each row gets a
   price field and a "Not available" action. Optional receipt total at the bottom with a gentle
   warning if it does not match the item sum.
10. **Settlement** — the result: "Ayşe owes Kaan ₺84.50". One line per person who owes money, plus
    a share button for a plain-text summary. Calm, final, read-only.
11. **History** — past baskets: store, date, total, who asked for what, how it ended.
12. **Members and invite** — member list, the 6-character invite code, share sheet trigger.
13. **Notifications** — an Android lock screen showing three of ours:
    - "Kaan is heading to Migros. Add what you need in the next 10 min."
    - "2 minutes left on the basket."
    - "You owe Kaan ₺84.50 for today's run."

**Rules that constrain the design:**

- **English only.** Every string in the mockups is English, even though the testers are Turkish.
  Keep the copy short, friendly and action-first. Currency renders as Turkish lira (₺84.50).
- **Money is exact** — two decimals, never a rounded-looking number.
- The countdown always reflects server time, so it must never look editable by a member; only the
  shopper can extend it.
- Basket states are `open → frozen → settled`, plus `cancelled`. The frozen state must read
  visibly as "locked, no more items" without an explanatory paragraph.
- Names in the household are short first names with avatars; assume 2-5 members.
- Design for **dark mode as well as light** — these are people looking at a phone in a shop aisle
  and on a sofa at night.

**What we want back:** a coherent visual system — type scale, colour roles, the countdown
treatment, the item row, the person chip — not twelve unrelated screens. Show the countdown
banner in its three states (normal, final two minutes, frozen) side by side somewhere.

Avoid: generic SaaS purple gradients, stock-Material blue, illustration-heavy empty states,
anything that looks like a template dashboard.
