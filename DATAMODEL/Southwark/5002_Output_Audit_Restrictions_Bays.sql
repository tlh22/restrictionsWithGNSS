/***

Finding Southwark bays that have been changed in the field

Possible:
 - change of restriction type
 - change of bay shape
 - change of nr bays
 - change of time period
 - change of max stay
 - change of no return
 - change of length (within reason)
 
***/

-- Correct "Free bays"

UPDATE "import_geojson"."Imported_Bays"
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

SELECT s."GeometryID", s.ogc_fid, s."SouthwarkProposedDeliveryZoneName"
,  CASE WHEN "RestrictionTypeID_new" != "RestrictionTypeID_orig" THEN 'Restriction Type'
		WHEN "TimePeriodID_new" != "TimePeriodID_orig" THEN 'Time Period'
		WHEN "NrBays_new" != "NrBays_orig" THEN 'Nr Bays'
		WHEN "MaxStayID_new" != "MaxStayID_orig" THEN 'Max Stay'
		WHEN "NoReturnID_new" != "NoReturnID_orig" THEN 'No Return'
		WHEN ABS(ST_Length(s.geom) - ST_Length(i.geom)) > 2.5 THEN 'Length'
		WHEN "RestrictionShapeTypeID_new" != "RestrictionShapeTypeID_orig" THEN 'Restriction Shape'
		ELSE 'Unknown' 
	END AS "Reason"
, "RoadName_orig", "RoadName_new"
, "RestrictionDescription_orig", "RestrictionDescription_new"
, "RestrictionShapeDescription_orig", "RestrictionShapeDescription_new"
, "NrBays_orig", "NrBays_new"
, "TimePeriodDescription_orig", "TimePeriodDescription_new"
, "MaxStayDescription_orig", "MaxStayDescription_new"
, "NoReturnDescription_orig", "NoReturnDescription_new"
, ST_Length(i.geom) AS "Length orig",  ST_Length(s.geom) AS "Length new"
--, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new", "NrBays" As "NrBays_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "GeomShapeID" AS "RestrictionShapeTypeID_new"
	, "TimePeriodID" AS "TimePeriodID_new", "MaxStayID" AS "MaxStayID_new", "NoReturnID" AS "NoReturnID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription_new"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription_new"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription_new"
	, a.geom
	, a."LastUpdatePerson"
	FROM toms."Bays" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON a."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON a."NoReturnID" is not distinct from "LengthOfTime2"."Code"
	) AS s,
	(
	SELECT "GeometryID", b.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_orig", "RoadName" AS "RoadName_orig", "NrBays" As "NrBays_orig"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "GeomShapeID" AS "RestrictionShapeTypeID_orig"
	, "TimePeriodID" AS "TimePeriodID_orig", "MaxStayID" AS "MaxStayID_orig", "NoReturnID" AS "NoReturnID_orig"
	, "BayLineTypes"."Description" AS "RestrictionDescription_orig"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription_orig"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription_orig"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription_orig"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription_orig"
	, b.geom
	FROM "import_geojson"."Imported_Bays" b
	LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON b."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
	LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON b."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
	 LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON b."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON b."TimePeriodID" is not distinct from "TimePeriods1"."Code"
     LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON b."MaxStayID" is not distinct from "LengthOfTime1"."Code"
	 LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON b."NoReturnID" is not distinct from "LengthOfTime2"."Code"
	) AS i
WHERE s.ogc_fid = i.ogc_fid
AND
(
"RestrictionTypeID_new" != "RestrictionTypeID_orig"
OR "TimePeriodID_new" != "TimePeriodID_orig"
OR "NrBays_new" != "NrBays_orig"
OR "MaxStayID_new" != "MaxStayID_orig"
OR "NoReturnID_new" != "NoReturnID_orig"
OR (ABS(ST_Length(s.geom) - ST_Length(i.geom)) > 2.5
	AND s."LastUpdatePerson" != 'postgres')
OR ABS ("RestrictionShapeTypeID_orig" - "RestrictionShapeTypeID_new") NOT IN (0, 20)
)
AND s."SouthwarkProposedDeliveryZoneName" IN ('A', 'B')

