-- Set up Wards within Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "WardID" INTEGER;

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
AND "WardID" IS NOT NULL;