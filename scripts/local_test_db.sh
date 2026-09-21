#!/usr/bin/env bash
# Starts a local PostgreSQL 16 for `dart test`, on the port config/test.yaml
# already expects. No Docker.
#
# Why this exists: integration tests cannot use the embedded database that
# development uses (ADR-003). `serverpod_test` brings the embedded postmaster
# up twice per group -- once to create the ephemeral database, once when the
# pod starts -- and the second attempt cannot attach to the first, because
# `embedded_postgres_resolver.dart` starts it with `detach: false`. The second
# start hits the live `postmaster.pid` and reports "Another process is using
# the local database". That is a framework limitation in Serverpod 4.0.0, not
# something the project can configure around.
#
# CI brings the same database up from docker-compose.yaml. This script is the
# equivalent for a machine where Docker does not run.
#
#   ./scripts/local_test_db.sh start     # first run also creates the cluster
#   ./scripts/local_test_db.sh stop
#   ./scripts/local_test_db.sh status
#
# The cluster lives under open_basket_server/.serverpod/, which is gitignored,
# and is separate from any PostgreSQL Homebrew may already be running.
set -euo pipefail

PORT=9090
DB=open_basket_test
USER=postgres
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER="$ROOT/open_basket_server/.serverpod/local-test-db"
PGDATA="$CLUSTER/pgdata"
LOG="$CLUSTER/postgres.log"

PGBIN=""
for candidate in \
  /opt/homebrew/opt/postgresql@16/bin \
  /usr/local/opt/postgresql@16/bin \
  /usr/lib/postgresql/16/bin; do
  [ -x "$candidate/pg_ctl" ] && PGBIN="$candidate" && break
done

if [ -z "$PGBIN" ]; then
  echo "PostgreSQL 16 not found. Install it with:" >&2
  echo "  brew install postgresql@16" >&2
  # Serverpod 4 reads pg_index.indnullsnotdistinct, which arrived in
  # PostgreSQL 15. An older server fails while applying migrations, with
  # 'column "indnullsnotdistinct" does not exist'.
  echo "Versions below 15 will not work." >&2
  exit 1
fi

# initdb refuses to run when the process has gone multithreaded, which the
# default locale can trigger on macOS: "postmaster became multithreaded
# during startup".
export LC_ALL=C

case "${1:-start}" in
  start)
    if [ ! -d "$PGDATA" ]; then
      echo "Creating the test cluster in $PGDATA"
      mkdir -p "$CLUSTER"
      "$PGBIN/initdb" -D "$PGDATA" -U "$USER" --auth=trust >/dev/null
    fi

    if "$PGBIN/pg_isready" -h localhost -p "$PORT" >/dev/null 2>&1; then
      echo "Already listening on port $PORT."
    else
      "$PGBIN/pg_ctl" -D "$PGDATA" -o "-p $PORT" -l "$LOG" start
    fi

    "$PGBIN/createdb" -h localhost -p "$PORT" -U "$USER" "$DB" 2>/dev/null \
      && echo "Created database $DB." \
      || echo "Database $DB is already there."

    echo
    echo "Ready. Run the tests with:"
    echo "  cd open_basket_server && dart test"
    ;;
  stop)
    "$PGBIN/pg_ctl" -D "$PGDATA" stop
    ;;
  status)
    "$PGBIN/pg_isready" -h localhost -p "$PORT"
    ;;
  *)
    echo "Usage: $0 {start|stop|status}" >&2
    exit 1
    ;;
esac
