CREATE TABLE "mhtc_operations"."project_parameters" (
    "Field" character varying NOT NULL,
    "Value" character varying NOT NULL
);

ALTER TABLE ONLY "mhtc_operations"."project_parameters"
    ADD CONSTRAINT "project_parameters_pkey" PRIMARY KEY ("Field");

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "mhtc_operations"."project_parameters" TO toms_admin;
GRANT SELECT ON TABLE "mhtc_operations"."project_parameters" TO toms_operator, toms_public;

INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('VehicleLength', '5.0');
INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('VehicleWidth', '2.5');
INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('MotorcycleWidth', '1.0');

--
ALTER TABLE demand."MASTER_Demand_01_Weekday_Weekday_Overnight"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."MASTER_Demand_01_Weekday_Weekday_Overnight"
    ADD COLUMN "Stress" double precision;
ALTER TABLE demand."MASTER_Demand_01_Weekday_Weekday_Overnight"
    ADD COLUMN "SurveyDate_Rounded" character varying;

--
ALTER TABLE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon"
    ADD COLUMN "Stress" double precision;
ALTER TABLE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon"
    ADD COLUMN "SurveyDate_Rounded" character varying;

--
ALTER TABLE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon"
    ADD COLUMN "Stress" double precision;
ALTER TABLE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon"
    ADD COLUMN "SurveyDate_Rounded" character varying;

--
ALTER TABLE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon"
    ADD COLUMN "Stress" double precision;
ALTER TABLE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon"
    ADD COLUMN "SurveyDate_Rounded" character varying;

--
CREATE UNIQUE INDEX idx_geometry_id_01
ON demand."MASTER_Demand_01_Weekday_Weekday_Overnight" ("GeometryID");

CREATE UNIQUE INDEX idx_geometry_id_02
ON demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" ("GeometryID");

CREATE UNIQUE INDEX idx_geometry_id_03
ON demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" ("GeometryID");

CREATE UNIQUE INDEX idx_geometry_id_04
ON demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" ("GeometryID");

/*
ALTER TABLE demand."MASTER_Demand_01_Weekday_Weekday_Overnight"
    ALTER COLUMN "Demand" TYPE double precision;
ALTER TABLE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon"
    ALTER COLUMN "Demand" TYPE double precision;
ALTER TABLE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon"
    ALTER COLUMN "Demand" TYPE double precision;
ALTER TABLE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon"
    ALTER COLUMN "Demand" TYPE double precision;
*/

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "public"."lbhf_update_demand"() RETURNS "trigger"
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

    NEW."Demand" = COALESCE(NEW."ncars"::float, 0.0) + COALESCE(NEW."nlgvs"::float, 0.0) + COALESCE(NEW."nmcls"::float, 0.0)*0.33 + (COALESCE(NEW."nogvs"::float, 0) + COALESCE(NEW."nogvs2"::float, 0) + COALESCE(NEW."nminib"::float, 0) + COALESCE(NEW."nbuses"::float, 0))*1.5  + COALESCE(NEW."ntaxis"::float, 0);

    /* What to do about suspensions */

    CASE
        WHEN NEW."Capacity" = 0 THEN
            CASE
                WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                ELSE NEW."Stress" = 0.0;
            END CASE;
        ELSE
            CASE
                WHEN NEW."Capacity"::float - COALESCE(NEW."sbays"::float, 0.0) > 0.0 THEN
                    NEW."Stress" = NEW."Demand" / (NEW."Capacity"::float - COALESCE(NEW."sbays"::float, 0.0));
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

--CREATE TRIGGER "lbhf_update_demand_1" BEFORE INSERT OR UPDATE ON "demand"."MASTER_Demand_01_Weekday_Weekday_Overnight" FOR EACH ROW EXECUTE FUNCTION "public"."lbhf_update_demand"();

-- trigger trigger

UPDATE "demand"."MASTER_Demand_01_Weekday_Weekday_Overnight" SET "RestrictionLength" = "RestrictionLength";
UPDATE "demand"."MASTER_Demand_02_Weekday_Weekday_Afternoon" SET "RestrictionLength" = "RestrictionLength";
UPDATE "demand"."MASTER_Demand_03_Saturday_Saturday_Afternoon" SET "RestrictionLength" = "RestrictionLength";
UPDATE "demand"."MASTER_Demand_04_Sunday_Sunday_Afternoon" SET "RestrictionLength" = "RestrictionLength";

UPDATE demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a
	SET "Capacity"=b."CarCapacity"
	FROM demand."LBHF_ParkingStress_2016_WeekdayOvernight" b
WHERE a."GeometryID" = b."GeometryID"
AND a."SurveyID"::integer = b."SurveyType";

