alter table "public"."reviews" drop constraint "ratingstars";
alter table "public"."reviews" add constraint "ratingstars" check (rating_stars > 0::numeric OR rating_stars < 6::numeric);