UNION

-- Restrictions that have been added

SELECT s."GeometryID", s.ogc_fid, "SouthwarkProposedDeliveryZoneName"
, 'Added' AS "Reason"
, '' AS "RoadName_orig", "RoadName_new"
, '' AS "RestrictionDescription_orig", "RestrictionDescription_new"
, '' AS "RestrictionShapeDescription_orig", "RestrictionShapeDescription_new"
, NULL AS "NrBays_orig", "NrBays_new"
, '' AS "TimePeriodDescription_orig", "TimePeriodDescription_new"
, '' AS "MaxStayDescription_orig", "MaxStayDescription_new"
, '' AS "NoReturnDescription_orig", "NoReturnDescription_new"
, NULL AS "Length orig",  ST_Length(s.geom) AS "Length new"
--, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new", "NrBays" As "NrBays_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "GeomShapeID" AS "RestrictionShapeTypeID_new"
	, "TimePeriodID" AS "TimePeriodID_new", "MaxStayID" AS "MaxStayID_new", "NoReturnID" AS "NoReturnID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription_new"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription_new"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription_new"
	, a.geom
	FROM toms."Bays" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON a."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON a."NoReturnID" is not distinct from "LengthOfTime2"."Code"
	) AS s
WHERE  s."ogc_fid" IS NULL
AND "SouthwarkProposedDeliveryZoneName" IN ('A', 'B')

UNION

--- Restrictions that have been removed

SELECT '' AS "GeometryID", i.ogc_fid, i."SouthwarkProposedDeliveryZoneName"
, 'Removed' AS "Reason"
, "RoadName_orig", '' AS "RoadName_new"
, "RestrictionDescription_orig", '' AS "RestrictionDescription_new"
, "RestrictionShapeDescription_orig", '' AS "RestrictionShapeDescription_new"
, "NrBays_orig", NULL AS "NrBays_new"
, "TimePeriodDescription_orig", '' AS "TimePeriodDescription_new"
, "MaxStayDescription_orig", '' AS "MaxStayDescription_new"
, "NoReturnDescription_orig", '' AS "NoReturnDescription_new"
, ST_Length(i.geom) AS "Length orig",  NULL AS "Length new"
--, i.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new", "NrBays" As "NrBays_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "GeomShapeID" AS "RestrictionShapeTypeID_new"
	, "TimePeriodID" AS "TimePeriodID_new", "MaxStayID" AS "MaxStayID_new", "NoReturnID" AS "NoReturnID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription_new"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription_new"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription_new"
	, a.geom
	FROM toms."Bays" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON a."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON a."NoReturnID" is not distinct from "LengthOfTime2"."Code"
	) AS s FULL OUTER JOIN 
	(
	SELECT "GeometryID", b.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_orig", "RoadName" AS "RoadName_orig", "NrBays" As "NrBays_orig"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "GeomShapeID" AS "RestrictionShapeTypeID_orig"
	, "TimePeriodID" AS "TimePeriodID_orig", "MaxStayID" AS "MaxStayID_orig", "NoReturnID" AS "NoReturnID_orig"
	, "BayLineTypes"."Description" AS "RestrictionDescription_orig"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription_orig"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription_orig"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription_orig"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription_orig"
	, b.geom
	FROM "import_geojson"."Imported_Bays" b
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON b."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON b."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON b."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON b."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON b."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON b."NoReturnID" is not distinct from "LengthOfTime2"."Code"
	) AS i
	ON s.ogc_fid = i.ogc_fid
WHERE i.ogc_fid IS NOT NULL
AND s.ogc_fid IS NULL
AND i."SouthwarkProposedDeliveryZoneName" IN ('A', 'B')