UPDATE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" AS a
	SET "Capacity"=b."CarCapacity"
	FROM demand."LBHF_ParkingStress_2016_WeekdayAfternoon" b
WHERE a."GeometryID" = b."GeometryID"
AND a."SurveyID"::integer = b."SurveyType";

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
	SET "Capacity"=b."CarCapacity"
	FROM demand."LBHF_ParkingStress_2016_SaturdayAfternoon" b
WHERE a."GeometryID" = b."GeometryID"
AND a."SurveyID"::integer = b."SurveyType";

UPDATE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
	SET "Capacity"=b."CarCapacity"
	FROM demand."LBHF_ParkingStress_2016_SundayAfternoon" b
WHERE a."GeometryID" = b."GeometryID"
AND a."SurveyID"::integer = b."SurveyType";

-- ensure survey dates are correct (as best we can)

UPDATE demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a
SET "surveyHour" = date_part('hour', ("SurveyDate"::timestamp)),
    "SurveyDate_Rounded" = CASE WHEN date_part('hour', ("SurveyDate"::timestamp))::int > 20 THEN to_char("SurveyDate"::timestamp + interval '1 day', 'YYYY-MM-DD')
                                ELSE to_char("SurveyDate"::timestamp, 'YYYY-MM-DD')
								END;

UPDATE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" AS a
SET "SurveyDate_Rounded" = to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
SET "SurveyDate_Rounded" = to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

UPDATE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
SET "SurveyDate_Rounded" = to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

-- Now deal with specifics ...
-- car
SELECT DISTINCT "Area", "Section", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD')
FROM demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
WHERE "Area"::int = 2 --AND "Section"::int IN (3)
ORDER BY "Area", "Section", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

