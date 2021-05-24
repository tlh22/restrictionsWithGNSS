/***
Various interesting queries

***/

-- Different time periods

SELECT "TimePeriodID", "TimePeriods"."Description" AS "TimePeriod", COUNT(*) As "Count"
FROM
((
    SELECT "GeometryID", "TimePeriodID" AS "TimePeriodID"
    FROM toms."Bays"
        UNION
	SELECT "GeometryID", "MatchDayTimePeriodID" AS "TimePeriodID"
    FROM toms."Bays"
    WHERE "MatchDayTimePeriodID" IS NOT NULL
        UNION
    SELECT "GeometryID", "NoWaitingTimeID" AS "TimePeriodID"
    FROM toms."Lines"
	WHERE "NoWaitingTimeID" IS NOT NULL
        UNION
    SELECT "GeometryID", "MatchDayTimePeriodID" AS "TimePeriodID"
    FROM toms."Lines"
	WHERE "MatchDayTimePeriodID" IS NOT NULL
        UNION
    SELECT "GeometryID", "NoLoadingTimeID" AS "TimePeriodID"
    FROM toms."Lines"
	WHERE "NoLoadingTimeID" IS NOT NULL
	    UNION
    SELECT "GeometryID", "TimePeriodID" AS "TimePeriodID"
    FROM toms."RestrictionPolygons"
	WHERE "TimePeriodID" IS NOT NULL
		UNION
    SELECT "GeometryID", "NoWaitingTimeID" AS "TimePeriodID"
    FROM toms."RestrictionPolygons"
	WHERE "NoWaitingTimeID" IS NOT NULL
		UNION
    SELECT "GeometryID", "NoLoadingTimeID" AS "TimePeriodID"
    FROM toms."RestrictionPolygons"
	WHERE "NoLoadingTimeID" IS NOT NULL

        UNION
    SELECT "GeometryID", "timeInterval" AS "TimePeriodID"
    FROM moving_traffic."TurnRestrictions"
	WHERE "timeInterval" IS NOT NULL

        UNION
    SELECT "GeometryID", "timeInterval" AS "TimePeriodID"
    FROM moving_traffic."AccessRestrictions"
	WHERE "timeInterval" IS NOT NULL
        UNION
    SELECT "GeometryID", "timeInterval" AS "TimePeriodID"
    FROM moving_traffic."HighwayDedications"
	WHERE "timeInterval" IS NOT NULL
        UNION
    SELECT "GeometryID", "timeInterval" AS "TimePeriodID"
    FROM moving_traffic."SpecialDesignations"
	WHERE "timeInterval" IS NOT NULL
) AS a
    LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods" ON a."TimePeriodID" is not distinct from "TimePeriods"."Code")
GROUP BY "TimePeriodID", "TimePeriod";

-- Different bay types by CPZ

SELECT "CPZ", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionDescription", COUNT (*) AS "NrOfBanks", SUM("Capacity") As "Capacity"
FROM
(
    toms."Bays" As a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     WHERE a."MHTC_CheckIssueTypeID" = 1
GROUP BY "CPZ", "RestrictionTypeID", "RestrictionDescription"
ORDER BY "CPZ", "RestrictionDescription";

-- Lines by CPZ

SELECT "CPZ", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionDescription", COUNT (*) AS "NrOfSections", SUM("Capacity") As "Capacity"
FROM
(
    toms."Lines" As a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     WHERE a."MHTC_CheckIssueTypeID" = 1
GROUP BY "CPZ", "RestrictionTypeID", "RestrictionDescription"
ORDER BY "CPZ", "RestrictionDescription";


-- Count of items

-- ** HighwayAssets

DO
$$DECLARE
    relevant_table record;
    squery TEXT = '';
    len_squery INTEGER;
BEGIN

    FOR relevant_table IN (
          select table_schema, table_name::text, concat(table_schema, '.', quote_ident(table_name))::regclass AS full_table_name
          from information_schema.columns
          where column_name = 'GeometryID'
          AND table_schema IN ('highway_assets')
          AND table_name != 'HighwayAssets'
        ) LOOP

			--RAISE NOTICE 'table: % ', relevant_table.full_table_name;

            IF LENGTH(squery) > 0 THEN
                squery = squery || ' UNION ';
            END IF;

			--squery = squery || format('%s', relevant_table.full_table_name);

			--RAISE NOTICE 'squery: % ', squery;

            squery = squery || format('
                SELECT ''%1$s'' AS "HighwayAssetType", COUNT(*) AS "NrItems"
                FROM %2$s
             ', relevant_table.table_name, relevant_table.full_table_name);

	END LOOP;

	RAISE NOTICE 'squery: % ', squery;

    --EXECUTE FORMAT ('COPY %1$s TO STDOUT WITH CSV HEADER', squery);
    --EXECUTE squery;

END$$;


