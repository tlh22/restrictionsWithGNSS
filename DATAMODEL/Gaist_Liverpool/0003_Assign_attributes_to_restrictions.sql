/***
 Using the links from the signs, assign attributes - restriction types and times 
 
 Also need to identify restrictions that require checking
 
 ***/

-- Set up required fields

ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "RestrictionTypeID" integer;
	
ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "TimePeriodID" integer;
	
ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "MaxStayID" integer;
	
ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "NoReturnID" integer;
	
ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "NoWaitingTimeID" integer;

ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "NoLoadingTimeID" integer;	

/***
-- Deal with "easy" ones
Restriction types are:
1017 - SYL
1018.1 - DYL
1025.1.3.4 - Bus Stop
1027.1 - Zig Zag
1028.1.4 - Parking bay
***/

-- DYL
UPDATE local_authority."Gaist_RoadMarkings_Lines"
SET "RestrictionTypeID" = 202, "NoWaitingTimeID" = 1
WHERE "Dft Diagra" = '1018.1';

-- SYL
UPDATE local_authority."Gaist_RoadMarkings_Lines"
SET "RestrictionTypeID" = 224
WHERE "Dft Diagra" = '1017';

-- Bus stop 
UPDATE local_authority."Gaist_RoadMarkings_Lines"
SET "RestrictionTypeID" = 107
WHERE "Dft Diagra" IN ( '1025.1', '1025.3', '1025.4');



-- *** NOW look at times 
UPDATE local_authority."Gaist_RoadMarkings_Lines"
SET "NoWaitingTimeID" = NULL, "NoLoadingTimeID" = NULL;

-- DYL
UPDATE local_authority."Gaist_RoadMarkings_Lines"
SET "NoWaitingTimeID" = 1
WHERE "RestrictionTypeID" = 202;

-- Now look for restrictions that are only associated with one sign 

-- Disabled bay
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Disabled bay
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('661A')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 110
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";

		raise notice 'record: (Disabled) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 110;
	
    END LOOP;
end; $$;

-- Pay and Display bay
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Pay and Display bay
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('661.2A')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 103
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
		
		raise notice 'record: (P&D) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 103;

    END LOOP;
end; $$;

-- Permit holder bay
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Permit holder bay
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('660', '660.3')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 131
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
		
		raise notice 'record: (Permit holder) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 131;

    END LOOP;
end; $$;

-- Loading bay
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Loading bay
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('660.4')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 114
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
		
		raise notice 'record: (Loading) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 114;

    END LOOP;
end; $$;

-- Shared Use bay (with limited waiting)
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Shared Use bay (with limited waiting)
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('660.6')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 136, "TimePeriodID" = s."MHTC_TimePeriodCode", "MaxStayID" = s."MHTC_MaxStayCode", "NoReturnID" = s."MHTC_NoReturnCode"
		FROM local_authority."Gaist_Signs" s
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID"
		AND s."GeometryID" = restrictions_with_one_sign."SignGeometryID";
		
		raise notice 'record: (Shared Use bay (with limited waiting)) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 136;

    END LOOP;
end; $$;

-- Parking place
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Parking place
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('801')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 127
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
		
		raise notice 'record: (Parking place) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 127;

    END LOOP;
end; $$;

-- Bus only bay
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- Bus only bay
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."Dft Diagra" IN ('1028.1', '1028.4')
			AND s."Dft Diagra" IN ('969')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "RestrictionTypeID" = 109
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
		
		raise notice 'record: (Bus only bay) %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", 109;

    END LOOP;
end; $$;

-- *** TIMES
-- SYL times
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- SYL
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."RestrictionTypeID" IN (224)
			AND s."Dft Diagra" IN ('637.3', '639')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
	
		time_code = NULL;
		-- Get the sign time code
		SELECT t."Code"
		INTO time_code
		FROM local_authority."Gaist_Signs" s, toms_lookups."TimePeriods" t
		WHERE s."MHTC_TimePeriodCode" = t."Code"
		AND s."GeometryID" = restrictions_with_one_sign."SignGeometryID";
		
		raise notice 'record: %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", time_code;
		
		IF NOT found OR time_code IS NULL THEN
			CONTINUE;
		END IF;
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "NoWaitingTimeID" = time_code
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
	
    END LOOP;
end; $$;

-- get any loading times - 638 = at any time; 638.1 (time periods)
do $$
DECLARE
	restrictions_with_one_sign RECORD;
	time_code INTEGER;
	
begin

	-- DYL, SYL
    FOR restrictions_with_one_sign IN
			SELECT SfR."SignGeometryID", SfR."RestrictionGeometryID"
			FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l, local_authority."Gaist_Signs" s
			WHERE SfR."RestrictionGeometryID" = l."GeometryID"
			AND SfR."SignGeometryID" = s."GeometryID"
			AND l."RestrictionTypeID" IN (202, 224)
			AND s."Dft Diagra" IN ('638', '638.1')
			AND "RestrictionGeometryID" IN (
				SELECT "RestrictionGeometryID"
				FROM (
					SELECT DISTINCT "Dft Diagra", "Month Day", "RestrictionGeometryID"
					FROM local_authority."Gaist_Signs" s, "mhtc_operations"."SignsForRestrictions" SfR
					WHERE s."GeometryID" = SfR."SignGeometryID" ) s
				GROUP BY "RestrictionGeometryID"
				HAVING COUNT("RestrictionGeometryID") = 1
				ORDER BY "RestrictionGeometryID"
			)
			ORDER BY SfR."RestrictionGeometryID"
	LOOP
	
		time_code = NULL;
		-- Get the sign time code
		SELECT t."Code"
		INTO time_code
		FROM local_authority."Gaist_Signs" s, toms_lookups."TimePeriods" t
		WHERE s."MHTC_TimePeriodCode" = t."Code"
		AND s."GeometryID" = restrictions_with_one_sign."SignGeometryID";
		
		raise notice 'record: %:%. %', restrictions_with_one_sign."RestrictionGeometryID", restrictions_with_one_sign."SignGeometryID", time_code;
		
		IF NOT found OR time_code IS NULL THEN
			CONTINUE;
		END IF;
		
		UPDATE local_authority."Gaist_RoadMarkings_Lines" l
		SET "NoLoadingTimeID" = time_code
		WHERE l."GeometryID" = restrictions_with_one_sign."RestrictionGeometryID";
	
    END LOOP;
end; $$;
   
