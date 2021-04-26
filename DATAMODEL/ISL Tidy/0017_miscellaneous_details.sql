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
    SELECT "GeometryID", "NoWaitingTimeID" AS "TimePeriodID"
    FROM toms."Lines"
        UNION
    SELECT "GeometryID", "NoLoadingTimeID" AS "TimePeriodID"
    FROM toms."Lines"
) AS a
    LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods" ON a."TimePeriodID" is not distinct from "TimePeriods"."Code")
GROUP BY "TimePeriodID", "TimePeriod";

-- Different bay types by CPZ

SELECT "CPZ", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionDescription", COUNT (*) --, SUM("Capacity")
FROM
(
    toms."Bays" As a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
GROUP BY "CPZ", "RestrictionTypeID", "RestrictionDescription"
ORDER BY "CPZ", "RestrictionDescription";

