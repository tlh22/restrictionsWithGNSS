
-- Add Southwark Zone details to Lines

ALTER TABLE toms."Lines" DISABLE TRIGGER all;

ALTER TABLE IF EXISTS toms."Lines"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE toms."Lines"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE toms."Lines" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE toms."Lines" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

ALTER TABLE toms."Lines" ENABLE TRIGGER all;

--

ALTER TABLE IF EXISTS "import_geojson"."Imported_Lines"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE "import_geojson"."Imported_Lines"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE "import_geojson"."Imported_Lines" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "import_geojson"."Imported_Lines" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

-- Add CPZ

ALTER TABLE IF EXISTS "import_geojson"."Imported_Lines"
  ADD COLUMN IF NOT EXISTS "CPZ" character varying(40) COLLATE pg_catalog."default";

UPDATE "import_geojson"."Imported_Lines"
SET "CPZ" = NULL;

UPDATE "import_geojson"."Imported_Lines" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "import_geojson"."Imported_Lines" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND s."CPZ" IS NULL;
