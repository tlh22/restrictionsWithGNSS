/**
remove any test data
**/

DELETE
FROM toms."Bays";

DELETE
FROM toms."Lines";

DELETE
FROM toms."Signs";

DELETE
FROM toms."RestrictionPolygons";

DELETE
FROM toms."ControlledParkingZones";

DELETE
FROM toms."ParkingTariffAreas";

DELETE
FROM toms."MatchDayEventDayZones";

-- Tidy up other things ...

ALTER TABLE highway_assets."CrossingPoints"
    ALTER COLUMN "AssetConditionTypeID" DROP NOT NULL;

... also for lines/bays ??

ALTER TABLE highway_assets."CrossingPoints"
    ALTER COLUMN id DROP NOT NULL;