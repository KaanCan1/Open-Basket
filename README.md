# Open Basket

A live, time-boxed shared shopping basket for families and housemates.

The shopper opens a basket and sets a duration ("checkout in 8 minutes"). Everyone in the
household gets a push notification and adds what they need; items appear instantly on every
device. When the time runs out the basket closes **on the server**, even if the app was killed.
At checkout the shopper enters prices and the server works out who owes whom.

The only thing shared is the remaining time. Live location never reaches the server.

Built with Serverpod (streaming, future calls, server-side settlement) and Flutter.

Status: in development. See `PLAN.md` for the build plan and `CLAUDE.md` for project rules.
