/**
Use UnacceptableTypeID to show differences
**/
-- SYL

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 201
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221
WHERE "RestrictionTypeID" in (201, 224)
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 216
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220
WHERE "RestrictionTypeID" IN (216, 225)
AND "UnacceptableTypeID" IS NOT NULL;
