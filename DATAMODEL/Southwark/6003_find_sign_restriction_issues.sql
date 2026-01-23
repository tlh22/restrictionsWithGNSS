/***

-- Now check to see whether there are restrictions without signs

***/

DELETE FROM mhtc_operations."Restrictions_Signs_Audit_Issues";

INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
	"GeometryID", ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "CPZ"
	, "Reason"
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
	, COALESCE("CPZ", '')  AS "CPZ"
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


INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "CPZ"
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
	, COALESCE("CPZ", '')  AS "CPZ"
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

INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
	"GeometryID"
	, ogc_fid
	, "SouthwarkProposedDeliveryZoneName"
	, "CPZ"
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
	, COALESCE("CPZ", '')  AS "CPZ"
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

AND "GeometryID" NOT IN (SELECT "GeometryID"
                         FROM mhtc_operations."Restrictions_Signs_Audit_Issues")

ORDER BY "RoadName"
;


-- Consider issues for spacing of signs for restrictions


--

-- Sign not within 15m of bay start/end

-- Check distance from start/end of bay to signs is not greater than 15m

DO $$
DECLARE
	this_bay RECORD;
	sign_linked_to_bay RECORD;
	min_distance_to_start REAL;
	min_distance_to_end REAL;
	this_distance_to_start REAL;
	this_distance_to_end REAL;
	this_sign CHARACTER VARYING;
	
	spacing_allowed REAL = 20.0;
	large_distance REAL = 10000.0;
	
	already_present BOOLEAN;
	
	nr_issues INTEGER = 0;
	nr_signs INTEGER = 0;
	
BEGIN

    FOR this_bay IN
		SELECT r."GeometryID"
			, r.ogc_fid
			, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
			, COALESCE("CPZ", '')  AS "CPZ"
			, "RoadName"
			, "BayLineTypes"."Description" AS "RestrictionDescription"
			, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionShapeDescription"
			, "NrBays"
			, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription"
			, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription"
			, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription"
			, ST_Length(r.geom) AS "Length_new"
			, r.geom
			, ST_StartPoint(r.geom) AS "StartPoint"
			, ST_EndPoint(r.geom) AS "EndPoint"
		FROM  toms."Bays" r
				LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
				LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
				LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
				LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."TimePeriodID" is not distinct from "TimePeriods1"."Code"
				LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON r."MaxStayID" is not distinct from "LengthOfTime1"."Code"
				LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON r."NoReturnID" is not distinct from "LengthOfTime2"."Code"
		WHERE ST_Length(r.geom) > spacing_allowed
		AND r."RestrictionTypeID" IN (105, 131)  -- Only check for Shared Use and permit holder bays
		--AND "GeometryID" = 'B_0003461'

	LOOP
	
		min_distance_to_start = large_distance;
		min_distance_to_end = large_distance;		
		
		-- Calculate distance to start/end points of bay from related signs
		
		nr_signs = 0;
		
		FOR sign_linked_to_bay IN 
			SELECT s."GeometryID", s.geom
			     , ST_DISTANCE(s.geom, this_bay."StartPoint") AS this_distance_to_start
			     , ST_DISTANCE(s.geom, this_bay."EndPoint") AS this_distance_to_end
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND l."LinkedTo" = this_bay."GeometryID"
		LOOP

			--RAISE NOTICE 'GeometryID: %: min dist: % %', this_bay."GeometryID", sign_linked_to_bay.this_distance_to_start, sign_linked_to_bay.this_distance_to_end;
			
			IF sign_linked_to_bay.this_distance_to_start < min_distance_to_start THEN
				min_distance_to_start = sign_linked_to_bay.this_distance_to_start;
			END IF;
			
			IF sign_linked_to_bay.this_distance_to_end < min_distance_to_end THEN
				min_distance_to_end = sign_linked_to_bay.this_distance_to_end;
			END IF;
			
			nr_signs = nr_signs + 1;
			
		END LOOP;
		
		IF (min_distance_to_start > spacing_allowed OR min_distance_to_end > spacing_allowed)
            AND nr_signs > 0 THEN
			
			nr_issues = nr_issues + 1;
						
            --RAISE NOTICE 'GeometryID: %: max dist to end: %', this_bay."GeometryID", GREATEST (min_distance_to_start, min_distance_to_end);
			
			-- check to see if already in issues

			SELECT true
			INTO already_present
			FROM mhtc_operations."Restrictions_Signs_Audit_Issues"
			WHERE "GeometryID" = this_bay."GeometryID";
			
			IF already_present THEN
			
				UPDATE mhtc_operations."Restrictions_Signs_Audit_Issues"
				SET "Notes" = CONCAT("Notes", '; ', 'Max distance to start-end is ', ROUND(GREATEST (min_distance_to_start, min_distance_to_end)::numeric,1))
				WHERE "GeometryID" = this_bay."GeometryID";

			ELSE
			
				INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
					"GeometryID"
					, ogc_fid
					, "SouthwarkProposedDeliveryZoneName"
					, "CPZ"
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
					this_bay."GeometryID"
					, this_bay.ogc_fid
					, this_bay."SouthwarkProposedDeliveryZoneName"
					, this_bay."CPZ"
					, 'Distance from start/end'
					, this_bay."RoadName"
					, this_bay."RestrictionDescription"
					, this_bay."RestrictionShapeDescription"
					, this_bay."NrBays"
					, this_bay."TimePeriodDescription"
					, this_bay."MaxStayDescription"
					, this_bay."NoReturnDescription"
					, CONCAT('Max distance to start-end is ', ROUND(GREATEST (min_distance_to_start, min_distance_to_end)::numeric,1))
					, this_bay."Length_new"
					, this_bay.geom
					);

			END IF;

		END IF;
		
	END LOOP;
	
	RAISE NOTICE 'Nr distance to end issues for bays found: %', nr_issues;
		
