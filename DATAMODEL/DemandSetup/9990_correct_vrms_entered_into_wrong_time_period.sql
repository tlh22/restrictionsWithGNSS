/***
VRMs entered into wrong time period
***/


CREATE OR REPLACE FUNCTION demand."move_vrms_between_time_periods"(geometry_id text,
                                                                   original_time_period integer,
                                                                   new_time_period integer)
    RETURNS boolean
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    result boolean = true;
BEGIN

    RAISE NOTICE 'Moving % from % to %', geometry_id, original_time_period, new_time_period;

    -- Deal with the RiS tables
    -- transfer details
    UPDATE demand."RestrictionsInSurveys_ALL" AS n
	SET "DemandSurveyDateTime" = o."DemandSurveyDateTime",
	    "Enumerator" = o."Enumerator",
	    "Done" = o."Done",
	    "SuspensionReference" = o."SuspensionReference",
	    "SuspensionReason" = o."SuspensionReason",
	    "SuspensionLength" = o."SuspensionLength",
	    "NrBaysSuspended" = o."NrBaysSuspended",
	    "SuspensionNotes" = o."SuspensionNotes",
	    "Photos_01" = o."Photos_01",
	    "Photos_02" = o."Photos_02",
	    "Photos_03" = o."Photos_03"
    FROM demand."RestrictionsInSurveys_ALL" o
	WHERE o."GeometryID" = n."GeometryID"
    AND o."SurveyID" = original_time_period
    AND n."SurveyID" = new_time_period
    AND o."GeometryID" = geometry_id;

    -- reset values for the original time period
    UPDATE demand."RestrictionsInSurveys_ALL"
	SET "DemandSurveyDateTime" = NULL,
	    "Enumerator" = NULL,
	    "Done" = false,
	    "SuspensionReference" = NULL,
	    "SuspensionReason" = NULL,
	    "SuspensionLength" = NULL,
	    "NrBaysSuspended" = NULL,
	    "SuspensionNotes" = NULL,
	    "Photos_01" = NULL,
	    "Photos_02" = NULL,
	    "Photos_03" = NULL
    WHERE "SurveyID" = original_time_period
    AND "GeometryID" = geometry_id;

    -- move VRMs
    UPDATE demand."VRMs"
    SET "SurveyID" = new_time_period
    WHERE "SurveyID" = original_time_period
    AND "GeometryID" = geometry_id;

    RETURN result;

END;
$BODY$;

/**
Operations
**/

DO
$do$
DECLARE
   row RECORD;
   geometry_id TEXT;
   result BOOLEAN;
   count integer = 0;
BEGIN
    FOR row IN SELECT "GeometryID"
               FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
               WHERE ST_Within (s.geom, a.geom)
               AND a."name" = 'HS-2'
    LOOP

        geometry_id = row."GeometryID";

        SELECT demand."move_vrms_between_time_periods"(geometry_id, 13, 33) INTO result;
        count = count + 1;

    END LOOP;

    RAISE NOTICE 'Total records moved: %', count;

END
$do$;



SELECT "GeometryID"
FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE ST_Within (s.geom, a.geom)
AND a."name" = 'HS-2'

SELECT "GeometryID"
FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE ST_Within (s.geom, a.geom)
SELECT demand."move_vrms_between_time_periods"(11, 31)