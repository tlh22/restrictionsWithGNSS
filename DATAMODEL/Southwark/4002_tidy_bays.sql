-- Correct "Free bays"

UPDATE "import_geojson"."Imported_Bays"
SET "RestrictionTypeID" = 126
WHERE "RestrictionTypeID" = 127
AND "MaxStayID" > 0;

UPDATE "toms"."Bays"
SET "RestrictionTypeID" = 126
WHERE "RestrictionTypeID" = 127
AND "MaxStayID" > 0;

-- Add Southwark Zone details to Bays

ALTER TABLE toms."Bays" DISABLE TRIGGER all;

ALTER TABLE IF EXISTS toms."Bays"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE toms."Bays"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE toms."Bays" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE toms."Bays" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

ALTER TABLE toms."Bays" ENABLE TRIGGER all;

--

ALTER TABLE IF EXISTS "import_geojson"."Imported_Bays"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE "import_geojson"."Imported_Bays"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE "import_geojson"."Imported_Bays" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "import_geojson"."Imported_Bays" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

--
-- set road details

/***

ALTER TABLE toms."Bays" ADD COLUMN IF NOT EXISTS "SectionID" integer;

UPDATE toms."Bays" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM toms."Bays" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

***/