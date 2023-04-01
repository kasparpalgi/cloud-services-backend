alter table "public"."reviews" drop constraint "ratingstars";
alter table "public"."reviews" add constraint "ratingstars" check (CHECK (rating_stars > 0 OR rating_stars < 6));
