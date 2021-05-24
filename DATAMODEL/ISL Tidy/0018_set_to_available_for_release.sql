
-- Signs
ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN ( 1, 18)
AND  "FieldCheckCompleted" =  'true';

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- HighwayDedications

ALTER TABLE moving_traffic."HighwayDedications" DISABLE TRIGGER all;

UPDATE moving_traffic."HighwayDedications"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."HighwayDedications" ENABLE TRIGGER all;

-- SpecialDesignations

ALTER TABLE moving_traffic."SpecialDesignations" DISABLE TRIGGER all;

UPDATE moving_traffic."SpecialDesignations"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."SpecialDesignations" ENABLE TRIGGER all;

-- Turn Restrictions

ALTER TABLE moving_traffic."TurnRestrictions" DISABLE TRIGGER all;

UPDATE moving_traffic."TurnRestrictions"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."TurnRestrictions" ENABLE TRIGGER all;

-- RestrictionsForVehicles

ALTER TABLE moving_traffic."RestrictionsForVehicles" DISABLE TRIGGER all;

UPDATE moving_traffic."RestrictionsForVehicles"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."RestrictionsForVehicles" ENABLE TRIGGER all;

-- AccessRestrictions

ALTER TABLE moving_traffic."AccessRestrictions" DISABLE TRIGGER all;

UPDATE moving_traffic."AccessRestrictions"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."AccessRestrictions" ENABLE TRIGGER all;


