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

-- Step 1: Add new fields

ALTER TABLE demand."Counts"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."Counts"
    ADD COLUMN "Stress" double precision;

-- Step 2: calculate demand values using trigger

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 vehicleLength real := 0.0;
	 vehicleWidth real := 0.0;
	 motorcycleWidth real := 0.0;
	 restrictionLength real := 0.0;
BEGIN

    IF vehicleLength IS NULL OR vehicleWidth IS NULL OR motorcycleWidth IS NULL THEN
        RAISE EXCEPTION 'Capacity parameters not available ...';
        RETURN OLD;
    END IF;

    NEW."Demand" = COALESCE(NEW."ncars"::float, 0.0) + COALESCE(NEW."nlgvs"::float, 0.0)
                    + COALESCE(NEW."nmcls"::float, 0.0)*0.33
                    + (COALESCE(NEW."nogvs"::float, 0) + COALESCE(NEW."nogvs2"::float, 0) + COALESCE(NEW."nminib"::float, 0) + COALESCE(NEW."nbuses"::float, 0))*1.5
                    + COALESCE(NEW."ntaxis"::float, 0);

    /* What to do about suspensions */

    CASE
        WHEN NEW."CapacityFromDemand" = 0 THEN
            CASE
                WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                ELSE NEW."Stress" = 0.0;
            END CASE;
        ELSE
            CASE
                WHEN NEW."CapacityFromDemand"::float - COALESCE(NEW."sbays"::float, 0.0) > 0.0 THEN
                    NEW."Stress" = NEW."Demand" / (NEW."CapacityFromDemand"::float - COALESCE(NEW."sbays"::float, 0.0)) * 100.0;
                ELSE
                    CASE
                        WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                        ELSE NEW."Stress" = 0.0;
                    END CASE;
            END CASE;
    END CASE;

	RETURN NEW;

END;
$$;

-- create trigger

CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."Counts" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand"();

-- trigger trigger

UPDATE "demand"."Counts" SET "RestrictionLength" = "RestrictionLength";

-- Step 3: output demand

SELECT
d."SurveyID", s."SurveyDay" As "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" As "Survey Time", d."GeometryID",
       (COALESCE("ncars"::float, 0)+COALESCE("ntaxis"::float, 0)) As "Nr Cars", COALESCE("nlgvs"::float, 0) As "Nr LGVs",
       COALESCE("nmcls"::float, 0) AS "Nr MCLs", COALESCE("nogvs"::float, 0) AS "Nr OGVs", COALESCE("nbuses"::float, 0) AS "Nr Buses",
       COALESCE("nspaces"::float, 0) AS "Nr Spaces",
       COALESCE(d."sbays"::integer, 0) AS "Bays Suspended", d."snotes" AS "Suspension Notes", "Demand" As "Demand",
             d."nnotes" AS "Surveyor Notes",
        su."RestrictionTypeID", su."Capacity"

FROM --"SYL_AllowableTimePeriods" syls,
      demand."Demand_Merged" d, demand."Surveys" s, mhtc_operations."Supply" su  -- include Supply to ensure that only current supply elements are included
WHERE s."SurveyID" = d."SurveyID"
AND d."GeometryID" = su."GeometryID"
ORDER BY  "GeometryID", d."SurveyID"




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
    SELECT "SurveyID", s."RoadName", SUM(s."CapacityFromDemand") AS "Capacity", SUM(d."Demand") AS "Demand"
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
