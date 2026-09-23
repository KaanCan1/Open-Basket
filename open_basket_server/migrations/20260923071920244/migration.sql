BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "household_member" ADD COLUMN "leftAt" timestamp without time zone;

--
-- HAND-WRITTEN. NOT GENERATED. Rule 4: one open basket per household.
--
-- `.spy.yaml` has no partial index, and a plain unique index on "householdId"
-- would allow a household exactly one basket ever. The transaction check in
-- BasketEndpoint.open is only the polite answer; two concurrent calls can both
-- read "no open basket" before either inserts. This index is what actually
-- stops the second one, and `open` turns the violation back into
-- householdAlreadyHasOpenBasket by matching on this name.
--
-- A fresh database is built from THIS file (definition.sql), not from the
-- migration.sql files, so the index has to live in both. `serverpod
-- create-migration` regenerates definition.sql from the models, which do not
-- know about this index -- so it must be re-added by hand to every new
-- migration. `basket_lifecycle_test` asserts the index exists, and fails the
-- build if a regeneration drops it.
--
CREATE UNIQUE INDEX IF NOT EXISTS "basket_one_open_per_household_idx"
    ON "basket" ("householdId")
    WHERE "status" = 'open';

--
-- MIGRATION VERSION FOR open_basket
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('open_basket', '20260923071920244', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260923071920244', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();


COMMIT;
