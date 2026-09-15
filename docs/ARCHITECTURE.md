# Architecture decisions

Short entries, newest last. Write one the moment a decision is made — the other developer's
Claude session cannot see anything that is not committed.

## ADR-001: Server owns time

`closesAt` is stored and enforced on the server. The client fetches server time on connect and
renders `closesAt - serverNow`, so a wrong device clock cannot change when a basket closes.

## ADR-002: ETA is computed on the client

The shopper's device reads location once to suggest a duration. The server only ever receives the
chosen store and a number of minutes. Location is never sent, stored or logged.

## ADR-003: Local development uses Serverpod's embedded PostgreSQL, not Docker

`config/development.yaml` ships with `dataPath: .serverpod/development/pgdata`, so Serverpod starts
and manages its own PostgreSQL 16 for local development. Running the server is one command and
neither developer needs Docker Desktop, which is what unblocked Day 1 when Docker would not start
on the first machine.

Docker is still used where it makes sense: `docker-compose.yaml` stays in the repo for CI (the
tests workflow starts real Postgres and Redis containers) and for production deployment. Only the
local development database changed.
