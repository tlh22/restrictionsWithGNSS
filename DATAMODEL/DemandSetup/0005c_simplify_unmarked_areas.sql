/**
Use UnacceptableTypeID to show differences
**/

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 225
WHERE "RestrictionTypeID" in (216, 220);

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 224
WHERE "RestrictionTypeID" in (201, 221);