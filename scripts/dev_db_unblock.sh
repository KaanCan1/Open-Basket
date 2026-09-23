#!/usr/bin/env bash
# Lets the local development server start again after a migration re-adds
# the rule 4 partial index to the embedded development database (ADR-037).
#
# Why this exists: in development run mode, Serverpod 4.0.0 compares the
# database with the latest migration's definition.json on every start and,
# if they differ, exits with code 1 and no message (serverpod.dart,
# `_applyMigrations`: `throw ExitException(1)` when not verified in
# development). definition.json cannot describe a partial index, so the
# hand-written `basket_one_open_per_household_idx` (ADR-013) always "differs".
# Production only warns, which is why Serverpod Cloud runs fine with it.
#
# This drops that one index from the LOCAL DEVELOPMENT database only. Rule 4
# stays enforced where it matters: production has it, and `dart test` builds
# its database from definition.sql, where basket_lifecycle_test asserts it.
# Locally, the transaction check in `basket.open` still gives the polite
# answer; only a true two-phone race is unguarded, on a laptop.
#
# Run it after `dart bin/main.dart --apply-migrations` applies a migration and
# the server then exits silently. Needs the embedded database running, which
# the failed start leaves behind; this script stops it again afterwards.
#
#   ./scripts/dev_db_unblock.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="$ROOT/open_basket_server/.serverpod/development"
BIN="$(ls -d "$HOME"/Library/Caches/serverpod/pg-binaries/16.*/macos-arm64/bin 2>/dev/null | tail -1)"

if [[ -z "$BIN" || ! -x "$BIN/psql" ]]; then
  echo "Could not find Serverpod's PostgreSQL binaries under ~/Library/Caches/serverpod." >&2
  exit 1
fi
if [[ ! -f "$DEV/postgres.password" ]]; then
  echo "No embedded development database at $DEV — start the server once first." >&2
  exit 1
fi

# The failed start leaves the embedded postmaster running; if it does not,
# start it just for this.
if ! pgrep -f "$DEV/pgdata" >/dev/null; then
  "$BIN/pg_ctl" -D "$DEV/pgdata" -o "-k $DEV/run -c listen_addresses=''" \
    -l "$DEV/postgres.log" -w start >/dev/null
fi

PGPASSWORD="$(cat "$DEV/postgres.password")" "$BIN/psql" \
  -h "$DEV/run" -U postgres -d open_basket -v ON_ERROR_STOP=1 -q \
  -c 'DROP INDEX IF EXISTS "basket_one_open_per_household_idx";'
echo "Dropped the rule 4 partial index from the local development database."

# Leave nothing running: the server starts its own postmaster, and a stray
# one makes it fail with "Another process is using the local database".
if pgrep -f "$DEV/pgdata" >/dev/null; then
  "$BIN/pg_ctl" -D "$DEV/pgdata" -m fast -w stop >/dev/null || true
fi
echo "Now start the server as usual: dart bin/main.dart --apply-migrations"
