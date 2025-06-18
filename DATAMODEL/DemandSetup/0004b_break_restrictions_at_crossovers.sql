-- Supply_orig3

DROP TABLE IF EXISTS mhtc_operations."Supply_orig3" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig3" AS 
TABLE mhtc_operations."Supply";

/***
CREATE TABLE mhtc_operations."Supply_orig3"
(
    --"RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom public.geometry(LineString,27700) NOT NULL,
    "RestrictionLength" double precision NOT NULL,
    "RestrictionTypeID" integer NOT NULL,
    "GeomShapeID" integer NOT NULL,
    "AzimuthToRoadCentreLine" double precision,
    "Notes" character varying(254) COLLATE pg_catalog."default",
    "Photos_01" character varying(255) COLLATE pg_catalog."default",
    "Photos_02" character varying(255) COLLATE pg_catalog."default",
    "Photos_03" character varying(255) COLLATE pg_catalog."default",
    "RoadName" character varying(254) COLLATE pg_catalog."default",
    "USRN" character varying(254) COLLATE pg_catalog."default",
    --"label_X" double precision,
    --"label_Y" double precision,
    --"label_Rotation" double precision,
    --"labelLoading_X" double precision,
    --"labelLoading_Y" double precision,
    --"labelLoading_Rotation" double precision,
    --"label_TextChanged" character varying(254) COLLATE pg_catalog."default",
	label_pos public.geometry(MultiPoint,27700),
    label_ldr public.geometry(MultiLineString,27700),
	label_loading_pos public.geometry(MultiPoint,27700),
    label_loading_ldr public.geometry(MultiLineString,27700),
    "OpenDate" date,
    "CloseDate" date,
    "CPZ" character varying(40) COLLATE pg_catalog."default",
    "LastUpdateDateTime" timestamp without time zone,
    "LastUpdatePerson" character varying(255) COLLATE pg_catalog."default",
    "BayOrientation" double precision,
    "NrBays" integer NOT NULL DEFAULT '-1'::integer,
    "TimePeriodID" integer,
    "PayTypeID" integer,
    "MaxStayID" integer,
    "NoReturnID" integer,
    "NoWaitingTimeID" integer,
    "NoLoadingTimeID" integer,
    "UnacceptableTypeID" integer,
    "ParkingTariffArea" character varying(10) COLLATE pg_catalog."default",
    "AdditionalConditionID" integer,
    "ComplianceRoadMarkingsFaded" integer,
    "ComplianceRestrictionSignIssue" integer,
    "ComplianceLoadingMarkingsFaded" integer,
    "ComplianceNotes" character varying(254) COLLATE pg_catalog."default",
    "MHTC_CheckIssueTypeID" integer,
    "MHTC_CheckNotes" character varying(254) COLLATE pg_catalog."default",
    "PayParkingAreaID" character varying(255) COLLATE pg_catalog."default",
    "PermitCode" character varying(255) COLLATE pg_catalog."default",
    "MatchDayTimePeriodID" integer,
    "MatchDayEventDayZone" character varying(40),
    "Capacity" integer,
    "BayWidth" double precision,
    "SectionID" integer,
	"StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    CONSTRAINT "Supply_orig3_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Supply_orig3"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";
	
***/


-- set up crossover nodes table
DROP TABLE IF EXISTS  mhtc_operations."CrossoverNodes" CASCADE;

CREATE TABLE mhtc_operations."CrossoverNodes"
(
  id SERIAL,
  geom public.geometry(Point,27700),
  CONSTRAINT "CrossoverNodes_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CrossoverNodes"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CrossoverNodes" TO postgres;

CREATE INDEX "sidx_CrossoverNodes_geom"
  ON mhtc_operations."CrossoverNodes"
  USING gist
  (geom);

/***
INSERT INTO mhtc_operations."CrossoverNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM mhtc_operations."Supply_orig3"
WHERE "RestrictionTypeID" = 220
AND "UnacceptableTypeID" IN (1, 4);

INSERT INTO mhtc_operations."CrossoverNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM mhtc_operations."Supply_orig3"
WHERE "RestrictionTypeID" = 220
AND "UnacceptableTypeID" IN (1, 4);
***/

INSERT INTO mhtc_operations."CrossoverNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM highway_assets."CrossingPoints";

INSERT INTO mhtc_operations."CrossoverNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM highway_assets."CrossingPoints";

-- Make "blade" public.geometry

DROP TABLE IF EXISTS  mhtc_operations."CrossoverNodes_Single" CASCADE;

CREATE TABLE mhtc_operations."CrossoverNodes_Single"
(
  id SERIAL,
  geom public.geometry(MultiPoint,27700),
  CONSTRAINT "CrossoverNodes_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CrossoverNodes_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CrossoverNodes_Single" TO postgres;

CREATE INDEX "sidx_CrossoverNodes_Single_geom"
  ON mhtc_operations."CrossoverNodes_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."CrossoverNodes_Single" (geom)
SELECT ST_Multi(ST_Collect(geom)) As geom
FROM mhtc_operations."CrossoverNodes";

-- ***

ALTER TABLE IF EXISTS demand."VRMs" DROP CONSTRAINT IF EXISTS "VRMs_GeometryID_fkey";

DELETE FROM mhtc_operations."Supply";

--
/***
INSERT INTO "mhtc_operations"."Supply" (
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
       geom)
SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    (ST_Dump(ST_Split(s3.geom, ST_Buffer(c.geom, 0.00001)))).geom
    FROM "mhtc_operations"."Supply_orig3" s3, mhtc_operations."CrossoverNodes_Single" c
    WHERE s3."RestrictionTypeID" < 200

UNION

SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s3.geom
    FROM "mhtc_operations"."Supply_orig3" s3, mhtc_operations."CrossoverNodes_Single" c
    WHERE s3."RestrictionTypeID" IN (201, 216, 224, 225)

UNION

SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s3.geom
    FROM "mhtc_operations"."Supply_orig3" s3, mhtc_operations."CrossoverNodes_Single" c
    WHERE s3."RestrictionTypeID" > 200
    AND s3."RestrictionTypeID" NOT IN (201, 216, 224, 225);

DELETE FROM "mhtc_operations"."Supply"
WHERE ST_Length(geom) < 0.0001;
***/


INSERT INTO "mhtc_operations"."Supply" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "mhtc_operations"."Supply_orig3" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig3" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."CrossoverNodes_Single"
                                          ) cnr
									  ) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
