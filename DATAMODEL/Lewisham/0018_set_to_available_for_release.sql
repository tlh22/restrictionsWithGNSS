
-- Signs
ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN ( 1, 18)
AND  "FieldCheckCompleted" =  'true';

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- CarriagewayMarkings
ALTER TABLE moving_traffic."CarriagewayMarkings" DISABLE TRIGGER all;

UPDATE  moving_traffic."CarriagewayMarkings"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN ( 1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE  moving_traffic."CarriagewayMarkings" ENABLE TRIGGER all;

-- HighwayDedications
ALTER TABLE moving_traffic."HighwayDedications" DISABLE TRIGGER all;

UPDATE moving_traffic."HighwayDedications"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."HighwayDedications" ENABLE TRIGGER all;

-- RestrictionPolygons
ALTER TABLE toms."RestrictionPolygons" DISABLE TRIGGER all;

UPDATE toms."RestrictionPolygons"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN ( 1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE toms."RestrictionPolygons" ENABLE TRIGGER all;

-- SpecialDesignations
ALTER TABLE moving_traffic."SpecialDesignations" DISABLE TRIGGER all;

UPDATE moving_traffic."SpecialDesignations"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."SpecialDesignations" ENABLE TRIGGER all;

-- VehicleBarriers
ALTER TABLE highway_assets."VehicleBarriers" DISABLE TRIGGER all;

UPDATE highway_assets."VehicleBarriers"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN ( 1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE highway_assets."VehicleBarriers" ENABLE TRIGGER all;

-- AccessRestrictions
ALTER TABLE moving_traffic."AccessRestrictions" DISABLE TRIGGER all;

UPDATE moving_traffic."AccessRestrictions"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."AccessRestrictions" ENABLE TRIGGER all;

-- RestrictionsForVehicles
ALTER TABLE moving_traffic."RestrictionsForVehicles" DISABLE TRIGGER all;

UPDATE moving_traffic."RestrictionsForVehicles"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."RestrictionsForVehicles" ENABLE TRIGGER all;

-- Turn Restrictions
ALTER TABLE moving_traffic."TurnRestrictions" DISABLE TRIGGER all;

UPDATE moving_traffic."TurnRestrictions"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN (1, 18)
OR "MHTC_CheckIssueTypeID" IS NULL;

ALTER TABLE moving_traffic."TurnRestrictions" ENABLE TRIGGER all;

-- Remove any overnight waiting signs
ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "MHTC_CheckIssueTypeID" = 18
WHERE "SignType_1" = 64021;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- Make sure all signs are available for release
ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "MHTC_CheckIssueTypeID" = 1
WHERE "MHTC_CheckIssueTypeID" NOT IN ( 1, 18)
AND  "FieldCheckCompleted" =  'true';

ALTER TABLE toms."Signs" ENABLE TRIGGER all;