--
--NB: Some car data entry done on 4/10 - need to check ...
-- Saturday (Area 1 section 1,2,3,5) should be 12/9 except for activity on 19/9; Area 2 section 3 should be 19/9
-- Sunday (Area 1 section 1,2,3,5 and Area 2 section 1 should be 13/9 except for 20/9??

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-09-12'
WHERE "Area"::int = 1 AND "Section"::int IN (1,2,3,5)
AND  "SurveyDate_Rounded" NOT IN ('2020-09-19', '2020-09-26', '2020-10-03');

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-09-12'
WHERE "Area"::int = 2 AND "Section"::int IN (1)
AND  "SurveyDate_Rounded" NOT IN ('2020-09-19', '2020-09-26', '2020-10-03');

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-09-19'
WHERE "Area"::int = 2 AND "Section"::int IN (3)
AND  "SurveyDate_Rounded" NOT IN ('2020-09-19', '2020-09-26', '2020-10-03');

UPDATE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-09-13'
WHERE "Area"::int = 1 AND "Section"::int IN (1,2,3,5)
AND  "SurveyDate_Rounded" NOT IN ('2020-09-20', '2020-09-27', '2020-10-04');

UPDATE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-09-13'
WHERE "Area"::int = 2 AND "Section"::int IN (1, 2, 3, 4, 5)
AND  "SurveyDate_Rounded" NOT IN ('2020-09-20', '2020-09-27', '2020-10-04');

--
-- Check survey on correct Day of Week

SELECT "GeometryID", "Area", "Section", "SurveyDate", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD'), to_char("SurveyDate_Rounded"::timestamp, 'D')
FROM demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a
WHERE to_char("SurveyDate_Rounded"::timestamp, 'D')::int NOT IN (3,4,5)
ORDER BY "Area", "Section", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

SELECT "GeometryID", "Area", "Section", "SurveyDate", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD'), to_char("SurveyDate_Rounded"::timestamp, 'D')
FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" AS a
WHERE to_char("SurveyDate_Rounded"::timestamp, 'D')::int NOT IN (3,4,5)
ORDER BY "Area", "Section", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

SELECT "GeometryID", "Area", "Section", "SurveyDate", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD'), to_char("SurveyDate_Rounded"::timestamp, 'D')
FROM demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
WHERE to_char("SurveyDate_Rounded"::timestamp, 'D')::int <> 7
ORDER BY "Area", "Section", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD');

SELECT "GeometryID", "Area", "Section", "SurveyDate", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD'), to_char("SurveyDate_Rounded"::timestamp, 'D')
FROM demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
WHERE "Area"::int = 2 --AND "Section"::int IN (3)
AND to_char("SurveyDate_Rounded"::timestamp, 'D')::int <> 1
ORDER BY "Area", "Section", to_char("SurveyDate"::timestamp, 'YYYY-MM-DD')

-- issues with:
 -- Saturday (Area 1 section 4 should be set as 3/10; Area 4 section 2 should be set as 3/10)

UPDATE demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a
SET "SurveyDate_Rounded" = '2020-10-03'
WHERE "Area"::int = 1 AND "Section"::int IN (4);

UPDATE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-10-03'
WHERE "Area"::int = 4 AND "Section"::int IN (2);

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
SET "SurveyDate_Rounded" = '2020-09-12'
WHERE "Area"::int = 3 AND "Section"::int IN (2)
AND to_char("SurveyDate"::timestamp, 'YYYY-MM-DD') = '2020-10-12';

-- suzie recording lgvs as ogvs
SELECT "GeometryID", "SurveyID", "SurveyDate", "Area", "Section", nlgvs, nogvs
FROM demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a
WHERE nogvs::int > 0
AND "SurveyDate"::timestamp < '2020-09-28'
UNION
SELECT "GeometryID", "SurveyID", "SurveyDate", "Area", "Section", nlgvs, nogvs
FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" AS a
WHERE nogvs::int > 0
AND "SurveyDate"::timestamp < '2020-09-28'
UNION
SELECT "GeometryID", "SurveyID", "SurveyDate", "Area", "Section", nlgvs, nogvs
FROM demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
WHERE nogvs::int > 0
AND "SurveyDate"::timestamp < '2020-09-28'
UNION
SELECT "GeometryID", "SurveyID", "SurveyDate", "Area", "Section", nlgvs, nogvs
FROM demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
WHERE nogvs::int > 0
AND "SurveyDate"::timestamp < '2020-09-28'
ORDER BY "SurveyID", "SurveyDate";

--

UPDATE demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a
SET nlgvs = "nogvs", "nogvs" = NULL
WHERE nogvs::int > 0
AND nlgvs IS NULL
--AND "SurveyDate"::timestamp < '2020-09-21';

UPDATE demand."MASTER_Demand_02_Weekday_Weekday_Afternoon" AS a
SET nlgvs = "nogvs", "nogvs" = NULL
WHERE nogvs::int > 0
AND nlgvs IS NULL
--AND "SurveyDate"::timestamp < '2020-09-21';

UPDATE demand."MASTER_Demand_03_Saturday_Saturday_Afternoon" AS a
SET nlgvs = "nogvs", "nogvs" = NULL
WHERE nogvs::int > 0
AND nlgvs IS NULL
--AND "SurveyDate"::timestamp < '2020-09-21';

UPDATE demand."MASTER_Demand_04_Sunday_Sunday_Afternoon" AS a
SET nlgvs = "nogvs", "nogvs" = NULL
WHERE nogvs::int > 0
AND nlgvs IS NULL
--AND "SurveyDate"::timestamp < '2020-09-21';


-- output

SELECT "GeometryID", "RoadName", "USRN", "STREETSIDE", "STREETFROM", "STREETTO", "Section", "Area", "CPZ", "RestrictionLength", "SurveyID", "SurveyDate", "SurveyDay", "SurveyTime", "Done", ncars, nlgvs, nmcls, nogvs, ntaxis, nminib, nbuses, nbikes, nogvs2, nspaces, nnotes, sref, sbays, sreason, snotes, "Photos_01", "Capacity", "Demand", "Stress", "surveyHour", "SurveyDate_Rounded"
	FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon";

-- deal with "incorrect" times for overnight...

SELECT "GeometryID", "SurveyDate", "surveyHour",
date_part('hour', to_timestamp("SurveyDate", 'YYYY-MM-DDTHH:MI:SS.MS')),
CASE WHEN "surveyHour"::int > 20 THEN DATE(to_timestamp("SurveyDate", 'YYYY-MM-DDTHH:MI:SS.MS')) + interval '1 day'
                                ELSE EXTRACT(YEAR FROM ("SurveyDate"::timestamp))
								END
FROM demand."MASTER_Demand_01_Weekday_Weekday_Overnight" AS a


-- reset sections
UPDATE "Demand_03_Saturday_Saturday_Afternoon" AS o
	SET  "Done"=NULL,
    ncars=NULL, nlgvs=NULL, nmcls=NULL, nogvs=NULL, ntaxis=NULL, nminib=NULL, nbuses=NULL, nbikes=NULL, nogvs2=NULL, nspaces=NULL, nnotes=NULL,
    sref=NULL, sbays=NULL, sreason=NULL, scars=NULL, slgvs=NULL, smcls=NULL, sogvs=NULL, staxis=NULL, sbikes=NULL, sbuses=NULL, sogvs2=NULL, sminib=NULL, snotes=NULL,
    dcars=NULL, dlgvs=NULL, dmcls=NULL, dogvs=NULL, dtaxis=NULL, dbikes=NULL, dbuses=NULL, dogvs2=NULL, dminib=NULL,
    "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL
	WHERE o."Section"= '4' AND o."Area"='1'
	AND o."Done" = 'true'