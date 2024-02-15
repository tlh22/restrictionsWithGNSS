/***

THEN
 - add new restrictions (ensuring that there are fields are completed - RestrictionID, WaitingTimeID, ...)
 - break new retrictions at corners and link to demand sections (maybe should be done before imported)
 - remove any of the original demand sections that overlap with the new restrictions
 - set any remaining original demand sections to be unmarked
 - deal with corner acceptability
 - calculate supply values for the original demand sections

***/

ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN IF NOT EXISTS "RestrictionTypeID" integer;

ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN IF NOT EXISTS "GeomShapeID" integer;
	
UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 202, "GeomShapeID" = 10
WHERE UPPER(type) = UPPER('No waiting')
AND UPPER(hours_of_operation) = UPPER('At any time')
AND "RestrictionTypeID" IS NULL
;

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 107, "GeomShapeID" = 10
WHERE UPPER(type) = UPPER('No stopping')
AND UPPER(road_marking) = UPPER('Bus stop')
AND "RestrictionTypeID" IS NULL
;

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 224, "GeomShapeID" = 10
WHERE UPPER(road_marking) = UPPER('Single yellow line')
AND "RestrictionTypeID" IS NULL
;

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 203, "GeomShapeID" = 12
WHERE UPPER(type) = UPPER('School Keep Clear')
AND UPPER(road_marking) = UPPER('Zig zag')
AND "RestrictionTypeID" IS NULL
;


ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN IF NOT EXISTS "NoWaitingTimeID" integer;
	
UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "NoWaitingTimeID" = 1
WHERE UPPER("hours_of_operation") = UPPER('At any time')
AND "NoWaitingTimeID" IS NULL
;

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "NoWaitingTimeID" = 1
WHERE UPPER("road_marking") IN (UPPER('Bus stop'), UPPER('Double yellow line'))
AND "NoWaitingTimeID" IS NULL;

-- Create temp table of unique time periods
	
CREATE TABLE IF NOT EXISTS mhtc_operations."time_period_lookup"
AS
SELECT DISTINCT type, road_marking, days_of_operation, hours_of_operation
	FROM local_authority."WaitingLoadingStoppingRestrictions"
	WHERE UPPER("hours_of_operation") != UPPER('At any time');
	
ALTER TABLE IF EXISTS mhtc_operations."time_period_lookup" ADD COLUMN IF NOT EXISTS gid BIGSERIAL PRIMARY KEY;

ALTER TABLE IF EXISTS mhtc_operations."time_period_lookup"
    ADD COLUMN IF NOT EXISTS "NoWaitingTimeID" integer;
	
/***
	Now manually add MHTC time period ids
***/

-- Update

UPDATE local_authority."WaitingLoadingStoppingRestrictions" w
SET "NoWaitingTimeID" = t."NoWaitingTimeID"
FROM mhtc_operations."time_period_lookup" t
WHERE w.type = t.type 
AND w.road_marking = t.road_marking
AND w.days_of_operation = t.days_of_operation
AND w.hours_of_operation = t.hours_of_operation
AND w."NoWaitingTimeID" IS NULL
;

-- Now break at corners

