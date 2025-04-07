-- Set up PTZ within Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN IF NOT EXISTS "ParkingTariffZoneID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "ParkingTariffZoneID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "ParkingTariffZoneID" = a."id"
FROM local_authority."PayByPhoneTariffZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "ParkingTariffZoneID" = a."id"
FROM local_authority."PayByPhoneTariffZones" a
WHERE ST_Intersects (s.geom, a.geom)
AND "ParkingTariffZoneID" IS NULL;

-- check 

SELECT "GeometryID" 
FROM "mhtc_operations"."Supply" s, local_authority."PayByPhoneTariffZones" a
WHERE ST_Intersects (s.geom, a.geom)
AND "ParkingTariffZoneID" IS NULL;