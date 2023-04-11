alter table "public"."transfers"
  add constraint "transfers_invoice_id_fkey"
  foreign key ("invoice_id")
  references "public"."invoices"
  ("id") on update restrict on delete restrict;
