-- Set up tables for output

-- Section details
--DROP TABLE IF EXISTS demand."LBHF_Sections_2020" CASCADE;

CREATE TABLE demand."LBHF_Sections_2020"
(
    geom geometry(LineString,27700),
    "StressID" integer,
    "GeometryID" character varying(255) COLLATE pg_catalog."default",
    "Street" character varying(255) COLLATE pg_catalog."default",
    "USRN" double precision,
    "StreetSide" character varying(255) COLLATE pg_catalog."default",
    "USS_ID" character varying(255) COLLATE pg_catalog."default",
    "StreetRef" character varying(255) COLLATE pg_catalog."default",
    "StreetFrom" character varying(255) COLLATE pg_catalog."default",
    "StreetTo" character varying(255) COLLATE pg_catalog."default",
    "Ward" double precision,
    "TotalLength" double precision,
    "AvailableK" double precision,
    "AvailableSpaces_Bays" double precision,
    "AvailableSpaces_SYLs" double precision,
    "Zone_" character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT "LBHF_Sections_2020_pkey" PRIMARY KEY ("GeometryID")
);

-- Populate

INSERT INTO demand."LBHF_Sections_2020"(
	geom, "StressID", "GeometryID", "Street", "USRN", "StreetSide", "USS_ID", "StreetRef", "StreetFrom", "StreetTo", "Ward", "TotalLength", "AvailableK", "AvailableSpaces_Bays", "AvailableSpaces_SYLs", "Zone_")
SELECT geom, "GeometryID", "Street", "USRN", "StreetSide", "USS_ID", "StreetRef", "StreetFrom", "StreetTo", "Ward", "TotalLength", "AvailableK", "AvailableSpaces_Bays", "AvailableSpaces_SYLs", "Zone_"
	FROM demand."LBHF_ParkingStress_2016_WeekdayOvernight";

-- Capacities

--DROP TABLE IF EXISTS demand."LBHF_Capacities_2020" CASCADE;

CREATE TABLE demand."LBHF_Capacities_2020"
(
    "GeometryID" character varying(255) COLLATE pg_catalog."default",
    "SurveyID" int,
    "CarCapacity" double precision,
    CONSTRAINT "LBHF_Capacities_2020_pkey" PRIMARY KEY ("GeometryID", "SurveyID")
);

-- Populate

INSERT INTO demand."LBHF_Capacities_2020"(
	"GeometryID", "SurveyID", "CarCapacity")
SELECT "GeometryID", "SurveyID"::int, "Capacity"
	FROM demand."MASTER_Demand_01_Weekday_Weekday_Overnight";

INSERT INTO demand."LBHF_Capacities_2020"(
	"GeometryID", "SurveyID", "CarCapacity")
SELECT "GeometryID", "SurveyID"::int, "Capacity"
	FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon";

INSERT INTO demand."LBHF_Capacities_2020"(
	"GeometryID", "SurveyID", "CarCapacity")
SELECT "GeometryID", "SurveyID"::int, "Capacity"
	FROM demand."MASTER_Demand_03_Saturday_Saturday_Afternoon";

INSERT INTO demand."LBHF_Capacities_2020"(
	"GeometryID", "SurveyID", "CarCapacity")
SELECT "GeometryID", "SurveyID"::int, "Capacity"
	FROM demand."MASTER_Demand_04_Sunday_Sunday_Afternoon";

-- Demand details

--DROP TABLE IF EXISTS demand."LBHF_ParkingStress_2020" CASCADE;

CREATE TABLE demand."LBHF_ParkingStress_2020"
(
    "GeometryID" character varying(255) COLLATE pg_catalog."default",
    "SurveyID" integer,
    "SurveyDate" character varying(255) COLLATE pg_catalog."default",
    "Add_Osbstr" integer,
    "NumCars" double precision,
    "STRESS" double precision,
    "StressLabel" double precision,
    CONSTRAINT "LBHF_ParkingStress_2020_pkey" PRIMARY KEY ("GeometryID", "SurveyID")
);

-- Populate

INSERT INTO demand."LBHF_ParkingStress_2020"(
	"GeometryID", "SurveyID", "SurveyDate", "Add_Osbstr", "NumCars", "STRESS", "StressLabel")