END; $$;


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
	nr_issues INTEGER = 0;	
BEGIN

    FOR long_bay IN
		SELECT DISTINCT ON (r."GeometryID") r."GeometryID"
			, r.ogc_fid
			, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
			, COALESCE("CPZ", '')  AS "CPZ"
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
		--AND "GeometryID" = 'B_0006258'

	LOOP
	
		min_distance = large_distance;
		
		FOR sign_linked_to_bay IN 
			SELECT s."GeometryID", s.geom
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND l."LinkedTo" = long_bay."GeometryID"
		LOOP

			SELECT l."GeometryID", ST_DISTANCE(sign_linked_to_bay.geom, s.geom) AS this_distance
			INTO this_sign, this_distance
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND s."GeometryID" != sign_linked_to_bay."GeometryID"
			AND l."LinkedTo" = long_bay."GeometryID"
			ORDER BY this_distance, l."GeometryID"
			LIMIT 1;

			IF this_distance < min_distance THEN
				min_distance = this_distance;
			END IF;
			
		END LOOP;
		
		IF min_distance > spacing_allowed AND min_distance < large_distance THEN
		
		    nr_issues = nr_issues + 1;
				
			--RAISE NOTICE 'GeometryID: %: min dist: %', long_bay."GeometryID", min_distance;
			
			-- check to see if already in issues
			
			SELECT true
			INTO already_present
			FROM mhtc_operations."Restrictions_Signs_Audit_Issues"
			WHERE "GeometryID" = long_bay."GeometryID";
			
			IF already_present THEN
			
				UPDATE mhtc_operations."Restrictions_Signs_Audit_Issues"
				SET "Notes" = CONCAT("Notes", '; ', 'Shortest distance between signs is ', ROUND(min_distance::numeric,1))
				WHERE "GeometryID" = long_bay."GeometryID";

			ELSE
			
				INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
					"GeometryID"
					, ogc_fid
					, "SouthwarkProposedDeliveryZoneName"
					, "CPZ"
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
					, long_bay."CPZ"
					, 'Distance between signs'
					, long_bay."RoadName"
					, long_bay."RestrictionDescription"
					, long_bay."RestrictionShapeDescription"
					, long_bay."NrBays"
					, long_bay."TimePeriodDescription"
					, long_bay."MaxStayDescription"
					, long_bay."NoReturnDescription"
					, CONCAT('Shortest distance between signs is ', ROUND(min_distance::numeric,1))
					, long_bay."Length_new"
					, long_bay.geom
					);
				
			END IF;
			
		END IF;
		
	END LOOP;
	
	RAISE NOTICE 'Nr distance between signs issues for bays found: %', nr_issues;
	
END; $$;


-- Consider distance from start/end of line - use 35.0m

-- Check distance from start/end of line to signs is not greater than 35m

DO $$
DECLARE
	this_line RECORD;
	sign_linked_to_bay RECORD;
	min_distance_to_start REAL;
	min_distance_to_end REAL;
	this_distance_to_start REAL;
	this_distance_to_end REAL;
	this_sign CHARACTER VARYING;
	
	spacing_allowed REAL = 35.0;
	large_distance REAL = 10000.0;
	
	already_present BOOLEAN;
	
	nr_issues INTEGER = 0;
	nr_signs INTEGER = 0;
	
