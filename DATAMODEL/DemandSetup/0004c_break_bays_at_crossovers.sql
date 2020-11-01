-- Supply_orig3

DROP TABLE IF EXISTS mhtc_operations."Supply_orig3" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig3"
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
    CONSTRAINT "Supply_orig3_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Supply_orig3"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";


-- set up crossover nodes table
DROP TABLE IF EXISTS  mhtc_operations."CrossoverNodes" CASCADE;

CREATE TABLE mhtc_operations."CrossoverNodes"
(
  id SERIAL,
  geom geometry(Point,27700),
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

-- Make "blade" geometry

DROP TABLE IF EXISTS  mhtc_operations."CrossoverNodes_Single" CASCADE;

CREATE TABLE mhtc_operations."CrossoverNodes_Single"
(
  id SERIAL,
  geom geometry(MultiPoint,27700),
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
    (ST_Dump(ST_Split(s3.geom, ST_Buffer(c.geom, 0.00001)))).geom
    FROM "mhtc_operations"."Supply_orig3" s3, mhtc_operations."CrossoverNodes_Single" c
    WHERE s3."RestrictionTypeID" < 200

UNION

SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s3.geom
    FROM "mhtc_operations"."Supply_orig3" s3, mhtc_operations."CrossoverNodes" c
    WHERE s3."RestrictionTypeID" > 200;

DELETE FROM "mhtc_operations"."Supply"
WHERE ST_Length(geom) < 0.0001;

-- Change acceptability type of bay

UPDATE "mhtc_operations"."Supply" AS s1
SET "UnacceptableTypeID" = s2."UnacceptableTypeID"
FROM "mhtc_operations"."Supply" s2
WHERE s1."RestrictionTypeID" < 200
AND s2."RestrictionTypeID" = 220
AND s2."UnacceptableTypeID" IN (1, 4)
AND ST_Intersects(s1.geom, ST_Buffer(ST_LineInterpolatePoint(s2.geom, 0.5), 0.1));