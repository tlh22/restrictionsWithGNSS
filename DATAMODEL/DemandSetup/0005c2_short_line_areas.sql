/**
Consider "short" line areas
**/

/*
SELECT "GeometryID", "RestrictionTypeID", "RestrictionLength", "Capacity"
FROM mhtc_operations."Supply"
WHERE "RestrictionTypeID" = 216
AND "RestrictionLength" < 5.0
ORDER BY "RestrictionLength"
*/

-- Unmarked
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" = 216
AND "Capacity" = 0;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" = 227
AND "Capacity" = 0;

-- SYLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" = 201
AND "Capacity" = 0;

-- SRLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 222, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" = 217
AND "Capacity" = 0;