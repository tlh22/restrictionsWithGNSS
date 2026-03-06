/***

Populate CPZ details

***/

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom)
AND s."CPZ" IS NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_Intersects (s.geom, a.geom)
AND s."CPZ" IS NULL;

-- Deal with control hours

-- Bays (just premit, P&D)
UPDATE "mhtc_operations"."Supply" AS s
SET "TimePeriodID" = a."TimePeriodID"
FROM toms."ControlledParkingZones" a
WHERE s."CPZ" = a."CPZ"
AND s."RestrictionTypeID" IN (101, 102, 103, 104, 105, 114, 126, 131, 133, 134, 135)
AND (s."TimePeriodID" IS NULL OR s."TimePeriodID" = 0);

-- SYLs

UPDATE "mhtc_operations"."Supply" AS s
SET "NoWaitingTimeID" = a."TimePeriodID"
FROM toms."ControlledParkingZones" a
WHERE s."CPZ" = a."CPZ"
AND s."RestrictionTypeID" IN (201, 221, 224)
AND (s."NoWaitingTimeID" IS NULL OR s."NoWaitingTimeID" = 0);


