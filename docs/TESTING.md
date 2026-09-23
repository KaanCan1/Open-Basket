# Testing instructions

For the Build Something Real judges. Everything below works against the deployed server
and needs no build, no account approval and no credentials from us.

The project must stay reachable until **20 October 2026, 17:00 CEST**. If anything here
does not work, the fault is ours — please say so rather than assuming a setup step was
missed.

## The fastest path: a browser

Open **https://open-basket.serverpod.space**

That is the Flutter app, built for web and served by the same Serverpod instance that
backs the phones. Nothing to install.

1. **Sign in.** Type any email address you can read mail at and press *Send me a code*.
   There is no password, no registration step and no approval — the address is the
   account. A six-digit code arrives by email within a few seconds. Enter it.
2. **Start a household.** Give it any name. You become its owner, and a six-character
   join code appears on the home screen.
3. **Open a basket.** Press *Open a basket*. Optionally add a store first (*Add a store*); a
   store saved with a location gets a suggested duration, worked out on the device. Pick a
   duration and press *Open for N minutes*. The countdown is rendered from the server's
   clock, not the browser's.
4. **Add items.** Type a name and an optional note, press *Add*. The row appears once the
   server has accepted it and pushed it back down the stream — it is not drawn
   optimistically.
5. **Extend once.** *Extend once* adds five minutes to the deadline and then disables
   itself. One extension per basket, by design.
6. **Check out.** *At checkout* freezes the list: no more items, the countdown stops. As the
   shopper you can already tick items off while the basket is open, by tapping them.
7. **Price it.** *Enter the prices*: type what each item cost, or tap it and choose *Not
   available*. Enter the receipt total if it differs — tax, a bag, a discount.
8. **Settle.** *Work out who owes what*. The server computes the lines: each member owes
   their own items plus an even share of any gap between the items and the receipt, and
   the lines always add up to exactly what was paid. A settled run cannot be changed.
9. **Look back.** *History* on the home screen lists every settled or cancelled run; tap one
   for the full breakdown. *Settings* (the gear) has the household name, currency, stores,
   sign out and leave.

## Seeing the live part, which is the point of the app

The basket is a stream, not a poll. To watch it:

1. Open **https://open-basket.serverpod.space** in a **second window** — a private window,
   a second browser, or a phone.
2. Sign in there with the **same email address**. You will get a fresh code; both sessions
   stay valid.
3. Open the basket on both, then add an item in one.

It appears in the other without a refresh. Extending the timer and checking out travel the
same way.

To do it as two people, sign the second window in with a **different** address and join
with the six-character household code from the first.

## Watching the basket close itself

This is the part that needs a server, and the reason the project is built on Serverpod.

Open a basket for **1 minute** and then **close the browser tab**, or lock the phone. Come
back after it expires: the basket is frozen. Nothing on any device did that — a Serverpod
future call scheduled at the deadline closed it, and it would have fired just the same if
every phone in the household had been switched off.

## Running it on a phone instead

```bash
git clone https://github.com/KaanCan1/Open-Basket.git
cd Open-Basket/open_basket_flutter
flutter run --dart-define=SERVER_URL=https://open-basket.api.serverpod.space/
```

Flutter 3.47.4. The `--dart-define` is what points the build at the deployed server; the
default is a local one.

## What is not built yet

Said plainly so no one hunts for a screen that does not exist:

- **Push notifications, on the phone.** The server side is built — who is told about a new
  basket, the "two minutes left" reminder for whoever has not added anything, and "you owe"
  after settling (ADR-043) — but the app does not register for notifications yet, so none
  arrive. People see a basket when they open the app.
- **Quantity in the add-item bar.** The endpoint takes it; the bar does not offer it yet.
- **One open basket per household at a time.** Deliberate (rule 4), not a missing feature: a
  second *Open a basket* takes you into the one already running.

## If you want to look at the server

- API: `https://open-basket.api.serverpod.space/`
- Source: https://github.com/KaanCan1/Open-Basket
- `docs/ARCHITECTURE.md` records every decision that shaped the build, including the ones
  that turned out wrong.
