alter table "public"."reviews" add constraint "ratingstars" check (rating_stars > 0 OR rating_stars < 6);
