ALTER TABLE toms."Bays" DISABLE TRIGGER all;

UPDATE toms."Bays"
SET "PayParkingAreaID" = NULL
WHERE "PayParkingAreaID" IS NOT NULL
AND "RestrictionTypeID" NOT IN (103, 105, 133, 134, 135);

ALTER TABLE toms."Bays" ENABLE TRIGGER all;

