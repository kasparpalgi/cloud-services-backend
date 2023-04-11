CREATE TABLE "public"."transfers" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "recipient" text NOT NULL, "credit_debit" bpchar NOT NULL, "amount" numeric NOT NULL, "created_at" timestamptz NOT NULL DEFAULT now(), PRIMARY KEY ("id") );
CREATE EXTENSION IF NOT EXISTS pgcrypto;
