/***
 * Set capacity values based on demand results
 ***/

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN "CapacityFromDemand" INTEGER;

-- Look for sections that have no demand

DO
$do$
DECLARE
    relevant_restriction RECORD;
    relevant_count RECORD;
    zero_capacity BOOLEAN := true;
BEGIN

    -- ** Bays
    FOR relevant_restriction IN
        SELECT DISTINCT "GeometryID"
        FROM mhtc_operations."Supply"
    LOOP

        zero_capacity = true;

        FOR relevant_count IN
            SELECT "SurveyID", "GeometryID",
               SUM(COALESCE("NrCars"::float, 0.0) +
                COALESCE("NrLGVs"::float, 0.0) +
                COALESCE("NrMCLs"::float, 0.0)*0.33 +
                (COALESCE("NrOGVs"::float, 0.0) + COALESCE("NrMiniBuses"::float, 0.0) + COALESCE("NrBuses"::float, 0.0))*1.5 +
                COALESCE("NrTaxis"::float, 0.0)) AS "Demand in Bays",
                SUM("NrSpaces") AS "Spaces",
                SUM(COALESCE("NrCars_Suspended"::float, 0.0) +
                COALESCE("NrLGVs_Suspended"::float, 0.0) +
                COALESCE("NrMCLs_Suspended"::float, 0.0)*0.33 +
                (COALESCE("NrOGVs_Suspended"::float, 0) + COALESCE("NrMiniBuses_Suspended"::float, 0) + COALESCE("NrBuses_Suspended"::float, 0))*1.5 +
                COALESCE("NrTaxis_Suspended"::float, 0)) As "Demand in Bays"
               FROM demand."Counts"
               WHERE "GeometryID" = relevant_restriction."GeometryID"
               GROUP BY "SurveyID", "GeometryID"
        LOOP

            IF relevant_count."Demand in Bays" + relevant_count."Demand in Bays" > 0 THEN
                zero_capacity = false;
                EXIT;
            END IF;

        END LOOP;

        IF zero_capacity = true THEN

			RAISE NOTICE '*****--- Setting capacity to 0 for (%)', relevant_restriction."GeometryID";

            UPDATE mhtc_operations."Supply"
            SET "CapacityFromDemand" = 0
            WHERE "GeometryID" = relevant_restriction."GeometryID";
            
		ELSE

		    UPDATE mhtc_operations."Supply"
            SET "CapacityFromDemand" = relevant_restriction."Capacity"
            WHERE "GeometryID" = relevant_restriction."GeometryID";

        END IF;

    END LOOP;

END;
$do$;
