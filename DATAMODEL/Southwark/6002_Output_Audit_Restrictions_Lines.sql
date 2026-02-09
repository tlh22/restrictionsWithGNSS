/***

Finding Southwark lines that have been changed in the field

Possible:
 - change of restriction type
 - change of bay shape
 - change of nr bays
 - change of time period
 - change of max stay
 - change of no return
 - change of length (within reason)
 
***/


---

INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "CPZ"
	, "Reason"
	, "RoadName_orig"
	, "RoadName_new"
	, "RestrictionDescription_orig"
	, "RestrictionDescription_new"
	, "NoWaitingTimeDescription_orig"
	, "NoWaitingTimeDescription_new"
	, "NoLoadingTimeDescription_orig"
	, "NoLoadingTimeDescription_new"
	, "Length orig", "Length new", geom)

SELECT "GeometryID"
, ogc_fid
, "SouthwarkProposedDeliveryZoneName"
, "CPZ"
, "Reason"
, "RoadName_orig", "RoadName_new"
, "RestrictionDescription_orig", "RestrictionDescription_new"
, "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription_new"
, "Length orig",  "Length new"
, geom

FROM 
(

SELECT s."GeometryID"
, s.ogc_fid
, s."SouthwarkProposedDeliveryZoneName"
, s."CPZ"
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
, s.geom
FROM
	(
	SELECT "GeometryID"
	, a.ogc_fid
	, "RestrictionTypeID" AS "RestrictionTypeID_new"
	, "RoadName" AS "RoadName_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
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
	SELECT "GeometryID"
	, b.ogc_fid
	, "RestrictionTypeID" AS "RestrictionTypeID_orig"
	, "RoadName" AS "RoadName_orig"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
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
--AND s."SouthwarkProposedDeliveryZoneName" IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K')

UNION 

-- Restrictions that have been added

SELECT s."GeometryID"
, s.ogc_fid
, "SouthwarkProposedDeliveryZoneName"
, "CPZ"
, 'Added' AS "Reason"
, '' AS "RoadName_orig", "RoadName_new"
, '' AS "RestrictionDescription_orig", "RestrictionDescription_new"
, NULL AS "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription_new"
, NULL AS "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription_new"
, NULL AS "Length orig",  ST_Length(s.geom) AS "Length new"
, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
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
AND s."RestrictionTypeID_new" NOT IN (209, 210, 211, 212, 213, 214, 215)  -- do not include crossings that have been added
--AND "SouthwarkProposedDeliveryZoneName" IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K')

UNION

-- Restriction that have been removed

SELECT '' AS "GeometryID", i.ogc_fid
, i."SouthwarkProposedDeliveryZoneName"
, i."CPZ"
, 'Removed' AS "Reason"
, "RoadName_orig", '' AS "RoadName_new"
, "RestrictionDescription_orig", '' AS "RestrictionDescription_new"
, "NoWaitingTimeDescription_orig", NULL AS "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription_orig", NULL AS "NoLoadingTimeDescription_new"
, ST_Length(i.geom) AS "Length orig",  NULL AS "Length new"
, i.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID" AS "RestrictionTypeID_new", "RoadName" AS "RoadName_new"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
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
	, COALESCE("CPZ", '')  AS "CPZ"
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
--AND i."SouthwarkProposedDeliveryZoneName" IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K')


/***
Also need restrictions for which there are other issues
 - missing sign 
 - faded markings
 
***/

UNION

SELECT "GeometryID", s.ogc_fid
, s."SouthwarkProposedDeliveryZoneName"
, s."CPZ"
, "Restriction_SignIssue_Description" AS "Reason"
, "RoadName" AS "RoadName_orig", "RoadName" AS "RoadName_new"    -- to avoid confusion, use the same details for old and new.
, "RestrictionDescription" AS "RestrictionDescription_orig", "RestrictionDescription" AS "RestrictionDescription_new"
, "NoWaitingTimeDescription" AS "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription" AS "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription" AS "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription" AS "NoLoadingTimeDescription_new"
, ST_Length(s.geom) AS "Length orig",  ST_Length(s.geom) AS "Length new"
, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID", "RoadName"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
	, "NoWaitingTimeID" 
	, "NoLoadingTimeID" 
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription"
	, "ComplianceRoadMarkingsFaded"
	, "ComplianceLoadingMarkingsFaded"
	, "ComplianceRestrictionSignIssue"
	, "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description"
	, a.geom
	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
		LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" IS NOT DISTINCT FROM "Restriction_SignIssueTypes"."Code"
	) AS s 
	
WHERE s."ComplianceRestrictionSignIssue" In (2,3,4,6)
-- AND s."SouthwarkProposedDeliveryZoneName" IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K')


) d
;

/***
WHERE d."GeometryID" NOT IN (
	SELECT "LinkedTo"
	FROM mhtc_operations."SignRestrictionLink" l, toms."Signs" s 
	WHERE l."GeometryID" = s."GeometryID"
	AND s."ComplianceRestrictionSignIssue" > 1
	)
***/

