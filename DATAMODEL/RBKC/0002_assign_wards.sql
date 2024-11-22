-- Set up Wards within Supply

ALTER TABLE IF EXISTS mhtc_operations."Supply"
  ADD COLUMN IF NOT EXISTS "WardID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "WardID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "WardID" = a."id"
FROM local_authority."Wards_2022" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "WardID" = a."id"
FROM local_authority."Wards_2022" a
WHERE ST_Intersects (s.geom, a.geom)
AND "WardID" IS NULL;

-- Check

SELECT "GeometryID" 
FROM "mhtc_operations"."Supply" s, local_authority."Wards_2022" a
WHERE ST_Intersects (s.geom, a.geom)
AND "WardID" IS NULL;