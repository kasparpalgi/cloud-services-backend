alter table "public"."reviews" drop constraint "ratingstars";
alter table "public"."reviews" add constraint "ratingstars" check (CHECK (rating_stars::numeric > 0::numeric OR rating_stars::numeric < 6::numeric));
