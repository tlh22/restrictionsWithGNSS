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

	SELECT concat('S_', to_char(nextval('"mhtc_operations"."Supply_id_seq"'::regclass), 'FM000000'::text)) INTO nextSeqVal;

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
    --"label_X" double precision,
    --"label_Y" double precision,
    --"label_Rotation" double precision,
    --"labelLoading_X" double precision,
    --"labelLoading_Y" double precision,
    --"labelLoading_Rotation" double precision,
    --"label_TextChanged" character varying(254) COLLATE pg_catalog."default",
	label_pos geometry(MultiPoint,27700),
    label_ldr geometry(MultiLineString,27700),
	label_loading_pos geometry(MultiPoint,27700),
    label_loading_ldr geometry(MultiLineString,27700),
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
    "SectionID" integer,
    "StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    "Capacity" integer,
    "BayWidth" double precision,
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