ALTER TABLE IF EXISTS mhtc_operations."Restrictions_Audit_Condition_Issues"
    ADD COLUMN IF NOT EXISTS "NoWaitingTimeDescription_orig" character varying COLLATE pg_catalog."default";
ALTER TABLE IF EXISTS mhtc_operations."Restrictions_Audit_Condition_Issues"
    ADD COLUMN IF NOT EXISTS "NoWaitingTimeDescription_new" character varying COLLATE pg_catalog."default";	
ALTER TABLE IF EXISTS mhtc_operations."Restrictions_Audit_Condition_Issues"
    ADD COLUMN IF NOT EXISTS "NoLoadingTimeDescription_orig" character varying COLLATE pg_catalog."default";
ALTER TABLE IF EXISTS mhtc_operations."Restrictions_Audit_Condition_Issues"
    ADD COLUMN IF NOT EXISTS "NoLoadingTimeDescription_new" character varying COLLATE pg_catalog."default";
	
INSERT INTO mhtc_operations."Restrictions_Audit_Condition_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "CPZ"
	, "Reason"
	, "RoadName_orig"
	, "RoadName_new"
	, "RestrictionDescription_orig"
	, "RestrictionDescription_new"
	, "NoWaitingTimeDescription_orig"
	, "NoWaitingTimeDescription_new"
	, "NoLoadingTimeDescription_orig"
	, "NoLoadingTimeDescription_new"
	, "Length orig", "Length new", geom)

SELECT "GeometryID"
, ogc_fid
, "SouthwarkProposedDeliveryZoneName"
, "CPZ"
, "Reason"
, "RoadName_orig", "RoadName_new"
, "RestrictionDescription_orig", "RestrictionDescription_new"
, "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription_new"
, "Length orig",  "Length new"
, geom

FROM 

(

SELECT "GeometryID"
, s.ogc_fid
, s."SouthwarkProposedDeliveryZoneName"
, s."CPZ"
, 'Faded Restriction Markings' AS "Reason"
, "RoadName" AS "RoadName_orig", "RoadName" AS "RoadName_new"    -- to avoid confusion, use the same details for old and new.
, "RestrictionDescription" AS "RestrictionDescription_orig", "RestrictionDescription" AS "RestrictionDescription_new"
, "NoWaitingTimeDescription" AS "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription" AS "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription" AS "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription" AS "NoLoadingTimeDescription_new"
, ST_Length(s.geom) AS "Length orig",  ST_Length(s.geom) AS "Length new"
, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID", "RoadName"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
	, "NoWaitingTimeID" 
	, "NoLoadingTimeID" 
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription"
	, "ComplianceRoadMarkingsFaded"
	, "ComplianceLoadingMarkingsFaded"
	, "ComplianceRestrictionSignIssue"
	, a.geom
	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS s 

WHERE COALESCE(s."ComplianceRoadMarkingsFaded", 0) > 1 
-- AND s."SouthwarkProposedDeliveryZoneName" IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K')

UNION

SELECT "GeometryID", s.ogc_fid
, s."SouthwarkProposedDeliveryZoneName"
, s."CPZ"
, 'Faded Loading Markings' AS "Reason"
, "RoadName" AS "RoadName_orig", "RoadName" AS "RoadName_new"    -- to avoid confusion, use the same details for old and new.
, "RestrictionDescription" AS "RestrictionDescription_orig", "RestrictionDescription" AS "RestrictionDescription_new"
, "NoWaitingTimeDescription" AS "NoWaitingTimeDescription_orig", "NoWaitingTimeDescription" AS "NoWaitingTimeDescription_new"
, "NoLoadingTimeDescription" AS "NoLoadingTimeDescription_orig", "NoLoadingTimeDescription" AS "NoLoadingTimeDescription_new"
, ST_Length(s.geom) AS "Length orig",  ST_Length(s.geom) AS "Length new"
, s.geom
FROM
	(
	SELECT "GeometryID", a.ogc_fid, "RestrictionTypeID", "RoadName"
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, COALESCE("CPZ", '')  AS "CPZ"
	, "NoWaitingTimeID" 
	, "NoLoadingTimeID" 
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription"
	, "ComplianceRoadMarkingsFaded"
	, "ComplianceLoadingMarkingsFaded"
	, "ComplianceRestrictionSignIssue"
	, a.geom
	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
	) AS s 

WHERE COALESCE(s."ComplianceLoadingMarkingsFaded", 0) > 1 
-- AND s."SouthwarkProposedDeliveryZoneName" IN ('C', 'D', 'E', 'F', 'G', 'G', 'I', 'J')

) p
WHERE p."GeometryID" NOT IN (SELECT "GeometryID"
                           FROM mhtc_operations."Restrictions_Audit_Issues")