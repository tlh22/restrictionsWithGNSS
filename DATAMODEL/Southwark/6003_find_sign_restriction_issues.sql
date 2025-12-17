/***

-- Now check to see whether there are restrictions without signs

***/

INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
	"GeometryID", ogc_fid, "SouthwarkProposedDeliveryZoneName", "Reason"
	, "RoadName_new"
	, "RestrictionDescription_new"
	, "RestrictionShapeDescription_new"
	, "NrBays_new"
	, "TimePeriodDescription_new"
	, "MaxStayDescription_new"
	, "NoReturnDescription_new"
	, "Length new"
	, geom)

SELECT r."GeometryID"
	, r.ogc_fid
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, 'Missing Sign' AS "Reason"
	, "RoadName" AS "RoadName_new"
	,"BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription"
	, "NrBays" AS "NrBays_new"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription"
	, ST_Length(r.geom) As "Length new"
	, r.geom
FROM toms."Bays" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON r."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON r."NoReturnID" is not distinct from "LengthOfTime2"."Code"
WHERE r."GeometryID" NOT IN (
	SELECT "LinkedTo"
	FROM mhtc_operations."SignRestrictionLink"
	)
AND r."RestrictionTypeID" NOT IN (107, 116, 118, 119, 147, 154, 168)  -- ignore certain bay types
AND COALESCE(r."ComplianceRestrictionSignIssue", 1) = 1 -- ignore situations where an issues is alrady identified

-- Take account of permit holder bays withhin PPA

AND r."GeometryID" NOT IN (
	SELECT b."GeometryID"
	FROM toms."Bays" b, toms."RestrictionPolygons" p 
	WHERE ST_Within(b.geom, p.geom)
	AND b."RestrictionTypeID" = 131
	AND p."RestrictionTypeID" = 2 -- PPA
	) 

AND COALESCE(r."MHTC_CheckIssueTypeID", 0) <= 1

ORDER BY "GeometryID"
;

-- Now check Lines


INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "Reason"
	, "RoadName_new"
	, "RestrictionDescription_new" 
	, "NoWaitingTimeDescription_new"
	, "NoLoadingTimeDescription_new"
	, "Length new"
	, geom)

SELECT r."GeometryID"
	, r.ogc_fid 
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, 'Missing Sign' AS "Reason"
	, "RoadName" AS "RoadName_new"
	,"BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_new"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_new"
	, ST_Length(r.geom) As "Length new"
	, r.geom
FROM toms."Lines" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON r."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
WHERE r."GeometryID" NOT IN (
	SELECT "LinkedTo"
	FROM mhtc_operations."SignRestrictionLink"
	)
AND r."RestrictionTypeID" NOT IN (202, 209, 210, 211, 212, 213, 214, 215, 216, 220, 225, 227, 228, 229)  -- ignore DYLs, crossings and unmarked
AND COALESCE(r."ComplianceRestrictionSignIssue", 1) = 1  -- ignore situations where an issue is already identified

-- Take account of SYLs withhin CPZs with the same time period

AND r."GeometryID" NOT IN (
	SELECT b."GeometryID"
	FROM toms."Lines" b, toms."ControlledParkingZones" p 
	WHERE ST_Within(b.geom, p.geom)
	AND b."RestrictionTypeID" IN (201, 221, 224)
	AND p."RestrictionTypeID" = 20 -- CPZ
	AND b."NoWaitingTimeID" = p."TimePeriodID"
	) 

-- remove any which are currently being reviewed

AND COALESCE(r."MHTC_CheckIssueTypeID", 0) <= 1

ORDER BY "GeometryID"
;

-- Check loading ...

INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "Reason"
	, "RoadName_new"
	, "RestrictionDescription_new" 
	, "NoWaitingTimeDescription_new"
	, "NoLoadingTimeDescription_new"
	, "Length new"
	, geom)

SELECT r."GeometryID"
	, r.ogc_fid
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, 'Missing Sign' AS "Reason"
	, "RoadName" AS "RoadName_new"
	,"BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_new"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_new"
	, ST_Length(r.geom) As "Length new"
	, r.geom
