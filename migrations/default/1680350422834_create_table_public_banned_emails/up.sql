CREATE TABLE "public"."banned_emails" ("id" serial NOT NULL, "email" text NOT NULL, "created_at" timestamptz NOT NULL DEFAULT now(), PRIMARY KEY ("id") , UNIQUE ("email"));
