/*
To create stress maps, steps are:
1.	Check that demand fields are correct
2. Prepare view with query below
*/

-- Ensure demand fields are tidy
UPDATE demand."Demand_Merged"
SET ncars = NULL
WHERE ncars = '';

UPDATE demand."Demand_Merged"
SET nlgvs = NULL
WHERE nlgvs = '';

UPDATE demand."Demand_Merged"
SET nmcls = NULL
WHERE nmcls = '';

UPDATE demand."Demand_Merged"
SET nogvs = NULL
WHERE nogvs = '';

UPDATE demand."Demand_Merged"
SET nogvs2 = NULL
WHERE nogvs2 = '';

UPDATE demand."Demand_Merged"
SET nbuses = NULL
WHERE nbuses = '';

UPDATE demand."Demand_Merged"
SET nminib = NULL
WHERE nminib = '';

UPDATE demand."Demand_Merged"
SET ntaxis = NULL
WHERE ntaxis = '';

UPDATE demand."Demand_Merged"
SET nspaces = NULL
WHERE nspaces = '';

UPDATE demand."Demand_Merged"
SET sbays = NULL
WHERE sbays = '';

-- Now prepare stress

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    s."name1" AS "RoadName", s.geom,
    d."SurveyID", d."Stress" AS "Stress"
	FROM highways_network."roadlink" s,
	(
	SELECT "SurveyID", "RoadName",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(d."Demand") AS "Demand"
    FROM mhtc_operations."Supply" s, demand."Demand_Merged" d
    WHERE s."GeometryID" = d."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
    GROUP BY d."SurveyID", s."RoadName"
    ORDER BY s."RoadName", d."SurveyID" ) a
    ) d
	WHERE s."name1" = d."RoadName"
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";


--
SELECT "SurveyID", "RoadName", "Capacity", "Demand",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(d."Demand") AS "Demand"
    FROM mhtc_operations."Supply" s, demand."Demand_Merged" d
    WHERE s."GeometryID" = d."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
    GROUP BY d."SurveyID", s."RoadName"
    ORDER BY s."RoadName", d."SurveyID" ) a


-- Stress from vrms_final

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    s."name1" AS "RoadName", s.geom,
    d."SurveyID", d."Stress" AS "Stress"
	FROM highways_network."roadlink" s,
	(
	SELECT "SurveyID", "RoadName",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(demand."Demand") AS "Demand"
    FROM mhtc_operations."Supply" s, (
        SELECT a."SurveyID", a."GeometryID", SUM("VehicleTypes"."PCU") AS "Demand"
        FROM (demand."VRMs_Final" AS a
        LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
        GROUP BY a."SurveyID", a."GeometryID"
    ) demand
    WHERE s."GeometryID" = demand."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
    GROUP BY demand."SurveyID", s."RoadName"
    ORDER BY s."RoadName", demand."SurveyID" ) a
    ) d
	WHERE s."name1" = d."RoadName"
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";
