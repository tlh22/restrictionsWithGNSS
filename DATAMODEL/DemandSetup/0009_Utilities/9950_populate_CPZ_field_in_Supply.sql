--

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM local_authority."Southwark CPZs" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM local_authority."Southwark CPZs" a
WHERE ST_WITHIN (s.geom, a.geom)
AND s."CPZ" IS NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM local_authority."Southwark CPZs" a
WHERE ST_Intersects (s.geom, a.geom)
AND s."CPZ" IS NULL;

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