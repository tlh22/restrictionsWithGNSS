
-- Step 1: Add new fields

alter table demand."Demand_Merged"
    add COLUMN "Demand" double precision;
alter table demand."Demand_Merged"
    add COLUMN "Stress" double precision;

-- Step 2: calculate demand values using trigger

-- set up trigger for demand and stress

create or replace function "demand"."update_demand"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    as $$
DECLARE
	 vehicleLength real := 0.0;
	 vehicleWidth real := 0.0;
	 motorcycleWidth real := 0.0;
	 restrictionLength real := 0.0;
	 supply_capacity int := 0;
begin

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
                    --+ COALESCE(NULLIF(NEW."nogvs2",'')::float, 0) * 2.3
                    + COALESCE(NULLIF(NEW."nbuses",'')::float, 0) * 2.0
                    + COALESCE(NULLIF(NEW."ntaxis",'')::float, 0);

    /* What to do about suspensions */

    SELECT "Capacity" INTO supply_capacity
    FROM mhtc_operations."Supply"
    WHERE "GeometryID" = NEW."GeometryID";

    CASE
        WHEN supply_capacity = 0 THEN
            CASE
                WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 1.0;
                ELSE NEW."Stress" = 0.0;
            END CASE;
        ELSE
            CASE
                WHEN supply_capacity::float - COALESCE(NULLIF(NEW."sbays",'')::float, 0.0) > 0.0 THEN
                    NEW."Stress" = NEW."Demand" / (NEW."Capacity"::float - COALESCE(NULLIF(NEW."sbays",'')::float, 0.0)) * 1.0;
                ELSE
                    CASE
                        WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 1.0;
                        ELSE NEW."Stress" = 0.0;
                    END CASE;
            END CASE;
    END CASE;

	RETURN NEW;

END;
$$;

-- create trigger

DROP trigger IF EXISTS "update_demand" ON "demand"."Demand_Merged";
create trigger "update_demand" before insert or update on "demand"."Demand_Merged" for each row EXECUTE function "demand"."update_demand"();

-- trigger trigger

UPDATE "demand"."Demand_Merged" SET "RestrictionLength" = "RestrictionLength";

-- Update capacity

UPDATE "demand"."Demand_Merged" AS d
SET "Capacity" = s."Capacity"
FROM mhtc_operations."Supply" s
WHERE s."GeometryID" = d."GeometryID";

-- Step 3: output demand

SELECT
d."SurveyID", s."SurveyDay" As "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" As "Survey Time", "GeometryID", "Done",

       (COALESCE(NULLIF("ncars",'')::float, 0) +COALESCE(NULLIF("ntaxis",'')::float, 0)) As "Nr Cars", COALESCE(NULLIF("nlgvs",'')::float, 0) As "Nr LGVs",
       COALESCE(NULLIF("nmcls",'')::float, 0) AS "Nr MCLs", COALESCE(NULLIF("nogvs",'')::float, 0) AS "Nr OGVs", COALESCE(NULLIF("nbuses",'')::float, 0) AS "Nr Buses",
       --COALESCE(NULLIF("nogv2s",'')::float, 0) AS "Nr OGV2s",
       COALESCE(NULLIF("nbikes",'')::float, 0) AS "Nr PCLs",
       COALESCE(NULLIF("nspaces",'')::float, 0) AS "Nr Spaces",
       COALESCE(NULLIF(d."sbays",'')::integer, 0) AS "Bays Suspended", d."snotes" AS "Suspension Notes", "Demand" As "Demand",

             d."nnotes" AS "Surveyor Notes"

FROM --"SYL_AllowableTimePeriods" syls,
      demand."Surveys" s,
      (SELECT s."GeometryID",
      "SurveyID", "DemandSurveyDateTime", "Done", ncars, nlgvs, nmcls, nogvs, ntaxis, nminib, nbuses, nbikes,
	   --nogvs2,
	   nspaces, nnotes,
      sref, sbays, sreason, scars, slgvs, smcls, sogvs, staxis, sbikes, sbuses,
	  --sogvs2,
	  sminib, snotes,
      dcars, dlgvs, dmcls, dogvs, dtaxis, dbikes, dbuses,
	  --dogvs2,
	  dminib, "Demand", "Stress"
	  FROM demand."Demand_Merged" de, mhtc_operations."Supply" s
	  WHERE de."GeometryID" = s."GeometryID"
	  AND de."Done" IS TRUE) As d
WHERE s."SurveyID" = d."SurveyID"

UNION

SELECT
d."SurveyID", s."SurveyDay" As "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" As "Survey Time", "GeometryID", "Done",

       0 As "Nr Cars", 0 As "Nr LGVs",
       0 AS "Nr MCLs", 0 AS "Nr OGVs", 0 AS "Nr Buses",
       --0 AS "Nr OGV2s",
       0 AS "Nr PCLs",
       0 AS "Nr Spaces",
       0 AS "Bays Suspended", d."snotes" AS "Suspension Notes", 0 As "Demand",

             '' AS "Surveyor Notes"

FROM --"SYL_AllowableTimePeriods" syls,
      demand."Surveys" s,
      (SELECT s."GeometryID",
      "SurveyID", "DemandSurveyDateTime", "Done", ncars, nlgvs, nmcls, nogvs, ntaxis, nminib, nbuses, nbikes,
	  --nogvs2,
	  nspaces, nnotes,
      sref, sbays, sreason, scars, slgvs, smcls, sogvs, staxis, sbikes, sbuses,
	  --sogvs2,
	  sminib, snotes,
      dcars, dlgvs, dmcls, dogvs, dtaxis, dbikes, dbuses,
	  --dogvs2,
	  dminib, "Demand", "Stress"
	  FROM demand."Demand_Merged" de, mhtc_operations."Supply" s
	  WHERE de."GeometryID" = s."GeometryID"
	  AND (de."Done" IS FALSE OR de."Done" IS NULL)) As d
WHERE s."SurveyID" = d."SurveyID"

ORDER BY  "GeometryID", "SurveyID"