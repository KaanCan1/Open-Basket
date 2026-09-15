# Architecture decisions

Short entries, newest last. Write one the moment a decision is made — the other developer's
Claude session cannot see anything that is not committed.

## ADR-001: Server owns time

`closesAt` is stored and enforced on the server. The client fetches server time on connect and
renders `closesAt - serverNow`, so a wrong device clock cannot change when a basket closes.

## ADR-002: ETA is computed on the client

The shopper's device reads location once to suggest a duration. The server only ever receives the
chosen store and a number of minutes. Location is never sent, stored or logged.
