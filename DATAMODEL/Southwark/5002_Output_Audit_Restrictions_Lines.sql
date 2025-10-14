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

---

SELECT s."GeometryID", s.ogc_fid, s."SouthwarkProposedDeliveryZoneName"
,  CASE WHEN "RestrictionTypeID_new" != "RestrictionTypeID_orig" THEN 'Restriction Type'
		WHEN "NoWaitingTimeID_new" != "NoWaitingTimeID_orig" THEN 'No Waiting Time'
		WHEN "NoLoadingTimeID_new" != "NoLoadingTimeID_orig" THEN 'No Loading Time'
		WHEN ABS(ST_Length(s.geom) - ST_Length(i.geom)) > 2.5 THEN 'Length'
		ELSE 'Unknown' 
	END AS "Reason"
, "RoadName_orig", "RoadName_new"
, "RestrictionDescription_orig", "RestrictionDescription_new"
, "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription_new"
, ST_Length(i.geom) AS "Length orig",  ST_Length(s.geom) AS "Length new"
--s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "NoWaitingTimeID" AS "NoWaitingTimeID_new"
	, "NoLoadingTimeID" AS "NoLoadingTimeID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_new"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_new"
	, a.geom
	, a."LastUpdatePerson"
	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS s,
	(
	SELECT "GeometryID", b.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_orig", "RoadName" AS "RoadName_orig"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "NoWaitingTimeID" AS "NoWaitingTimeID_orig"
	, "NoLoadingTimeID" AS "NoLoadingTimeID_orig"
	, "BayLineTypes"."Description" AS "RestrictionDescription_orig"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_orig"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_orig"
	, b.geom
	FROM "import_geojson"."Imported_Lines" b
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON b."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON b."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON b."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON b."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON b."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS i
WHERE s.ogc_fid = i.ogc_fid
AND
(
"RestrictionTypeID_new" != "RestrictionTypeID_orig"
OR "NoWaitingTimeID_new" != "NoWaitingTimeID_orig"
OR "NoLoadingTimeID_new" != "NoLoadingTimeID_orig"
OR (ABS(ST_Length(s.geom) - ST_Length(i.geom)) > 2.5
	AND "RestrictionTypeID_new" NOT IN (203, 204, 205, 206, 207, 208)
	AND s."LastUpdatePerson" != 'postgres')
)
AND s."SouthwarkProposedDeliveryZoneName" IN ('A', 'B')

UNION 

-- Restrictions that have been added

SELECT s."GeometryID", s.ogc_fid, "SouthwarkProposedDeliveryZoneName"
, 'Added' AS "Reason"
, '' AS "RoadName_orig", "RoadName_new"
, '' AS "RestrictionDescription_orig", "RestrictionDescription_new"
, NULL AS "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription_new"
, NULL AS "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription_new"
, NULL AS "Length orig",  ST_Length(s.geom) AS "Length new"
--, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "NoWaitingTimeID" AS "NoWaitingTimeID_new"
	, "NoLoadingTimeID" AS "NoLoadingTimeID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_new"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_new"
	, a.geom
	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS s
WHERE  s."ogc_fid" IS NULL
AND "SouthwarkProposedDeliveryZoneName" IN ('A', 'B')

UNION

-- Restriction that have been removed

SELECT '' AS s."GeometryID", i.ogc_fid, i."SouthwarkProposedDeliveryZoneName"
, 'Removed' AS "Reason"
, "RoadName_orig", '' AS "RoadName_new"
, "RestrictionDescription_orig", '' AS "RestrictionDescription_new"
, "NoWaitingTimeDescription_orig", NULL AS "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription_orig", NULL AS "NoLoadingTimeDescription_new"
, ST_Length(i.geom) AS "Length orig",  NULL AS "Length new"
--, i.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "NoWaitingTimeID" AS "NoWaitingTimeID_new"
	, "NoLoadingTimeID" AS "NoLoadingTimeID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_new"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_new"
	, a.geom
	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS s FULL OUTER JOIN
	(
	SELECT "GeometryID", b.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_orig", "RoadName" AS "RoadName_orig"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "NoWaitingTimeID" AS "NoWaitingTimeID_orig"
	, "NoLoadingTimeID" AS "NoLoadingTimeID_orig"
	, "BayLineTypes"."Description" AS "RestrictionDescription_orig"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_orig"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_orig"
	, b.geom
	FROM "import_geojson"."Imported_Lines" b
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON b."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON b."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON b."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON b."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON b."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS i
	ON s.ogc_fid = i.ogc_fid
WHERE i.ogc_fid IS NOT NULL
AND s.ogc_fid IS NULL
AND i."SouthwarkProposedDeliveryZoneName" IN ('A', 'B')