BEGIN

    FOR this_line IN
		SELECT r."GeometryID"
			, r.ogc_fid
			, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
			, COALESCE("CPZ", '')  AS "CPZ"
			, "RoadName"
			, "BayLineTypes"."Description" AS "RestrictionDescription"
			, "NoWaitingTimeID" AS "NoWaitingTimeID"
			, "NoLoadingTimeID" AS "NoLoadingTimeID"
			, "BayLineTypes"."Description" AS "RestrictionDescription"
			, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription"
			, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription"
			, ST_Length(r.geom) AS "Length_new"
			, r.geom
			, ST_StartPoint(r.geom) AS "StartPoint"
			, ST_EndPoint(r.geom) AS "EndPoint"
		FROM  toms."Lines" r
			LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
			LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
			LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
			LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
			LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON r."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
		WHERE ST_Length(r.geom) > spacing_allowed
		AND r."RestrictionTypeID" IN (201, 221, 224)
		--AND "GeometryID" = 'B_0003461'
		
		AND r."GeometryID" NOT IN (
			SELECT b."GeometryID"
			FROM toms."Lines" b, toms."ControlledParkingZones" p 
			WHERE ST_Within(b.geom, p.geom)
			AND b."RestrictionTypeID" IN (201, 221, 224)
			AND p."RestrictionTypeID" = 20 -- CPZ
			AND b."NoWaitingTimeID" = p."TimePeriodID"
		)
		
	LOOP
	
		min_distance_to_start = large_distance;
		min_distance_to_end = large_distance;		
		
		-- Calculate distance to start/end points of bay from related signs
		
		nr_signs = 0;
		
		FOR sign_linked_to_bay IN 
			SELECT s."GeometryID", s.geom
			     , ST_DISTANCE(s.geom, this_line."StartPoint") AS this_distance_to_start
			     , ST_DISTANCE(s.geom, this_line."EndPoint") AS this_distance_to_end
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND l."LinkedTo" = this_line."GeometryID"
		LOOP
			
			--RAISE NOTICE 'GeometryID: %: min dist: % %', this_line."GeometryID", sign_linked_to_bay.this_distance_to_start, sign_linked_to_bay.this_distance_to_end;
			
			IF sign_linked_to_bay.this_distance_to_start < min_distance_to_start THEN
				min_distance_to_start = sign_linked_to_bay.this_distance_to_start;
			END IF;
			
			IF sign_linked_to_bay.this_distance_to_end < min_distance_to_end THEN
				min_distance_to_end = sign_linked_to_bay.this_distance_to_end;
			END IF;

			nr_signs = nr_signs + 1;
			
		END LOOP;
		
		IF (min_distance_to_start > spacing_allowed OR min_distance_to_end > spacing_allowed) 
		    AND nr_signs > 0 THEN
			
			nr_issues = nr_issues + 1;
						
            --RAISE NOTICE 'GeometryID: %: max dist to end: %', this_line."GeometryID", GREATEST (min_distance_to_start, min_distance_to_end);
			
			-- check to see if already in issues

			SELECT true
			INTO already_present
			FROM mhtc_operations."Restrictions_Signs_Audit_Issues"
			WHERE "GeometryID" = this_line."GeometryID";

			IF already_present THEN
			
				UPDATE mhtc_operations."Restrictions_Signs_Audit_Issues"
				SET "Notes" = CONCAT("Notes", '; ', 'Max distance to start-end is ', ROUND(GREATEST (min_distance_to_start, min_distance_to_end)::numeric,1))
				WHERE "GeometryID" = this_line."GeometryID";

			ELSE
			
				INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
					"GeometryID"
					, ogc_fid
					, "SouthwarkProposedDeliveryZoneName"
					, "CPZ"
					, "Reason"
					, "RoadName_new"
					, "RestrictionDescription_new"
					, "NoWaitingTimeDescription_new"
					, "NoLoadingTimeDescription_new"
					, "Notes"
					, "Length new"
					, geom)
				VALUES (
					this_line."GeometryID"
					, this_line.ogc_fid
					, this_line."SouthwarkProposedDeliveryZoneName"
					, this_line."CPZ"
					, 'Distance from start/end'
					, this_line."RoadName"
					, this_line."RestrictionDescription"
					, this_line."NoWaitingTimeDescription"
					, this_line."NoLoadingTimeDescription"
					, CONCAT('Max distance to start-end is ', ROUND(GREATEST (min_distance_to_start, min_distance_to_end)::numeric,1))
					, this_line."Length_new"
					, this_line.geom
					);

			END IF;

		END IF;
		
	END LOOP;
	
	RAISE NOTICE 'Nr distance from end issues for lines found: %', nr_issues;
		
END; $$;

--- Consider distance between signs for SYLs (and loading) - use 60.0m

-- Check distance between signs for the same line is not greater than 60m

DO $$
DECLARE
	this_restriction RECORD;
	sign_linked_to_restriction RECORD;
	min_distance REAL;
	this_distance REAL;
	this_sign CHARACTER VARYING;
	
	spacing_allowed REAL = 65.0;
	large_distance REAL = 10000.0;
	
	already_present BOOLEAN;
	nr_issues INTEGER = 0;
	
