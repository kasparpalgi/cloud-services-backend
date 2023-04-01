alter table "public"."users" add constraint "mobile_number" check (char_length(mobile_number) >= 7 AND mobile_number ~ '^[\d\-\+\(\)]+$');
