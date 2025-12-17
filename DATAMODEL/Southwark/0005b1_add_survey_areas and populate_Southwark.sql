


-- Add to Supply

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

-- Add to RestrictionPolygons

ALTER TABLE IF EXISTS toms."RestrictionPolygons"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE toms."RestrictionPolygons"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE toms."RestrictionPolygons" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);
