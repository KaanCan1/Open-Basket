BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "analytics_event" (
    "id" bigserial PRIMARY KEY,
    "type" text NOT NULL,
    "householdId" bigint,
    "basketId" bigint,
    "memberId" bigint,
    "payload" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "analytics_type_idx" ON "analytics_event" USING btree ("type", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "basket" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "shopperMemberId" bigint NOT NULL,
    "storeId" bigint,
    "status" text NOT NULL DEFAULT 'open'::text,
    "openedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closesAt" timestamp without time zone NOT NULL,
    "frozenAt" timestamp without time zone,
    "closedAutomatically" boolean NOT NULL DEFAULT false,
    "extendCount" bigint NOT NULL DEFAULT 0,
    "receiptTotalMinor" bigint,
    "currencyCode" text NOT NULL DEFAULT 'TRY'::text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "basket_item" (
    "id" bigserial PRIMARY KEY,
    "basketId" bigint NOT NULL,
    "requesterMemberId" bigint NOT NULL,
    "name" text NOT NULL,
    "quantity" bigint NOT NULL DEFAULT 1,
    "note" text,
    "status" text NOT NULL DEFAULT 'requested'::text,
    "priceMinor" bigint,
    "addedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "device_token" (
    "id" bigserial PRIMARY KEY,
    "userId" uuid NOT NULL,
    "token" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "device_token__token__unique_idx" ON "device_token" USING btree ("token");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "household" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "currencyCode" text NOT NULL DEFAULT 'TRY'::text,
    "code" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "household__code__unique_idx" ON "household" USING btree ("code");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "household_member" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "userId" uuid NOT NULL,
    "displayName" text NOT NULL,
    "role" text NOT NULL DEFAULT 'member'::text,
    "notifyBasketOpened" boolean NOT NULL DEFAULT true,
    "notifyClosingSoon" boolean NOT NULL DEFAULT true,
    "notifySettlementReady" boolean NOT NULL DEFAULT true,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "member_unique_idx" ON "household_member" USING btree ("householdId", "userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "settlement_line" (
    "id" bigserial PRIMARY KEY,
    "basketId" bigint NOT NULL,
    "fromMemberId" bigint NOT NULL,
    "toMemberId" bigint NOT NULL,
    "amountMinor" bigint NOT NULL,
    "itemsMinor" bigint NOT NULL,
    "receiptGapMinor" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sign_in_code" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "codeHash" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "attemptsRemaining" bigint NOT NULL DEFAULT 3,
    "consumedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "sign_in_code_email_idx" ON "sign_in_code" USING btree ("email", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "store" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "name" text NOT NULL,
    "lat" double precision,
    "lng" double precision,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "basket"
    ADD CONSTRAINT "basket_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "basket"
    ADD CONSTRAINT "basket_fk_1"
    FOREIGN KEY("shopperMemberId")
    REFERENCES "household_member"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "basket"
    ADD CONSTRAINT "basket_fk_2"
    FOREIGN KEY("storeId")
    REFERENCES "store"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "basket_item"
    ADD CONSTRAINT "basket_item_fk_0"
    FOREIGN KEY("basketId")
    REFERENCES "basket"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "basket_item"
    ADD CONSTRAINT "basket_item_fk_1"
    FOREIGN KEY("requesterMemberId")
    REFERENCES "household_member"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "household_member"
    ADD CONSTRAINT "household_member_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "settlement_line"
    ADD CONSTRAINT "settlement_line_fk_0"
    FOREIGN KEY("basketId")
    REFERENCES "basket"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "settlement_line"
    ADD CONSTRAINT "settlement_line_fk_1"
    FOREIGN KEY("fromMemberId")
    REFERENCES "household_member"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "settlement_line"
    ADD CONSTRAINT "settlement_line_fk_2"
    FOREIGN KEY("toMemberId")
    REFERENCES "household_member"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "store"
    ADD CONSTRAINT "store_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR open_basket
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('open_basket', '20260917085420223', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260917085420223', "timestamp" = now();

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
