-- Step 1: Add new fields

ALTER TABLE demand."Demand_Merged"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."Demand_Merged"
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

    /*
    IF vehicleLength IS NULL OR vehicleWidth IS NULL OR motorcycleWidth IS NULL THEN
        RAISE EXCEPTION 'Capacity parameters not available ...';
        RETURN OLD;
    END IF;
    */

    NEW."Demand" = COALESCE(NULLIF(NEW."ncars",'')::float, 0.0) + COALESCE(NULLIF(NEW."nlgvs",'')::float, 0.0) + COALESCE(NULLIF(NEW."nminib",'')::float, 0.0)
                    + COALESCE(NULLIF(NEW."nmcls",'')::float, 0.0)*0.4
                    + COALESCE(NULLIF(NEW."nbikes", '')::float, 0.0) * 0.2
                    + COALESCE(NULLIF(NEW."nogvs",'')::float, 0) * 1.5
                    + COALESCE(NULLIF(NEW."nogvs2",'')::float, 0) * 2.3
                    + COALESCE(NULLIF(NEW."nbuses",'')::float, 0) * 2.0
                    + COALESCE(NULLIF(NEW."ntaxis",'')::float, 0);

    /* What to do about suspensions */

    CASE
        WHEN NEW."Capacity" = 0 THEN
            CASE
                WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                ELSE NEW."Stress" = 0.0;
            END CASE;
        ELSE
            CASE
                WHEN NEW."Capacity"::float - COALESCE(NULLIF(NEW."sbays",'')::float, 0.0) > 0.0 THEN
                    NEW."Stress" = NEW."Demand" / (NEW."Capacity"::float - COALESCE(NULLIF(NEW."sbays",'')::float, 0.0)) * 100.0;
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

DROP TRIGGER IF EXISTS "update_demand" ON "demand"."Demand_Merged";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."Demand_Merged" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand"();

-- trigger trigger

UPDATE "demand"."Demand_Merged" SET "RestrictionLength" = "RestrictionLength";

-- Step 3: output demand

SELECT
d."SurveyID", s."SurveyDay" As "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" As "Survey Time", "GeometryID",

       (COALESCE(NULLIF("ncars",'')::float, 0) +COALESCE(NULLIF("ntaxis",'')::float, 0)) As "Nr Cars", COALESCE(NULLIF("nlgvs",'')::float, 0) As "Nr LGVs",
       COALESCE(NULLIF("nmcls",'')::float, 0) AS "Nr MCLs", COALESCE(NULLIF("nogvs",'')::float, 0) AS "Nr OGVs", COALESCE(NULLIF("nbuses",'')::float, 0) AS "Nr Buses",
       COALESCE(NULLIF("nogv2s",'')::float, 0) AS "Nr OGV2s", COALESCE(NULLIF("nbikes",'')::float, 0) AS "Nr PCLs",
       COALESCE(NULLIF("nspaces",'')::float, 0) AS "Nr Spaces",
       COALESCE(NULLIF(d."sbays",'')::integer, 0) AS "Bays Suspended", d."snotes" AS "Suspension Notes", "Demand" As "Demand",

             d."nnotes" AS "Surveyor Notes"

FROM --"SYL_AllowableTimePeriods" syls,
      demand."Demand_Merged" d, demand."Surveys" s
WHERE s."SurveyID" = d."SurveyID"
ORDER BY  "GeometryID", d."SurveyID"