FROM toms."Lines" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON r."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
WHERE r."GeometryID" NOT IN (
	SELECT "LinkedTo"
	FROM mhtc_operations."SignRestrictionLink" l, toms."Signs" s
	WHERE l."GeometryID" = s."GeometryID"
	-- And with signs that have loading details
	AND (
		s."SignType_1" IN (21,23) OR
		s."SignType_2" IN (21,23) OR
		s."SignType_3" IN (21,23) OR
		s."SignType_4" IN (21,23)
	)
)
AND r."RestrictionTypeID" IN (201, 202, 220, 224)  -- only SYLs and DYLs
AND COALESCE(r."ComplianceRestrictionSignIssue", 1) = 1  -- ignore situations where an issue is already identified

-- remove any which are currently being reviewed

AND COALESCE(r."MHTC_CheckIssueTypeID", 0) <= 1

-- Now consider only those restrictions with loading other than "At Any Time"
AND COALESCE(r."NoLoadingTimeID", 0) > 1

ORDER BY "RoadName"
;


-- Consider issues for spaces of signs for restrictions

ALTER TABLE IF EXISTS mhtc_operations."Restrictions_Audit_Issues"
    ADD COLUMN IF NOT EXISTS "Notes" character varying COLLATE pg_catalog."default";

--

INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "Reason"
	, "RoadName_new"
	, "RestrictionDescription_new" 
	, "RestrictionShapeDescription_new"
	, "NrBays_new"
	, "TimePeriodDescription_new"
	, "MaxStayDescription_new"
	, "NoReturnDescription_new"
	, "Length new" 
	, "Notes"
	, geom)

SELECT "GeometryID"
	, ogc_fid 
	, "SouthwarkProposedDeliveryZoneName"
	,  CASE WHEN "CurrNrSigns" > 0 THEN 'Number of signs in restriction'
			ELSE 'Distance from start/end to sign'
		END AS "Reason"
	, "RoadName"
	, "RestrictionDescription"
	, "RestrictionShapeDescription"
	, "NrBays"
	, "TimePeriodDescription"
	, "MaxStayDescription"
	, "NoReturnDescription"
	, "Length new"
	,  CASE WHEN "CurrNrSigns" > 0 THEN CONCAT('Required: ', "RequiredNrSigns" , ' - Current: ', "CurrNrSigns")
		ELSE CONCAT('Shortest distance is ', ROUND("Distance to sign"::numeric,1))
		END AS "Notes"
	, geom
		
FROM (

-- Consider distance between signs for Bays - use 30.0m

SELECT DISTINCT ON (r."GeometryID") r."GeometryID"
	, r.ogc_fid
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "RoadName"
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription"
	, "NrBays"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription"
	, FLOOR (ST_Length(r.geom)/35.0) As "RequiredNrSigns" 
	, CASE WHEN true THEN (SELECT COUNT(*)
					FROM mhtc_operations."SignRestrictionLink" l
					WHERE l."LinkedTo" = r."GeometryID")
			ELSE 0
		END AS "CurrNrSigns"
	, 0 As "Distance to sign"		
	, ST_Length(r.geom) AS "Length new"
	, r.geom
FROM  toms."Bays" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON r."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON r."NoReturnID" is not distinct from "LengthOfTime2"."Code"
WHERE FLOOR (ST_Length(r.geom)/35.0) > (SELECT COUNT(*) AS Nr
										  FROM mhtc_operations."SignRestrictionLink" l
										  WHERE l."LinkedTo" = r."GeometryID"
										  HAVING COUNT(*) > 0)
AND r."RestrictionTypeID" IN (105, 131)  -- Only check for Shared Use and permit holder bays

-- remove any which are currently being reviewed

AND COALESCE(r."MHTC_CheckIssueTypeID", 0) <= 1
AND ST_Length(r.geom) > 35.0

-- Sign not within 15m of bay start/end
UNION

SELECT DISTINCT ON (r."GeometryID") r."GeometryID"
	, r.ogc_fid
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "RoadName"
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription"
	, "NrBays"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription"
	, 0 AS "RequiredNrSigns", 0 AS "CurrNrSigns"
	, LEAST (ST_Distance(l.geom, ST_EndPoint(r.geom)), ST_Distance(l.geom, ST_EndPoint(r.geom))) AS "Distance to sign"
	, ST_Length(r.geom) AS "Length new"
	, r.geom
FROM mhtc_operations."SignRestrictionLink" l
	, toms."Bays" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."TimePeriodID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON r."MaxStayID" is not distinct from "LengthOfTime1"."Code"
		LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON r."NoReturnID" is not distinct from "LengthOfTime2"."Code"
WHERE l."LinkedTo" = r."GeometryID"
AND r."RestrictionTypeID" IN (105, 131)
AND (
	NOT (ST_DWithin(l.geom, ST_EndPoint(r.geom), 20.0)) OR
	NOT (ST_DWithin(l.geom, ST_StartPoint(r.geom), 20.0))
)

) z

