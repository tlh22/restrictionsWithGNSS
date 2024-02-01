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
    ADD COLUMN "RestrictionTypeID" integer;

ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN "GeomShapeID" integer;
	
UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 202, "GeomShapeID" = 10
WHERE type = 'No waiting'
AND hours_of_operation = 'At any time';

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 107, "GeomShapeID" = 10
WHERE type = 'No stopping'
AND road_marking = 'Bus stop';

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 224, "GeomShapeID" = 10
WHERE road_marking = 'Single yellow line';

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "RestrictionTypeID" = 203, "GeomShapeID" = 12
WHERE type = 'School Keep Clear'
AND road_marking = 'Zig zag';


ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN "NoWaitingTimeID" integer;
	
UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "NoWaitingTimeID" = 1
WHERE "hours_of_operation" = 'At any time';

UPDATE local_authority."WaitingLoadingStoppingRestrictions"
SET "NoWaitingTimeID" = 1
WHERE "road_marking" IN ('Bus stop', 'Double yellow line')
AND "NoWaitingTimeID" IS NULL;

-- Create temp table of unique time periods
	
CREATE TABLE mhtc_operations."time_period_lookup"
AS
SELECT DISTINCT type, road_marking, days_of_operation, hours_of_operation
	FROM local_authority."WaitingLoadingStoppingRestrictions"
	WHERE "hours_of_operation" != 'At any time';
	
ALTER TABLE IF EXISTS mhtc_operations."time_period_lookup" ADD COLUMN gid BIGSERIAL PRIMARY KEY;

ALTER TABLE IF EXISTS mhtc_operations."time_period_lookup"
    ADD COLUMN "NoWaitingTimeID" integer;
	
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

-- Now break at corners

