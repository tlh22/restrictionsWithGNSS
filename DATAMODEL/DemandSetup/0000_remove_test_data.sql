/**
Before starting the scripts need to:
  - Create database, restore latest version of TOMs_Test and create relevant pg service
  - Get project folder structure and rename appropriate files
  - Change service name in project file
  - Run this script
  - Within QGIS, add relevant layers into project and transfer to database:
      - os_mastermap_topography_text
      - os_mastermap_topography_polygons
      - SiteArea
      - RoadCentreLine (remember to only include selected items)

***
Loading data from .gml files  (from https://stackoverflow.com/questions/53340732/batch-convert-multiple-gml-files-to-postgis-sql-tables-using-ogr2ogr

See file "load_gml_to_postgis.bat" under QGIS/Project folder structure

-- then, if sent as tiles, may need to remove any duplicates

DELETE FROM gml.topographicarea a
USING gml.topographicarea b
WHERE a.ogc_fid < b.ogc_fid
AND a.fid = b.fid;

-- Change column names
ALTER TABLE topography.os_mastermap_topography_polygons
    RENAME wkb_geometry TO geom;
ALTER TABLE topography.os_mastermap_topography_polygons
    RENAME featurecode TO "FeatureCode";

ALTER TABLE topography.os_mastermap_topography_polygons
    RENAME wkb_geometry TO geom;

ALTER TABLE topography.os_mastermap_topography_polygons
    RENAME featurecode TO "FeatureCode";

--

ALTER TABLE topography.os_mastermap_topography_text
    RENAME wkb_geometry TO geom;

ALTER TABLE topography.os_mastermap_topography_text
    RENAME featurecode TO "FeatureCode";

ALTER TABLE topography.os_mastermap_topography_text
    RENAME theme TO "Theme";

ALTER TABLE topography.os_mastermap_topography_text
    RENAME textstring TO xml_text_string;

ALTER TABLE topography.os_mastermap_topography_text
    RENAME orientation TO xml_rotation;

ALTER TABLE topography.os_mastermap_topography_text
    RENAME height TO xml_text_size;
--
ALTER TABLE highways_network.roadlink
    RENAME wkb_geometry TO geom;

ALTER TABLE highways_network.roadlink
    RENAME roadname TO name1;

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

DELETE
FROM toms."TilesInAcceptedProposals";

DELETE
FROM toms."MapGrid";

DELETE
FROM toms."RestrictionsInProposals";

DELETE
FROM toms."Proposals";

DELETE
FROM highways_network."roadlink";

DELETE
FROM local_authority."SiteArea";

DELETE
FROM mhtc_operations."Corners";

DELETE
FROM mhtc_operations."SectionBreakPoints";

DELETE
FROM highway_assets."CrossingPoints";

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


ALTER TABLE highway_assets."CrossingPoints"
    ALTER COLUMN id DROP NOT NULL;