SELECT "GeometryID", "SurveyID"::int, "SurveyDate_Rounded", sbays::int, "Demand", "Stress"*100, ROUND("Stress"*100)
	FROM demand."MASTER_Demand_01_Weekday_Weekday_Overnight";

INSERT INTO demand."LBHF_ParkingStress_2020"(
	"GeometryID", "SurveyID", "SurveyDate", "Add_Osbstr", "NumCars", "STRESS", "StressLabel")
SELECT "GeometryID", "SurveyID"::int, "SurveyDate_Rounded", sbays::int, "Demand", "Stress"*100, ROUND("Stress"*100)
	FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon";

INSERT INTO demand."LBHF_ParkingStress_2020"(
	"GeometryID", "SurveyID", "SurveyDate", "Add_Osbstr", "NumCars", "STRESS", "StressLabel")
SELECT "GeometryID", "SurveyID"::int, "SurveyDate_Rounded", sbays::int, "Demand", "Stress"*100, ROUND("Stress"*100)
	FROM demand."MASTER_Demand_03_Saturday_Saturday_Afternoon";

INSERT INTO demand."LBHF_ParkingStress_2020"(
	"GeometryID", "SurveyID", "SurveyDate", "Add_Osbstr", "NumCars", "STRESS", "StressLabel")
SELECT "GeometryID", "SurveyID"::int, "SurveyDate_Rounded", sbays::int, "Demand", "Stress"*100, ROUND("Stress"*100)
	FROM demand."MASTER_Demand_04_Sunday_Sunday_Afternoon";


-- Deal with sections that have no dates ...
UPDATE demand."LBHF_ParkingStress_2020" AS d1
SET "SurveyDate" = g."SurveyDate"
FROM (
        SELECT DISTINCT ON ("Zone_")
         "SurveyDate", "Zone_"
        FROM demand."LBHF_ParkingStress_2020" d, demand."LBHF_Sections_2020" s
        WHERE d."GeometryID" = s."GeometryID"
        AND "SurveyDate" IS NOT NULL
        ORDER BY "Zone_", "SurveyDate" ASC
	) AS g, demand."LBHF_Sections_2020" s1
WHERE s1."Zone_" = g."Zone_"
AND s1."GeometryID" = d1."GeometryID"
AND d1."SurveyDate" IS NULL;



SELECT DISTINCT ON ("Zone_")
 "SurveyDate", "Zone_"
FROM demand."LBHF_ParkingStress_2020" d, demand."LBHF_Sections_2020" s
WHERE d."GeometryID" = s."GeometryID"
AND "SurveyDate" IS NOT NULL
ORDER BY "Zone_", "SurveyDate" ASC

-- output for checking ... (and then pivot)


SELECT d."GeometryID", d."SurveyID", "Street", "StreetSide", "CarCapacity", "NumCars"
FROM demand."LBHF_ParkingStress_2020" d, demand."LBHF_Capacities_2020" c, demand."LBHF_Sections_2020" s
WHERE d."GeometryID" = c."GeometryID"
AND d."SurveyID" = c."SurveyID"
AND d."GeometryID" = s."GeometryID"
ORDER BY d."SurveyID", "Street", "StreetSide";

-- possibly use crosstab

-- Now output into LBHF structure

SELECT geom, "StressID", d."GeometryID", d."SurveyID" AS "SurveyType", "SurveyDate", "Street", "USRN", "StreetSide", "USS_ID", "StreetRef",
      "StreetFrom", "StreetTo", "Ward", "TotalLength", "AvailableK", "AvailableSpaces_Bays", "AvailableSpaces_SYLs", "Zone_",
      "CarCapacity", "Add_Osbstr", "NumCars", "STRESS", "StressLabel"
FROM demand."LBHF_ParkingStress_2020" d, demand."LBHF_Capacities_2020" c, demand."LBHF_Sections_2020" s
WHERE d."GeometryID" = c."GeometryID"
AND d."SurveyID" = c."SurveyID"
AND d."GeometryID" = s."GeometryID"
AND d."SurveyID" = 1
ORDER BY d."SurveyID", "Street", "StreetSide";