AND "RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 224, 225, 226, 227, 229, 101, 102, 104, 105, 125, 126, 127, 129, 131, 133, 134, 135, 142, 152, 154, 203, 207, 208, 231)  -- SYLs, SRLs, Unmarked and general bays
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig3" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig3" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."CrossoverNodes_Single"
                                          ) cnr
									  ) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25)
AND "RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 224, 225, 226, 227, 229, 101, 102, 104, 105, 125, 126, 127, 129, 131, 133, 134, 135, 142, 152, 154, 203, 207, 208, 231)  -- SYLs, SRLs, Unmarked and general bays
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig3" s1
WHERE "RestrictionTypeID" NOT IN (
SELECT "RestrictionTypeID" FROM "mhtc_operations"."Supply_orig3"
WHERE "RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 224, 225, 226, 227, 229, 101, 102, 104, 105, 125, 126, 127, 129, 131, 133, 134, 135, 142, 152, 154, 203, 207, 208, 231)
)
;

DELETE FROM "mhtc_operations"."Supply"
WHERE ST_Length(geom) < 0.0001;


-- Change acceptability type of lines

UPDATE "mhtc_operations"."Supply" AS s1
SET "UnacceptableTypeID" =
	CASE WHEN s2."CrossingPointTypeID" = 1 or s2."CrossingPointTypeID" = 2 THEN 4
	     WHEN s2."CrossingPointTypeID" = 4 THEN 11
         ELSE 1
         END
FROM highway_assets."CrossingPoints" s2
WHERE s1."RestrictionTypeID" < 200
AND ST_Within(s1.geom, ST_Buffer(s2.geom, 0.1));

UPDATE "mhtc_operations"."Supply" AS s1
SET "UnacceptableTypeID" = CASE WHEN s2."CrossingPointTypeID" = 1 or s2."CrossingPointTypeID" = 2 THEN 4
                                ELSE 1
                                END
FROM highway_assets."CrossingPoints" s2
WHERE s1."RestrictionTypeID" > 200
AND s1."RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 227, 224, 225, 226, 229, 203, 207, 208, 231)
AND ST_Within(s1.geom, ST_Buffer(s2.geom, 0.1));

-- delete unmarked unacceptable lines intersecting with bays

/***
DELETE FROM "mhtc_operations"."Supply" AS s2
USING "mhtc_operations"."Supply" s1
WHERE s2."RestrictionTypeID" = 220
AND s2."UnacceptableTypeID" IN (1, 4)
AND s1."RestrictionTypeID" < 200
AND ST_Intersects(s1.geom, ST_Buffer(ST_LineInterpolatePoint(s2.geom, 0.5), 0.1));
***/

-- sort out unacceptability ...

-- SYLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221
WHERE "RestrictionTypeID" IN (201, 224)
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220
WHERE "RestrictionTypeID" IN (216, 225)
AND "UnacceptableTypeID" IS NOT NULL;

-- SRLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 222
WHERE "RestrictionTypeID" IN (217, 226)
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 228
WHERE "RestrictionTypeID" IN (227, 229)
AND "UnacceptableTypeID" IS NOT NULL;

-- deal with labels


-- Check for locations where crossovers have not broken restriction

SELECT "GeometryID", c.geom
FROM mhtc_operations."Supply" s, mhtc_operations."CrossoverNodes_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	)
AND s."RestrictionTypeID" NOT IN (202, 108)   -- DYL, Bus Stop
ORDER BY "GeometryID";