ORDER BY "GeometryID"
;

-- Check distance between signs for the same restriction is not greater than 30m

DO $$
DECLARE
	long_bay RECORD;
	sign_linked_to_bay RECORD;
	min_distance REAL;
	this_distance REAL;
	this_sign CHARACTER VARYING;
	
	spacing_allowed REAL = 35.0;
	large_distance REAL = 10000.0;
	
	already_present BOOLEAN;
	
BEGIN

    FOR long_bay IN
		SELECT DISTINCT ON (r."GeometryID") r."GeometryID"
			, r.ogc_fid
			, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
			, "RoadName"
			, "BayLineTypes"."Description" AS "RestrictionDescription"
			, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription"
			, "NrBays"
			, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription"
			, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription"
			, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription"
			, FLOOR (ST_Length(r.geom)/spacing_allowed) As "RequiredNrSigns" 
			, CASE WHEN true THEN (SELECT COUNT(*)
							FROM mhtc_operations."SignRestrictionLink" l
							WHERE l."LinkedTo" = r."GeometryID")
					ELSE 0
				END AS "CurrNrSigns"
			, 0 As "Distance to sign"		
			, ST_Length(r.geom) AS "Length_new"
			, r.geom
		FROM  toms."Bays" r
				LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
				LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
				LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
				LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."TimePeriodID" is not distinct from "TimePeriods1"."Code"
				LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON r."MaxStayID" is not distinct from "LengthOfTime1"."Code"
				LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON r."NoReturnID" is not distinct from "LengthOfTime2"."Code"
		WHERE ST_Length(r.geom) > spacing_allowed
		AND 1 < (SELECT COUNT(*)
							FROM mhtc_operations."SignRestrictionLink" l
							WHERE l."LinkedTo" = r."GeometryID")
		AND r."RestrictionTypeID" IN (105, 131)  -- Only check for Shared Use and permit holder bays
		--AND "GeometryID" = 'B_0003461'

	LOOP
	
		min_distance = large_distance;
		
		FOR sign_linked_to_bay IN 
			SELECT s."GeometryID", s.geom
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND l."LinkedTo" = long_bay."GeometryID"
		LOOP

			SELECT DISTINCT ON (l."GeometryID") l."GeometryID", ST_DISTANCE(sign_linked_to_bay.geom, s.geom) AS this_distance
			INTO this_sign, this_distance
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND s."GeometryID" != sign_linked_to_bay."GeometryID"
			AND l."LinkedTo" = long_bay."GeometryID"
			ORDER BY l."GeometryID", this_distance
			LIMIT 1;

			IF this_distance < min_distance THEN
				min_distance = this_distance;
			END IF;
			
		END LOOP;
		
		IF min_distance > spacing_allowed AND min_distance < large_distance THEN
				
			RAISE NOTICE 'GeometryID: %: min dist: %', long_bay."GeometryID", min_distance;
			
			-- check to see if already in issues
			
			SELECT true
			INTO already_present
			FROM mhtc_operations."Restrictions_Audit_Issues"
			WHERE "GeometryID" = long_bay."GeometryID";
			
			IF already_present THEN
			
				UPDATE mhtc_operations."Restrictions_Audit_Issues"
				SET "Notes" = CONCAT("Notes", '; ', 'Shortest distance is ', ROUND(min_distance::numeric,1))
				WHERE "GeometryID" = long_bay."GeometryID";

			ELSE
			
				INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
					"GeometryID"
					, ogc_fid
					, "SouthwarkProposedDeliveryZoneName"
					, "Reason"
					, "RoadName_new"
					, "RestrictionDescription_new"
					, "RestrictionShapeDescription_new"
					, "NrBays_new"
					, "TimePeriodDescription_new"
					, "MaxStayDescription_new"
					, "NoReturnDescription_new"
					, "Notes"
					, "Length new"
					, geom)
				VALUES (
					long_bay."GeometryID"
					, long_bay.ogc_fid
					, long_bay."SouthwarkProposedDeliveryZoneName"
					, 'Distance between signs'
					, long_bay."RoadName"
					, long_bay."RestrictionDescription"
					, long_bay."RestrictionShapeDescription"
					, long_bay."NrBays"
					, long_bay."TimePeriodDescription"
					, long_bay."MaxStayDescription"
					, long_bay."NoReturnDescription"
					, CONCAT('Shortest distance is ', ROUND(min_distance::numeric,1))
					, long_bay."Length_new"
					, long_bay.geom
					);
				
			END IF;
			
		END IF;
		
	END LOOP;
		
