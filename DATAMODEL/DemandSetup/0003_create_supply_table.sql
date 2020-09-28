DROP SEQUENCE IF EXISTS mhtc_operations."Supply_id_seq" CASCADE;

CREATE SEQUENCE "mhtc_operations"."Supply_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE OR REPLACE FUNCTION "public"."create_supply_geometryid"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 nextSeqVal varchar := '';
BEGIN

	SELECT concat('S_', to_char(nextval('"mhtc_operations"."Supply_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$$;

DROP TABLE IF EXISTS mhtc_operations."Supply" CASCADE;

CREATE TABLE mhtc_operations."Supply"
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
    "PayParkingAreaCode" character varying(255) COLLATE pg_catalog."default",
    "PermitCode" character varying(255) COLLATE pg_catalog."default",
    "MatchDayTimePeriodID" integer,
    --CONSTRAINT "Supply_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_GeometryID_key" UNIQUE ("GeometryID")
    CONSTRAINT "Supply_pkey" UNIQUE ("GeometryID")
    );

CREATE INDEX "sidx_Supply_geom"
    ON mhtc_operations."Supply" USING gist
    (geom)
    TABLESPACE pg_default;

CREATE TRIGGER "set_restriction_length_Lines"
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Supply"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_restriction_length();

INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaCode", "PermitCode", "MatchDayTimePeriodID")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaCode", "PermitCode", "MatchDayTimePeriodID"
	FROM toms."Bays";

INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_X", "label_Y", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "labelLoading_X", "labelLoading_Y", "labelLoading_Rotation", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID"
	FROM toms."Lines";

CREATE TRIGGER "create_geometryid_supply" BEFORE INSERT ON mhtc_operations."Supply" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();

--

UPDATE mhtc_operations."Supply"
SET "TimePeriodID" = 1
WHERE "RestrictionTypeID" IN (107, 108, 110, 111, 112, 113, 116, 120, 122, 124)
AND "TimePeriodID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "NoWaitingTimeID" = 1
WHERE "RestrictionTypeID" IN (202, 218)
AND "NoWaitingTimeID" IS NULL;
