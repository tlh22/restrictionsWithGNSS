-- Set up ParkingTariffZones within Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "ParkingTariffZoneID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "ParkingTariffZoneID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "ParkingTariffZoneID" = a."id"
FROM local_authority."ParkingTariffZones_2022" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "ParkingTariffZoneID" = a."id"
FROM local_authority."ParkingTariffZones_2022" a
WHERE ST_Intersects (s.geom, a.geom)
AND "ParkingTariffZoneID" IS NOT NULL;