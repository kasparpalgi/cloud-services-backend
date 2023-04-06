CREATE TABLE "public"."chat_messages" ("id" serial NOT NULL, "sender_id" integer NOT NULL, "receiver_id" integer NOT NULL, "content" text NOT NULL, "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), PRIMARY KEY ("id") );COMMENT ON TABLE "public"."chat_messages" IS E'Live chat messages';
CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_public_chat_messages_updated_at"
BEFORE UPDATE ON "public"."chat_messages"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_chat_messages_updated_at" ON "public"."chat_messages"
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
