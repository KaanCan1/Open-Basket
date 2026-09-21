<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/brand/open-basket-white-on-black-banner.png">
  <img alt="Open Basket" src="docs/brand/open-basket-black-on-white-banner.png" width="640">
</picture>

A live, time-boxed shared shopping basket for families and housemates.

The shopper opens a basket and sets a duration ("checkout in 8 minutes"). Everyone in the
household gets a push notification and adds what they need; items appear instantly on every
device. When the time runs out the basket closes **on the server**, even if the app was killed.
At checkout the shopper enters prices and the server works out who owes whom.

The only thing shared is the remaining time. Live location never reaches the server.

Built with Serverpod (streaming, future calls, server-side settlement) and Flutter.

Status: in development. See `PLAN.md` for the build plan and `CLAUDE.md` for project rules.

**Live:** the app is deployed on Serverpod Cloud.

| | |
|---|---|
| API | https://open-basket.api.serverpod.space/ |
| Web | https://open-basket.serverpod.space/ |

Point a build at it with
`flutter run --dart-define=SERVER_URL=https://open-basket.api.serverpod.space/`.

---

## Build and run

### What you need

| Tool | Version | Notes |
|---|---|---|
| Flutter | 3.47.4 (stable) | Brings Dart 3.13.3 with it |
| Dart | the one bundled with Flutter | **Not** a separate Homebrew Dart. Serverpod 4 needs >= 3.10.3 |
| Serverpod CLI | 4.0.0 | `dart pub global activate serverpod_cli` |
| PostgreSQL | none to install | Serverpod starts its own PostgreSQL 16 for development |

If `dart --version` reports a Homebrew install, put `<flutter>/bin` ahead of
`/opt/homebrew/bin` in `PATH`.

```bash
git clone https://github.com/KaanCan1/Open-Basket.git
cd Open-Basket
dart pub get                       # one workspace, all three packages
```

### Secrets

`open_basket_server/config/passwords.yaml` is deliberately not in git. Create it from the
template Serverpod generates, or copy this and replace every value with a long random
string of your own:

```yaml
development:
  database: '<the development database password>'
  serviceSecret: '<random>'
  emailSecretHashPepper: '<random>'
  jwtHmacSha512PrivateKey: '<random>'
  jwtRefreshTokenHashPepper: '<random>'

test:
  database: '<the test database password>'
  emailSecretHashPepper: '<random>'
  jwtHmacSha512PrivateKey: '<random>'
  jwtRefreshTokenHashPepper: '<random>'
```

CI passes the same values as `SERVERPOD_PASSWORD_*` environment variables instead.

### Run the server

```bash
cd open_basket_server
dart bin/main.dart --apply-migrations
```

That starts PostgreSQL, applies the migrations and listens on `localhost:8080`. No Docker
is involved.

### Run the app

```bash
cd open_basket_flutter
flutter run
```

Sign-in is a six-digit code sent by email. **In development nothing is actually emailed —
the code is printed to the server's console.** Enter the address you want, read the code
out of the terminal running the server, and type it in.

### Run the tests

```bash
cd open_basket_server
dart test                       # unit tests need nothing extra
```

Integration tests need a PostgreSQL **15 or newer** separate from the development one, on
port 9090. Either bring up the container CI uses:

```bash
docker compose up -d postgres_test
```

or, on a machine without Docker, use the script that creates a local cluster on the same
port:

```bash
./scripts/local_test_db.sh start
```

Then:

```bash
cd open_basket_server && dart test
cd open_basket_flutter && flutter test
```

`docs/ARCHITECTURE.md` (ADR-003) explains why the embedded database cannot serve the
integration tests.

### Deploying

The server runs on Serverpod Cloud (ADR-024), which manages every password the auth flow
needs — including the key that actually sends the sign-in email.

```bash
cd open_basket_server
serverpod cloud deploy -p open-basket
```

> **Deploy from a path with no spaces in it.** This repository is usually checked out at
> `.../Open Basket`, and the Serverpod Cloud CLI walks the workspace root, prints it as
> `Open%20Basket` and then reports "No files to upload". It is not a `.gitignore`
> problem and a symlink does not help, because the CLI resolves the physical path. Clone
> to a space-free directory and deploy from there, or rename the checkout.

### After changing a model or an endpoint

```bash
cd open_basket_server
serverpod generate               # models and endpoints -> ORM + typed client
serverpod create-migration       # only when the schema changed
```

> **A hand-written index has to survive every migration.** Rule 4 — one open basket per
> household — is enforced by a partial unique index that `.spy.yaml` cannot express, so
> after `serverpod create-migration` it must be re-added by hand to the new migration's
> `definition.sql` *and* `migration.sql`. See ADR-013. `basket_lifecycle_test` fails with
> instructions if it goes missing.

## Repository layout

```
open_basket_server/    Serverpod backend: models, endpoints, future calls, migrations
open_basket_client/    Generated Dart client. Never edited by hand.
open_basket_flutter/   The Flutter app
docs/                  ARCHITECTURE.md (decisions), CONTEXT.md (status), SUBMISSION.md
scripts/               local_test_db.sh
```
