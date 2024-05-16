--
--DROP TABLE IF EXISTS mhtc_operations."Supply_Copy";

CREATE TABLE mhtc_operations."Supply_Copy"
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
    "SectionID" integer,
    "StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    "Capacity" integer,
    "BayWidth" double precision,
    --CONSTRAINT "Supply_Copy_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_Copy_GeometryID_key" UNIQUE ("GeometryID")
    CONSTRAINT "Supply_Copy_pkey" UNIQUE ("GeometryID")
    );

CREATE INDEX "sidx_Supply_Copy_geom"
    ON mhtc_operations."Supply_Copy" USING gist
    (geom)
    TABLESPACE pg_default;

INSERT INTO mhtc_operations."Supply_Copy"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";