END; $$;

--- Consider distance for SYLs (and loading) - use 60.0m


INSERT INTO mhtc_operations."Restrictions_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "Reason"
	, "RoadName_new"
	, "RestrictionDescription_new"
	, "NoWaitingTimeDescription_new"
	, "NoLoadingTimeDescription_new"
	, "Notes"
	, "Length new"
	, geom)

SELECT "GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, 'Number of signs in restriction' AS "Reason"
	, "RoadName_new"
	, "RestrictionDescription_new"
	, "NoWaitingTimeDescription_new"
	, "NoLoadingTimeDescription_new"
	, CONCAT('Required: ', "RequiredNrSigns" , ' - Current: ', "CurrNrSigns") AS "Notes"
	, "Length new"
	, geom
	
FROM (

SELECT "GeometryID"
	, r.ogc_fid
	, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	, "RoadName" AS "RoadName_new"
	, "NoWaitingTimeID" AS "NoWaitingTimeID_new"
	, "NoLoadingTimeID" AS "NoLoadingTimeID_new"
	, "BayLineTypes"."Description" AS "RestrictionDescription_new"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription_new"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription_new"
	, FLOOR (ST_Length(r.geom)/60.0) As "RequiredNrSigns" 
	, CASE WHEN true THEN (SELECT COUNT(*)
					FROM mhtc_operations."SignRestrictionLink" l
		 			WHERE l."LinkedTo" = r."GeometryID")
	    ELSE 0
		END AS "CurrNrSigns"
	, ST_Length(r.geom) AS "Length new"
	, r.geom
FROM  toms."Lines" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON r."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
WHERE FLOOR (ST_Length(r.geom)/60.0) > (SELECT COUNT(*) AS Nr
										  FROM mhtc_operations."SignRestrictionLink" l
										  WHERE l."LinkedTo" = r."GeometryID"
										  HAVING COUNT(*) > 0)
AND r."RestrictionTypeID" IN (201, 221, 224)

-- check that line is not within CPZ and has same hours

AND r."GeometryID" NOT IN (
	SELECT b."GeometryID"
	FROM toms."Lines" b, toms."ControlledParkingZones" p 
	WHERE ST_Within(b.geom, p.geom)
	AND b."RestrictionTypeID" IN (201, 221, 224)
	AND p."RestrictionTypeID" = 20 -- CPZ
	AND b."NoWaitingTimeID" = p."TimePeriodID"
	) 

) d
;

