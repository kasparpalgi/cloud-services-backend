alter table "public"."reviews" drop constraint "ratingstars";
alter table "public"."reviews" add constraint "ratingstars" check (rating_stars::numeric > 0::numeric AND rating_stars::numeric < 6::numeric);
