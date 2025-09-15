--

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom);

/***
-- Southwark things
UPDATE "mhtc_operations"."Supply" AS s
SET "NoWaitingTimeID" = 341
WHERE "CPZ" = 'C1'
AND "RestrictionTypeID" = 201
AND ("NoWaitingTimeID" IS NULL
OR "NoWaitingTimeID" = 291);

SELECT "GeometryID"
FROM "mhtc_operations"."Supply"
WHERE "CPZ" = 'C1'
AND "RestrictionTypeID" = 201
AND ("NoWaitingTimeID" IS NULL
OR "NoWaitingTimeID" = 291);

SELECT "GeometryID"
FROM "mhtc_operations"."Supply"
WHERE "RestrictionTypeID" = 201
AND "NoWaitingTimeID" IS NULL
;

UPDATE "mhtc_operations"."Supply" AS s
SET "NoWaitingTimeID" = a."TimePeriodID"
FROM toms."ControlledParkingZones" a
WHERE s."CPZ" = a."CPZ"
AND s."RestrictionTypeID" = 201
AND s."NoWaitingTimeID" = 0
;
***/