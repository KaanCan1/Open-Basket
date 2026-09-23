# Demo script

**Under two minutes, hard limit.** The Official Rules say "less than two (2) minutes" and
prevail over the BuilderBase page's three (`docs/SUBMISSION.md`). Target **1:50**, so a slow
edit still lands under.

Captions, not narration: every beat below has its on-screen line. English only. No music
with a copyright on it — silence or the room is fine.

**Nothing faked.** Recorded against production (`open-basket.api.serverpod.space`), both
accounts signed in by emailed code. Every cut is marked on screen with the clock visible,
so a judge can see that time passed rather than be told it did. If push notifications are
not built by recording day, beat 2 shows Ayşe opening the app herself — do not mock a
notification.

## The story in one line

Kaan is walking to Migros. He opens a basket for twelve minutes. Ayşe adds what she needs
from the sofa. Kaan's phone dies on the way. The basket closes on time anyway — on the
server. At the till he prices what he found, and the app says who owes whom.

## Shots

Two phones side by side, the same size on screen. Left: **Kaan** (shopper). Right: **Ayşe**.
Status-bar clocks visible on both.

| Time | Left — Kaan | Right — Ayşe | Caption |
|---|---|---|---|
| 0:00–0:08 | Home, "Kaya household" | Home | **One person shops. Everyone adds.** |
| 0:08–0:22 | *Open a basket* → Migros → "Estimated 12 min" → *Open for 12 minutes*. Countdown starts | — | The shopper picks a store. The phone suggests a time; **its location never leaves it.** |
| 0:22–0:40 | Adds "Bread" for himself | Home shows "A basket is open" → *Open it* → tap the *Oat milk* chip → type "Eggs", note "free range" → *Add* | Everyone in the house adds what they need. |
| (same) | Both rows arrive, sliding in | Rows appear | **Live over a Serverpod stream.** |
| 0:40–0:50 | Swipe up, swipe the app away. App gone | Countdown still running | Kaan's phone dies on the way. |
| 0:50–1:02 | **Cut: twelve minutes later**, both status-bar clocks on screen. Still nothing running | Countdown reaches 0:00 → "The basket closed itself at 18:42" | **The server closes it on time. A Serverpod future call — no phone needed.** |
| 1:02–1:10 | Opens the app: the basket is already frozen | — | Nobody's timer. The server's. |
| 1:10–1:35 | *Enter the prices*: Oat milk ₺54.50, Eggs → *Not available*, Bread ₺30.00; receipt total ₺84.50 → *Work out who owes what* | Her open basket turns *Settled*; she opens it | Prices go in once. **The server does the maths** — in whole kuruş, never floating point. |
| 1:35–1:45 | "Ayşe owes Kaan ₺54.50" | Same line | Everyone sees the same answer. |
| 1:45–1:55 | Home | Home | Open Basket — Serverpod + Flutter. open-basket.serverpod.space |

The figures above are placeholders: use whatever the real receipt says, and change the
captions to match. What matters is that the line on screen follows from the prices shown.

## Setup before recording

1. **Accounts.** Two real addresses, signed in on production by emailed code. Display names
   **Kaan** and **Ayşe** with capitals — the settlement line prints them.
2. **Household** "Kaya household", TRY. Store **Migros** saved *with a location*, so the
   estimate appears; stand (or set the simulator location) about a kilometre away.
3. **History, so the chips appear.** Ayşe must have asked for *Oat milk* in at least two
   earlier runs ("You usually ask for" needs two). Do two short real runs the day before.
4. **No basket open or awaiting prices** in the house, or *Open a basket* opens that one.
5. **Duration.** Open it for the real twelve minutes and cut the wait. The cut is honest
   because both status-bar clocks stay on screen across it and the caption says how long
   passed. Do not shorten the basket and caption it as twelve.
6. **Do Not Disturb on both phones**, notifications from other apps off, battery above 20%.
7. Light mode on both. Largest text size off.

## Recording

- **Simulators** (the fallback if the phones are not to hand): iPhone 18 Pro and iPhone 17
  Pro side by side. Record each with `xcrun simctl io <udid> recordVideo left.mov`, then put
  them side by side with `ffmpeg -i left.mov -i right.mov -filter_complex hstack out.mov`.
  Killing the app on a simulator is the same swipe in the app switcher.
- **Real phones**: screen-record on both, start them together, clap once on camera to line
  the two tracks up.
- Keep the raw takes. If the edit runs over 1:55, cut the chip (beat 2) before anything
  else; the future call beat stays whatever happens — it is the reason Serverpod is here.

## What not to say

- Not "everyone is notified" unless push is built and shown working in the take.
- Not "items appear as you type" — they appear when added.
- Not a round number of users or runs. The report has the real ones.

Before recording, walk the whole script once on production and fix anything above that does
not happen exactly as written — the table was written from the code and the simulator walks,
not from a take.
