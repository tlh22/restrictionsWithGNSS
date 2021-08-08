/**
Use UnacceptableTypeID to show differences
**/

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 225
WHERE "RestrictionTypeID" in (216, 220);

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 224
WHERE "RestrictionTypeID" in (201, 221);

-- or the other way

--SYLs

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 201
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 216
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 227
WHERE "RestrictionTypeID" = 229
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 228
WHERE "RestrictionTypeID" = 229
AND "UnacceptableTypeID" IS NOT NULL;