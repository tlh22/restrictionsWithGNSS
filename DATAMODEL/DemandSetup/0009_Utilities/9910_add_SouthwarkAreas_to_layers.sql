ALTER TABLE IF EXISTS mhtc_operations."Supply"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

-- CPZs

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom)
AND s."CPZ" IS NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "NoWaitingTimeID" = a."TimePeriodID"
FROM toms."ControlledParkingZones" a
WHERE s."CPZ" = a."CPZ"
AND s."RestrictionTypeID" = 201
AND (s."NoWaitingTimeID" = 0 OR s."NoWaitingTimeID" IS NULL);

/***

Add Southwark Areas to roadlink

***/

ALTER TABLE "highways_network"."roadlink"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" integer;

UPDATE "highways_network"."roadlink" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "highways_network"."roadlink" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;