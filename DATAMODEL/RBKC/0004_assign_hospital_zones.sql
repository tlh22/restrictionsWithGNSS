-- Set up ParkingTariffZones within Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "HospitalZonesBlueBadgeHoldersID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "HospitalZonesBlueBadgeHoldersID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "HospitalZonesBlueBadgeHoldersID" = a."id"
FROM local_authority."HospitalZonesBlueBadgeHolders_2022" a
WHERE ST_WITHIN (s.geom, a.geom);

/***  Assume that covers all required restrictions
UPDATE "mhtc_operations"."Supply" AS s
SET "HospitalZonesBlueBadgeHoldersID" = a."id"
FROM local_authority."HospitalZonesBlueBadgeHolders_2022" a
WHERE ST_Intersects (s.geom, a.geom)
AND "HospitalZonesBlueBadgeHoldersID" IS NOT NULL;
***/