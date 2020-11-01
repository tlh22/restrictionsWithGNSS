-- Table: mhtc_operations.Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "SectionID" integer;
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "StartStreet" character varying(254);
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "EndStreet" character varying(254);
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "SideOfStreet" character varying(100);

DROP TABLE IF EXISTS mhtc_operations."Supply_orig" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig"
(
    --"RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700) NOT NULL,
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
    "label_X" double precision,
    "label_Y" double precision,
    "label_Rotation" double precision,
    "labelLoading_X" double precision,
    "labelLoading_Y" double precision,
    "labelLoading_Rotation" double precision,
    "label_TextChanged" character varying(254) COLLATE pg_catalog."default",
    "OpenDate" date,
    "CloseDate" date,
    "CPZ" character varying(40) COLLATE pg_catalog."default",
    "LastUpdateDateTime" timestamp without time zone NOT NULL,
    "LastUpdatePerson" character varying(255) COLLATE pg_catalog."default" NOT NULL,
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
    "SectionID" integer,
	"StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    --CONSTRAINT "Supply_orig_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_orig_GeometryID_key" UNIQUE ("GeometryID")
    CONSTRAINT "Supply_orig_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Supply_orig"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";

-- set up corner table

DROP TABLE IF EXISTS  mhtc_operations."Corners_Single" CASCADE;

CREATE TABLE mhtc_operations."Corners_Single"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "Corners_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."Corners_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."Corners_Single" TO postgres;

-- Index: public."sidx_Corners_Single_geom"

-- DROP INDEX public."sidx_Corners_Single_geom";

CREATE INDEX "sidx_Corners_Single_geom"
  ON mhtc_operations."Corners_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."Corners_Single" (geom)
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."Corners";

CREATE OR REPLACE FUNCTION cnrPoint(geometry) RETURNS geometry AS
'SELECT ST_ClosestPoint($1, c.geom) AS geom FROM mhtc_operations."Corners_Single" c
                    WHERE ST_Intersects($1, ST_Buffer(c.geom, 2.0))
                    AND ST_DWithin($1, c.geom, 1.0)'
LANGUAGE SQL;

-- ***

DELETE FROM mhtc_operations."Supply";

--

INSERT INTO "mhtc_operations"."Supply" (
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
       geom)
	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
     (ST_Dump(ST_Split(
	                            ST_Snap(lg1.geom, cnrPoint(lg1.geom), 0.00000001),
	                            cnrPoint(lg1.geom)))).geom
	FROM "mhtc_operations"."Supply_orig" lg1 LEFT JOIN LATERAL cnrPoint(lg1.geom) pt ON TRUE

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom
	FROM "mhtc_operations"."Supply_orig" lg1
    WHERE cnrPoint(lg1.geom) IS NULL;

-- set road details

UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

-- deal with unacceptability

DROP TABLE IF EXISTS mhtc_operations."Supply_orig2" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig2"
(
    --"RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700) NOT NULL,
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
    "label_X" double precision,
    "label_Y" double precision,
    "label_Rotation" double precision,
    "labelLoading_X" double precision,
    "labelLoading_Y" double precision,
    "labelLoading_Rotation" double precision,
    "label_TextChanged" character varying(254) COLLATE pg_catalog."default",
    "OpenDate" date,
    "CloseDate" date,
    "CPZ" character varying(40) COLLATE pg_catalog."default",
    "LastUpdateDateTime" timestamp without time zone NOT NULL,
    "LastUpdatePerson" character varying(255) COLLATE pg_catalog."default" NOT NULL,
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
    "SectionID" integer,
	"StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    --CONSTRAINT "Supply_orig2_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_orig2_GeometryID_key" UNIQUE ("GeometryID")
    CONSTRAINT "Supply_orig2_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Supply_orig2"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";

--
CREATE OR REPLACE FUNCTION cnrBufferExtent(geometry, real) RETURNS geometry AS
'SELECT ST_Collect(ST_ExteriorRing(ST_Buffer(c.geom, $2))) AS geom
FROM mhtc_operations."Corners_Single" c
WHERE ST_Intersects($1, ST_Buffer(c.geom, $2))
AND ST_DWithin($1, c.geom, $2)'
LANGUAGE SQL;

DELETE FROM mhtc_operations."Supply";

INSERT INTO "mhtc_operations"."Supply" (
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
       geom)
SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
     (ST_Dump(ST_Split(lg1.geom, cnrBufferExtent(lg1.geom, 5.0)))).geom
	FROM "mhtc_operations"."Supply_orig2" lg1 LEFT JOIN LATERAL cnrBufferExtent(lg1.geom, 5.0) pt ON TRUE
	WHERE lg1."RestrictionTypeID" in (201, 216)

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom
	FROM "mhtc_operations"."Supply_orig2" lg1
    WHERE cnrPoint(lg1.geom) IS NULL
    AND lg1."RestrictionTypeID" in (201, 216)

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom
	FROM "mhtc_operations"."Supply_orig2" lg1
    WHERE lg1."RestrictionTypeID" NOT IN (201, 216);

-- deal with acceptablity around corners

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 6
FROM mhtc_operations."Corners" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 6.0)))
AND s."RestrictionTypeID" = 216;

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 6
FROM mhtc_operations."Corners" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 6.0)))
AND s."RestrictionTypeID" = 201;
