-- Set up ParkingTariffZones within Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "ResidentParkingZoneID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "ResidentParkingZoneID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "ResidentParkingZoneID" = a."id"
FROM local_authority."ResidentParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "ResidentParkingZoneID" = a."id"
FROM local_authority."ResidentParkingZones" a
WHERE ST_Intersects (s.geom, a.geom)
AND "ResidentParkingZoneID" IS NOT NULL;

-- Check

SELECT "GeometryID" 
FROM "mhtc_operations"."Supply" s, local_authority."ResidentParkingZones" a
WHERE ST_Intersects (s.geom, a.geom)
AND "ResidentParkingZoneID" IS NULL;