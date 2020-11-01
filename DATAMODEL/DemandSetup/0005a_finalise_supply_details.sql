
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "Capacity" integer;

CREATE TRIGGER "update_capacity_supply" BEFORE INSERT OR UPDATE OF "RestrictionLength", "NrBays" ON "mhtc_operations"."Supply" FOR EACH ROW EXECUTE FUNCTION "public"."update_capacity"();

UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

-- Reset all road names, etc

UPDATE mhtc_operations."Supply" su
SET "RoadName" = s."RoadName",
"StartStreet" = s."StartStreet",
"EndStreet" = s."EndStreet",
"SideOfStreet" = s."SideOfStreet"
FROM mhtc_operations."RC_Sections_merged" s
WHERE su."SectionID" = s.gid


