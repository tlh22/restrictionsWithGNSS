/***

Remove overlapping sections

***/

DROP TABLE IF EXISTS mhtc_operations."SupplySectionsTrimmed" CASCADE;

CREATE TABLE mhtc_operations."SupplySectionsTrimmed"
(
    --"RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
	gid integer primary key generated always as identity, 
    "GeometryID" character varying(12) COLLATE pg_catalog."default",
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
    "Capacity" integer,
    "BayWidth" double precision,
    "SectionID" integer,
	"StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    "SurveyAreaID" integer,
	"DemandSection_GeometryID" character varying(12) COLLATE pg_catalog."default" 
    --CONSTRAINT "Supply_orig_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_orig_GeometryID_key" UNIQUE ("GeometryID")
    --CONSTRAINT "SupplySectionsTrimmed_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."SupplySectionsTrimmed"(
	--"RestrictionID",
	"GeometryID", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "SurveyAreaID", "DemandSection_GeometryID", geom)
SELECT
    --"RestrictionID",
    "GeometryID", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "SurveyAreaID", "DemandSection_GeometryID",
	(ST_Dump(COALESCE(ST_Difference(geom, (SELECT ST_Buffer(ST_Union(b.geom), 0.00001, 'endcap=flat')
											 FROM mhtc_operations."Supply" a, local_authority."WaitingLoadingStoppingRestrictions" b
											 WHERE ST_Intersects(a.geom, ST_Buffer(b.geom, 0.00001, 'endcap=flat'))
											 )), geom))).geom
	FROM mhtc_operations."Supply";

UPDATE mhtc_operations."SupplySectionsTrimmed"
SET "RestrictionTypeID" = 225
WHERE "RestrictionTypeID" = 1000;

/***

Now add the new restrictions

***/

INSERT INTO mhtc_operations."SupplySectionsTrimmed"(
	"RestrictionTypeID", "RestrictionLength", "GeomShapeID", "NoWaitingTimeID", "RoadName", "DemandSection_GeometryID", geom
	)
SELECT
	"RestrictionTypeID", ST_Length(geom), "GeomShapeID", "NoWaitingTimeID", street, "DemandSection_GeometryID", geom
FROM local_authority."WaitingLoadingStoppingRestrictions";


/***

Move to supply

***/

/***

DELETE FROM mhtc_operations."Supply";

INSERT INTO "mhtc_operations"."Supply" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "DemandSection_GeometryID",
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "DemandSection_GeometryID",
	geom
FROM mhtc_operations."SupplySectionsTrimmed";

***/

DROP TRIGGER IF EXISTS "update_capacity_supply" ON "mhtc_operations"."SupplySectionsTrimmed";
CREATE TRIGGER "update_capacity_supply" BEFORE INSERT OR UPDATE OF geom, "RestrictionTypeID", "RestrictionLength", "NrBays" ON "mhtc_operations"."SupplySectionsTrimmed" FOR EACH ROW EXECUTE FUNCTION "public"."update_capacity"();

UPDATE "mhtc_operations"."SupplySectionsTrimmed"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);