BEGIN

    FOR this_restriction IN
		SELECT DISTINCT ON (r."GeometryID") r."GeometryID"
			, r.ogc_fid
			, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
			, COALESCE("CPZ", '')  AS "CPZ"
			, "RoadName"
			, "BayLineTypes"."Description" AS "RestrictionDescription"
			, "NoWaitingTimeID" AS "NoWaitingTimeID_new"
			, "NoLoadingTimeID" AS "NoLoadingTimeID_new"
			, "BayLineTypes"."Description" AS "RestrictionDescription"
			, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription"
			, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription"
			, FLOOR (ST_Length(r.geom)/spacing_allowed) As "RequiredNrSigns" 
			, CASE WHEN true THEN (SELECT COUNT(*)
							FROM mhtc_operations."SignRestrictionLink" l
							WHERE l."LinkedTo" = r."GeometryID")
					ELSE 0
				END AS "CurrNrSigns"
			, 0 As "Distance to sign"		
			, ST_Length(r.geom) AS "Length_new"
			, r.geom
		FROM  toms."Lines" r
			LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
			LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON r."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
			LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON r."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
			LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON r."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
			LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON r."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
		WHERE ST_Length(r.geom) > spacing_allowed
		AND 1 < (SELECT COUNT(*)
							FROM mhtc_operations."SignRestrictionLink" l
							WHERE l."LinkedTo" = r."GeometryID")
		AND r."RestrictionTypeID" IN (201, 221, 224) -- Only check for SYLs
		--AND "GeometryID" = 'B_0003461'

	LOOP
	
		min_distance = large_distance;
		
		FOR sign_linked_to_restriction IN 
			SELECT s."GeometryID", s.geom
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND l."LinkedTo" = this_restriction."GeometryID"
		LOOP

			SELECT l."GeometryID", ST_DISTANCE(sign_linked_to_restriction.geom, s.geom) AS this_distance
			INTO this_sign, this_distance
			FROM toms."Signs" s, mhtc_operations."SignRestrictionLink" l
			WHERE s."GeometryID" = l."GeometryID"
			AND s."GeometryID" != sign_linked_to_restriction."GeometryID"
			AND l."LinkedTo" = this_restriction."GeometryID"
			ORDER BY this_distance, l."GeometryID"
			LIMIT 1;

			IF this_distance < min_distance THEN
				min_distance = this_distance;
			END IF;
			
		END LOOP;
		
		IF min_distance > spacing_allowed AND min_distance < large_distance THEN
		
		    nr_issues = nr_issues + 1;
				
			--RAISE NOTICE 'GeometryID: %: min dist: %', this_restriction."GeometryID", min_distance;
			
			-- check to see if already in issues
			
			SELECT true
			INTO already_present
			FROM mhtc_operations."Restrictions_Signs_Audit_Issues"
			WHERE "GeometryID" = this_restriction."GeometryID";
			
			IF already_present THEN
			
				UPDATE mhtc_operations."Restrictions_Signs_Audit_Issues"
				SET "Notes" = CONCAT("Notes", '; ', 'Shortest distance between signs is ', ROUND(min_distance::numeric,1))
				WHERE "GeometryID" = this_restriction."GeometryID";

			ELSE
			
				INSERT INTO mhtc_operations."Restrictions_Signs_Audit_Issues"(
					"GeometryID"
					, ogc_fid
					, "SouthwarkProposedDeliveryZoneName"
					, "CPZ"
					, "Reason"
					, "RoadName_new"
					, "RestrictionDescription_new"
					, "NoWaitingTimeDescription_new"
					, "NoLoadingTimeDescription_new"
					, "Notes"
					, "Length new"
					, geom)
				VALUES (
					this_restriction."GeometryID"
					, this_restriction.ogc_fid
					, this_restriction."SouthwarkProposedDeliveryZoneName"
					, this_restriction."CPZ"
					, 'Distance from start/end'
					, this_restriction."RoadName"
					, this_restriction."RestrictionDescription"
					, this_restriction."NoWaitingTimeDescription"
					, this_restriction."NoLoadingTimeDescription"
					, CONCAT('Shortest distance between signs is ', ROUND(min_distance::numeric,1))
					, this_restriction."Length_new"
					, this_restriction.geom
					);
				
			END IF;
			
		END IF;
		
	END LOOP;
	
	RAISE NOTICE 'Nr distance between signs issues for Lines found: %', nr_issues;
	
END; $$;


/***

Remove any that are already issues

***/

DELETE FROM mhtc_operations."Restrictions_Signs_Audit_Issues"
WHERE "GeometryID" IN (SELECT "GeometryID"
                       FROM mhtc_operations."Restrictions_Audit_Issues")
;