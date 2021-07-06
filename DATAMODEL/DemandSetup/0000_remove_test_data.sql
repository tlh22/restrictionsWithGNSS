/**
Before starting the scripts need to:
  - Create database, restore latest version of TOMs_Test and create relevant pg service
  - Get project folder structure and rename appropriate files
  - Change service name in project file
  - Run this script
  - Within QGISm, add relevant layers into project and transfer to database:
      - os_mastermap_topography_text
      - os_mastermap_topography_polygons
      - SiteArea
      - RoadCentreLine (remember to only include selected items)

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

ALTER TABLE highway_assets."HighwayAssets"
    ALTER COLUMN "AssetConditionTypeID" DROP NOT NULL;

--... also for lines/bays ??

--ALTER TABLE highway_assets."CrossingPoints"
--    ALTER COLUMN id DROP NOT NULL;

/**
before dealing with roadlink, need to drop StreetGazetteerView
**/

DROP MATERIALIZED VIEW local_authority."StreetGazetteerView";
