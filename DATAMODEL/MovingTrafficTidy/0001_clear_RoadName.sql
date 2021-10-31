-- Reset RoadName for all layers

-- Signs
ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "RoadName" = NULL;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- RestrictionPolygons
ALTER TABLE toms."RestrictionPolygons" DISABLE TRIGGER all;

UPDATE toms."RestrictionPolygons"
SET "RoadName" = NULL;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- CarriagewayMarkings

ALTER TABLE moving_traffic."CarriagewayMarkings" DISABLE TRIGGER all;

UPDATE moving_traffic."CarriagewayMarkings"
SET "RoadName" = NULL;

ALTER TABLE moving_traffic."CarriagewayMarkings" ENABLE TRIGGER all;

-- HighwayDedications

ALTER TABLE moving_traffic."HighwayDedications" DISABLE TRIGGER all;

UPDATE moving_traffic."HighwayDedications"
SET "RoadName" = NULL;

ALTER TABLE moving_traffic."HighwayDedications" ENABLE TRIGGER all;

-- SpecialDesignations

ALTER TABLE moving_traffic."SpecialDesignations" DISABLE TRIGGER all;

UPDATE moving_traffic."SpecialDesignations"
SET "RoadName" = NULL;

ALTER TABLE moving_traffic."SpecialDesignations" ENABLE TRIGGER all;

-- Turn Restrictions

ALTER TABLE moving_traffic."TurnRestrictions" DISABLE TRIGGER all;

UPDATE moving_traffic."TurnRestrictions"
SET "RoadName" = NULL;

ALTER TABLE moving_traffic."TurnRestrictions" ENABLE TRIGGER all;

-- RestrictionsForVehicles

ALTER TABLE moving_traffic."RestrictionsForVehicles" DISABLE TRIGGER all;

UPDATE moving_traffic."RestrictionsForVehicles"
SET "RoadName" = NULL;

ALTER TABLE moving_traffic."RestrictionsForVehicles" ENABLE TRIGGER all;

-- AccessRestrictions

ALTER TABLE moving_traffic."AccessRestrictions" DISABLE TRIGGER all;

UPDATE moving_traffic."AccessRestrictions"
SET "RoadName" = NULL;

ALTER TABLE moving_traffic."AccessRestrictions" ENABLE TRIGGER all;

-- VehicleBarriers

ALTER TABLE highway_assets."VehicleBarriers" DISABLE TRIGGER all;

UPDATE highway_assets."VehicleBarriers"
SET "RoadName" = NULL;

ALTER TABLE highway_assets."VehicleBarriers" ENABLE TRIGGER all;
