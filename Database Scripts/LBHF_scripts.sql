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





SELECT "GeometryID", "RoadName", "USRN", "STREETSIDE", "STREETFROM", "STREETTO", "Section", "Area", "CPZ", "RestrictionLength", "SurveyID", "SurveyDate", "SurveyDay", "SurveyTime", "Done", ncars, nlgvs, nmcls, nogvs, ntaxis, nminib, nbuses, nbikes, nogvs2, nspaces, nnotes, sref, sbays, sreason, snotes, "Photos_01", "Capacity", "Demand", "Stress", "surveyHour", "SurveyDate_Rounded"
	FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon";