
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "SupplyCapacity" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "CapacityAtTimeOfSurvey" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Stress" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Suspended" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Waiting" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Idling" double precision;

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand_counts_sections"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 --vehicleLength real := 0.0;
	 --vehicleWidth real := 0.0;
	 --motorcycleWidth real := 0.0;
	 restrictionLength real := 0.0;
	 carPCU real := 0.0;
	 lgvPCU real := 0.0;
	 mclPCU real := 0.0;
	 ogvPCU real := 0.0;
	 busPCU real := 0.0;
	 pclPCU real := 0.0;
	 taxiPCU real := 0.0;
	 otherPCU real := 0.0;
	 minibusPCU real := 0.0;
	 docklesspclPCU real := 0.0;
	 escooterPCU real := 0.0;

	 NrCars INTEGER := 0;
	 NrLGVs INTEGER := 0;
	 NrMCLs INTEGER := 0;
	 NrTaxis INTEGER := 0;
	 NrPCLs INTEGER := 0;
	 NrEScooters INTEGER := 0;
	 NrDocklessPCLs INTEGER := 0;
	 NrOGVs INTEGER := 0;
	 NrMiniBuses INTEGER := 0;
	 NrBuses INTEGER := 0;
	 NrSpaces INTEGER := 0;
     Notes VARCHAR (10000);
     SuspensionReference VARCHAR (250);
    ReasonForSuspension VARCHAR (250);
    DoubleParkingDetails VARCHAR (250);
    NrCars_Suspended INTEGER := 0;
    NrLGVs_Suspended INTEGER := 0;
    NrMCLs_Suspended INTEGER := 0;
    NrTaxis_Suspended INTEGER := 0;
    NrPCLs_Suspended INTEGER := 0;
    NrEScooters_Suspended INTEGER := 0;
    NrDocklessPCLs_Suspended INTEGER := 0;
    NrOGVs_Suspended INTEGER := 0;
    NrMiniBuses_Suspended INTEGER := 0;
    NrBuses_Suspended INTEGER := 0;

    NrCarsWaiting INTEGER := 0;
    NrLGVsWaiting INTEGER := 0;
    NrMCLsWaiting INTEGER := 0;
    NrTaxisWaiting INTEGER := 0;
    NrOGVsWaiting INTEGER := 0;
    NrMiniBusesWaiting INTEGER := 0;
    NrBusesWaiting INTEGER := 0;

    NrCarsIdling INTEGER := 0;
    NrLGVsIdling INTEGER := 0;
    NrMCLsIdling INTEGER := 0;
    NrTaxisIdling INTEGER := 0;
    NrOGVsIdling INTEGER := 0;
    NrMiniBusesIdling INTEGER := 0;
    NrBusesIdling INTEGER := 0;

    NrCarsParkedIncorrectly INTEGER := 0;
    NrLGVsParkedIncorrectly INTEGER := 0;
    NrMCLsParkedIncorrectly INTEGER := 0;
    NrTaxisParkedIncorrectly INTEGER := 0;
    NrOGVsParkedIncorrectly INTEGER := 0;
    NrMiniBusesParkedIncorrectly INTEGER := 0;
    NrBusesParkedIncorrectly INTEGER := 0;

    NrCarsWithDisabledBadgeParkedInPandD INTEGER := 0;

    Supply_Capacity INTEGER := 0;
    Capacity INTEGER := 0;
	NrBaysSuspended INTEGER := 0;
	RestrictionTypeID INTEGER;

	controlled BOOLEAN;
	check_exists BOOLEAN;
	check_dual_restrictions_exists BOOLEAN;
	
	count_survey BOOLEAN;

    primary_geometry_id VARCHAR (12);
    secondary_geometry_id VARCHAR (12);
    time_period_id INTEGER;
	
	supply_calc RECORD;
	Restriction_Capacity INTEGER := 0;

BEGIN

    RAISE NOTICE '--- considering capacity for (%); survey (%) ', NEW."GeometryID", NEW."SurveyID";

    ---
    select "PCU" into carPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Car';

    select "PCU" into lgvPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'LGV';

    select "PCU" into mclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'MCL';

    select "PCU" into ogvPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'OGV';

    select "PCU" into busPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Bus';

    select "PCU" into pclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'PCL';

    select "PCU" into taxiPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Taxi';

    select "PCU" into otherPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Other';

    select "PCU" into minibusPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Minibus';

    select "PCU" into docklesspclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Dockless PCL';

    select "PCU" into escooterPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'E-Scooter';


    IF carPCU IS NULL OR lgvPCU IS NULL OR mclPCU IS NULL OR ogvPCU IS NULL OR busPCU IS NULL OR
       pclPCU IS NULL OR taxiPCU IS NULL OR otherPCU IS NULL OR minibusPCU IS NULL OR docklesspclPCU IS NULL OR escooterPCU IS NULL THEN
        RAISE NOTICE '--- (%); (%); (%); (%); (%); (%); (%); (%); (%); (%); (%) ', carPCU, lgvPCU, mclPCU, ogvPCU, busPCU, pclPCU, taxiPCU, otherPCU, minibusPCU, docklesspclPCU, escooterPCU;
        RAISE EXCEPTION 'PCU parameters not available ...';
        RETURN OLD;
    END IF;

    SELECT RiS."NrCars", RiS."NrLGVs", RiS."NrMCLs", RiS."NrTaxis", RiS."NrPCLs", RiS."NrEScooters", RiS."NrDocklessPCLs", RiS."NrOGVs", RiS."NrMiniBuses", RiS."NrBuses", RiS."NrSpaces",
        RiS."Notes", RiS."DoubleParkingDetails",
        RiS."NrCars_Suspended", RiS."NrLGVs_Suspended", RiS."NrMCLs_Suspended", RiS."NrTaxis_Suspended", RiS."NrPCLs_Suspended", RiS."NrEScooters_Suspended",
        RiS."NrDocklessPCLs_Suspended", RiS."NrOGVs_Suspended", RiS."NrMiniBuses_Suspended", RiS."NrBuses_Suspended",

        RiS."NrCarsWaiting", RiS."NrLGVsWaiting", RiS."NrMCLsWaiting", RiS."NrTaxisWaiting", RiS."NrOGVsWaiting", RiS."NrMiniBusesWaiting", RiS."NrBusesWaiting",

        RiS."NrCarsIdling", RiS."NrLGVsIdling", RiS."NrMCLsIdling",
        RiS."NrTaxisIdling", RiS."NrOGVsIdling", RiS."NrMiniBusesIdling",
        RiS."NrBusesIdling"

        , RiS."NrCarsParkedIncorrectly", RiS."NrLGVsParkedIncorrectly", RiS."NrMCLsParkedIncorrectly",
        RiS."NrTaxisParkedIncorrectly", RiS."NrOGVsParkedIncorrectly", RiS."NrMiniBusesParkedIncorrectly",
        RiS."NrBusesParkedIncorrectly",

        RiS."NrCarsWithDisabledBadgeParkedInPandD",

        RiS."NrBaysSuspended", s."RestrictionTypeID"

    INTO
        NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces,
        Notes, DoubleParkingDetails,
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended,
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended,

        NrCarsWaiting, NrLGVsWaiting, NrMCLsWaiting, NrTaxisWaiting, NrOGVsWaiting, NrMiniBusesWaiting, NrBusesWaiting,

        NrCarsIdling, NrLGVsIdling, NrMCLsIdling, NrTaxisIdling, NrOGVsIdling, NrMiniBusesIdling, NrBusesIdling

        ,NrCarsParkedIncorrectly, NrLGVsParkedIncorrectly, NrMCLsParkedIncorrectly,
        NrTaxisParkedIncorrectly, NrOGVsParkedIncorrectly, NrMiniBusesParkedIncorrectly,
        NrBusesParkedIncorrectly,

        NrCarsWithDisabledBadgeParkedInPandD

        ,NrBaysSuspended, RestrictionTypeID

	FROM demand."RestrictionsInSurveys" RiS, mhtc_operations2."Supply" s
	WHERE RiS."GeometryID" = s."GeometryID"
	AND RiS."GeometryID" = NEW."GeometryID"
	AND RiS."SurveyID" = NEW."SurveyID"
    ;

	/***
	--- Only every dealing with sections
	
	-- Check PCU value for MCL/PCL bays
	IF (RestrictionTypeID = 117 OR RestrictionTypeID = 118 OR   -- MCLs
		RestrictionTypeID = 116 OR RestrictionTypeID = 119 OR RestrictionTypeID = 168 OR 
		RestrictionTypeID = 169       -- PCLs
		) THEN
		RAISE NOTICE '--- MCL/PCL bay - changing PCU values FROM %; %; %; % ', mclPCU, pclPCU, docklesspclPCU, escooterPCU;
		mclPCU := 1.0;
		pclPCU := 1.0;
		docklesspclPCU := 1.0;
		escooterPCU := 1.0;
		RAISE NOTICE '--- MCL/PCL bay - changing PCU values TO %; %; %; % ', mclPCU, pclPCU, docklesspclPCU, escooterPCU;
	END IF;
	***/
	
	-- Now calculate values ...
	
	-- Now calculate values ...
	
    NEW."Demand" = COALESCE(NrCars::float, 0.0) * carPCU::float +
        COALESCE(NrLGVs::float, 0.0) * lgvPCU::float +
        COALESCE(NrMCLs::float, 0.0) * mclPCU::float +
        COALESCE(NrOGVs::float, 0.0) * ogvPCU::float + 
		COALESCE(NrMiniBuses::float, 0.0) * minibusPCU::float + 
		COALESCE(NrBuses::float, 0.0) * busPCU::float +
        COALESCE(NrTaxis::float, 0.0) * taxiPCU::float +
        COALESCE(NrPCLs::float, 0.0) * pclPCU::float +
        COALESCE(NrEScooters::float, 0.0) * escooterPCU::float +
        COALESCE(NrDocklessPCLs::float, 0.0) * docklesspclPCU::float +

        -- vehicles parked incorrectly
        COALESCE(NrCarsParkedIncorrectly::float, 0.0) * carPCU::float +
        COALESCE(NrLGVsParkedIncorrectly::float, 0.0) * lgvPCU::float +
        COALESCE(NrMCLsParkedIncorrectly::float, 0.0) * mclPCU::float +
        COALESCE(NrOGVsParkedIncorrectly::float, 0) * ogvPCU::float + 
		COALESCE(NrMiniBusesParkedIncorrectly::float, 0) * minibusPCU::float + 
		COALESCE(NrBusesParkedIncorrectly::float, 0) * busPCU::float +
        COALESCE(NrTaxisParkedIncorrectly::float, 0) * carPCU::float +

        -- vehicles in P&D bay displaying disabled badge
  		COALESCE(NrCarsWithDisabledBadgeParkedInPandD::float, 0.0) * carPCU::float
        ;

    NEW."Demand_Suspended" =
        -- include suspended vehicles
        COALESCE(NrCars_Suspended::float, 0.0) * carPCU::float +
        COALESCE(NrLGVs_Suspended::float, 0.0) * lgvPCU::float +
        COALESCE(NrMCLs_Suspended::float, 0.0) * mclPCU::float +
        COALESCE(NrOGVs_Suspended::float, 0) * ogvPCU::float + 
		COALESCE(NrMiniBuses_Suspended::float, 0) * minibusPCU::float + 
		COALESCE(NrBuses_Suspended::float, 0) * busPCU::float +
        COALESCE(NrTaxis_Suspended::float, 0) +
        COALESCE(NrPCLs_Suspended::float, 0.0) * pclPCU::float +
        COALESCE(NrEScooters_Suspended::float, 0.0) * escooterPCU::float +
        COALESCE(NrDocklessPCLs_Suspended::float, 0.0) * docklesspclPCU::float;

    NEW."Demand_Waiting" =
        -- vehicles waiting
        COALESCE(NrCarsWaiting::float, 0.0) * carPCU::float +
        COALESCE(NrLGVsWaiting::float, 0.0) * lgvPCU::float +
        COALESCE(NrMCLsWaiting::float, 0.0) * mclPCU::float +
        COALESCE(NrOGVsWaiting::float, 0) * ogvPCU::float + 
		COALESCE(NrMiniBusesWaiting::float, 0) * minibusPCU::float + 
		COALESCE(NrBusesWaiting::float, 0) * busPCU::float +
        COALESCE(NrTaxisWaiting::float, 0) * carPCU::float;

    NEW."Demand_Idling" =
        -- vehicles idling
        COALESCE(NrCarsIdling::float, 0.0) * carPCU::float +
        COALESCE(NrLGVsIdling::float, 0.0) * lgvPCU::float +
        COALESCE(NrMCLsIdling::float, 0.0) * mclPCU::float +
        COALESCE(NrOGVsIdling::float, 0) * ogvPCU::float + 
		COALESCE(NrMiniBusesIdling::float, 0) * minibusPCU::float + 
		COALESCE(NrBusesIdling::float, 0) * busPCU::float +
        COALESCE(NrTaxisIdling::float, 0) * carPCU::float;

	-- Loop through each restriction in the section to determine supply values
	
	FOR supply_calc IN
		SELECT
			"GeometryID", "Capacity", "RestrictionTypeID"
		FROM mhtc_operations."Supply"
		WHERE "DemandSection_GeometryID" = NEW."GeometryID"
			
	LOOP

		Supply_Capacity = supply_calc."Capacity";
		
		/* What to do about suspensions */

		IF (supply_calc."RestrictionTypeID" = 201 OR supply_calc."RestrictionTypeID" = 221 OR supply_calc."RestrictionTypeID" = 224 OR   -- SYLs
			supply_calc."RestrictionTypeID" = 217 OR supply_calc."RestrictionTypeID" = 222 OR supply_calc."RestrictionTypeID" = 226 OR   -- SRLs
			supply_calc."RestrictionTypeID" = 227 OR supply_calc."RestrictionTypeID" = 228 OR supply_calc."RestrictionTypeID" = 220      -- Unmarked within PPZ
			) THEN

			-- Need to check whether or not effected by control hours

			RAISE NOTICE '--- checking SYL capacity for (%); survey (%) ', NEW."GeometryID", NEW."SurveyID";

			SELECT EXISTS INTO check_exists (
				SELECT FROM
					pg_tables
				WHERE
					schemaname = 'demand' AND
					tablename  = 'TimePeriodsControlledDuringSurveyHours'
				) ;

			IF check_exists THEN

				SELECT "Controlled"
				INTO controlled
				FROM mhtc_operations."Supply" s, demand."TimePeriodsControlledDuringSurveyHours" t
				WHERE s."GeometryID" = supply_calc."GeometryID"
				AND s."NoWaitingTimeID" = t."TimePeriodID"
				AND t."SurveyID" = NEW."SurveyID";

				IF controlled THEN
					RAISE NOTICE '*****--- capacity set to 0 ...';
					Supply_Capacity = 0.0;
				END IF;

			END IF;

		END IF;

		-- Now consider dual restrictions

		SELECT EXISTS INTO check_dual_restrictions_exists (
		SELECT FROM
			pg_tables
		WHERE
			schemaname = 'mhtc_operations' AND
			tablename  = 'DualRestrictions'
		) ;

		IF check_dual_restrictions_exists THEN
			-- check for primary

			SELECT d."GeometryID", "LinkedTo", COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
			INTO secondary_geometry_id, primary_geometry_id, time_period_id
			FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
			WHERE s."GeometryID" = d."GeometryID"
			AND d."LinkedTo" = NEW."GeometryID";

			IF primary_geometry_id IS NOT NULL THEN

				-- restriction is "primary". Need to check whether or not the linked restriction is active
				RAISE NOTICE '*****--- % Primary restriction. Checking time period % ...', NEW."GeometryID", time_period_id;

				SELECT "Controlled"
				INTO controlled
				FROM demand."TimePeriodsControlledDuringSurveyHours" t
				WHERE t."TimePeriodID" = time_period_id
				AND t."SurveyID" = NEW."SurveyID";

				-- TODO: Deal with multiple secondary bays ...

				IF controlled THEN
					RAISE NOTICE '*****--- Primary restriction. Setting capacity set to 0 ...';
					Supply_Capacity = 0.0;
				END IF;

			END IF;

			-- Now check for secondary

			SELECT d."GeometryID", "LinkedTo", COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
			INTO secondary_geometry_id, primary_geometry_id, time_period_id
			FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
			WHERE s."GeometryID" = d."GeometryID"
			AND d."GeometryID" = NEW."GeometryID";

			IF secondary_geometry_id IS NOT NULL THEN

				-- restriction is "secondary". Need to check whether or not it is active
				RAISE NOTICE '*****--- % Secondary restriction. Checking time period % ...', NEW."GeometryID", time_period_id;

				SELECT "Controlled"
				INTO controlled
				FROM demand."TimePeriodsControlledDuringSurveyHours" t
				WHERE t."TimePeriodID" = time_period_id
				AND t."SurveyID" = NEW."SurveyID";

				IF NOT controlled OR controlled IS NULL THEN
					RAISE NOTICE '*****--- Secondary restriction. Setting capacity set to 0 ...';
					Supply_Capacity = 0.0;
				END IF;

			END IF;
		END IF;

		Restriction_capacity = Restriction_capacity + Supply_Capacity;
		
    END LOOP;
	
    Capacity = COALESCE(Restriction_capacity::float, 0.0) - COALESCE(NrBaysSuspended::float, 0.0);
    IF Capacity < 0.0 THEN
        Capacity = 0.0;
    END IF;
    NEW."SupplyCapacity" = Restriction_capacity;
    NEW."CapacityAtTimeOfSurvey" = Capacity;

    IF Capacity <= 0.0 THEN
        IF NEW."Demand" > 0.0 THEN
            NEW."Stress" = 1.0;
        ELSE
            NEW."Stress" = 0.0;
        END IF;
    ELSE
        NEW."Stress" = NEW."Demand"::float / Capacity::float;
    END IF;

	RETURN NEW;

END;
$$;

-- create trigger

DROP TRIGGER IF EXISTS update_demand ON demand."RestrictionsInSurveys";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."RestrictionsInSurveys" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_counts_sections"();

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

