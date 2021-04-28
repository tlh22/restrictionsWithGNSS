/***
Some cycle hangars have been created as "dual restrictions". This script will find those and split the underlying restriction aroudn the hangar
***/

-- Bays_split_with_cycle_hangars

DROP TABLE IF EXISTS mhtc_operations."Bays_split_with_cycle_hangars" CASCADE;

CREATE TABLE mhtc_operations."Bays_split_with_cycle_hangars"
(
    "RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL DEFAULT ('B_'::text || to_char(nextval('toms."Bays_id_seq"'::regclass), 'FM0000000'::text)),
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
    "label_Rotation" double precision,
    "label_TextChanged" character varying(254) COLLATE pg_catalog."default",
    "OpenDate" date,
    "CloseDate" date,
    "CPZ" character varying(40) COLLATE pg_catalog."default",
    "LastUpdateDateTime" timestamp without time zone NOT NULL,
    "LastUpdatePerson" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "BayOrientation" double precision,
    "NrBays" integer NOT NULL DEFAULT '-1'::integer,
    "TimePeriodID" integer NOT NULL,
    "PayTypeID" integer,
    "MaxStayID" integer,
    "NoReturnID" integer,
    "ParkingTariffArea" character varying(10) COLLATE pg_catalog."default",
    "AdditionalConditionID" integer,
    "ComplianceRoadMarkingsFaded" integer,
    "ComplianceRestrictionSignIssue" integer,
    "ComplianceNotes" character varying(254) COLLATE pg_catalog."default",
    "MHTC_CheckIssueTypeID" integer,
    "MHTC_CheckNotes" character varying(254) COLLATE pg_catalog."default",
    "MatchDayTimePeriodID" integer,
    "FieldCheckCompleted" boolean NOT NULL DEFAULT false,
    "Last_MHTC_Check_UpdateDateTime" timestamp without time zone,
    "Last_MHTC_Check_UpdatePerson" character varying(255) COLLATE pg_catalog."default",
    "PayParkingAreaCode" character varying(255) COLLATE pg_catalog."default",
    "PermitCode" character varying(255) COLLATE pg_catalog."default",
    "PayParkingAreaID" integer,
    "CreateDateTime" timestamp without time zone NOT NULL,
    "CreatePerson" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    label_pos geometry(MultiPoint,27700),
    label_ldr geometry(MultiLineString,27700),
    "MatchDayEventDayZone" character varying(40) COLLATE pg_catalog."default",
    "Capacity" integer,
    "BayWidth" double precision,
    CONSTRAINT "Bays_split_with_cycle_hangars_pkey" PRIMARY KEY ("RestrictionID"),
    CONSTRAINT "Bays_split_with_cycle_hangars_GeometryID_key" UNIQUE ("GeometryID"),
    CONSTRAINT "Bays_split_with_cycle_hangars_AdditionalConditionID_fkey" FOREIGN KEY ("AdditionalConditionID")
        REFERENCES toms_lookups."AdditionalConditionTypes" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_ComplianceRestrictionSignIssue_fkey" FOREIGN KEY ("ComplianceRestrictionSignIssue")
        REFERENCES compliance_lookups."Restriction_SignIssueTypes" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_ComplianceRoadMarkingsFaded_fkey" FOREIGN KEY ("ComplianceRoadMarkingsFaded")
        REFERENCES compliance_lookups."RestrictionRoadMarkingsFadedTypes" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_GeomShapeID_fkey" FOREIGN KEY ("GeomShapeID")
        REFERENCES toms_lookups."RestrictionGeomShapeTypes" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_MHTC_CheckIssueTypeID_fkey" FOREIGN KEY ("MHTC_CheckIssueTypeID")
        REFERENCES compliance_lookups."MHTC_CheckIssueTypes" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_MatchDayEventDayZone_fkey" FOREIGN KEY ("MatchDayEventDayZone")
        REFERENCES toms."MatchDayEventDayZones" ("EDZ") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_MatchDayTimePeriodID_fkey" FOREIGN KEY ("MatchDayTimePeriodID")
        REFERENCES toms_lookups."TimePeriodsInUse" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_MaxStayID_fkey" FOREIGN KEY ("MaxStayID")
        REFERENCES toms_lookups."LengthOfTime" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_NoReturnID_fkey" FOREIGN KEY ("NoReturnID")
        REFERENCES toms_lookups."LengthOfTime" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_PayParkingAreaID_fkey" FOREIGN KEY ("PayParkingAreaID")
        REFERENCES local_authority."PayParkingAreas" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_PayTypeID_fkey" FOREIGN KEY ("PayTypeID")
        REFERENCES toms_lookups."PaymentTypes" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_RestrictionTypeID_fkey" FOREIGN KEY ("RestrictionTypeID")
        REFERENCES toms_lookups."BayTypesInUse" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Bays_split_with_cycle_hangars_TimePeriodID_fkey" FOREIGN KEY ("TimePeriodID")
        REFERENCES toms_lookups."TimePeriodsInUse" ("Code") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."Bays_split_with_cycle_hangars"
    OWNER to postgres;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE mhtc_operations."Bays_split_with_cycle_hangars" TO toms_admin;

GRANT SELECT ON TABLE mhtc_operations."Bays_split_with_cycle_hangars" TO toms_public;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE mhtc_operations."Bays_split_with_cycle_hangars" TO toms_operator;

GRANT ALL ON TABLE mhtc_operations."Bays_split_with_cycle_hangars" TO postgres;
-- Index: sidx_Bays_geom

-- DROP INDEX toms."sidx_Bays_geom";

CREATE INDEX "sidx_Bays_split_with_cycle_hangars_geom"
    ON mhtc_operations."Bays_split_with_cycle_hangars" USING gist
    (geom)
    TABLESPACE pg_default;


--- populate
/*
INSERT INTO mhtc_operations."Bays_split_with_cycle_hangars"(
	"RestrictionID", "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "PayParkingAreaCode", "PermitCode", "PayParkingAreaID", "CreateDateTime", "CreatePerson", label_pos, label_ldr, "MatchDayEventDayZone", "Capacity", "BayWidth")
SELECT "RestrictionID", "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "PayParkingAreaCode", "PermitCode", "PayParkingAreaID", "CreateDateTime", "CreatePerson", label_pos, label_ldr, "MatchDayEventDayZone", "Capacity", "BayWidth"
	FROM toms."Bays";
*/

-- set up crossover nodes table
DROP TABLE IF EXISTS  mhtc_operations."CycleHangarCrossoverNodes" CASCADE;

CREATE TABLE mhtc_operations."CycleHangarCrossoverNodes"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "CycleHangarCrossoverNodes_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CycleHangarCrossoverNodes"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CycleHangarCrossoverNodes" TO postgres;

CREATE INDEX "sidx_CycleHangarCrossoverNodes_geom"
  ON mhtc_operations."CycleHangarCrossoverNodes"
  USING gist
  (geom);

CREATE TABLE mhtc_operations."CycleHangarsAsDualRestrictions" ("GeometryID", geom) AS
SELECT b1."GeometryID", b1.geom
FROM (SELECT "GeometryID", geom
      FROM toms."Bays"
      WHERE "RestrictionTypeID" = 147) b1,
     (SELECT "GeometryID", geom
      FROM toms."Bays"
      WHERE "RestrictionTypeID" != 147) b2
WHERE ST_Within (b1.geom, ST_Buffer(b2.geom, 0.5));

INSERT INTO mhtc_operations."CycleHangarCrossoverNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM mhtc_operations."CycleHangarsAsDualRestrictions";

INSERT INTO mhtc_operations."CycleHangarCrossoverNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM mhtc_operations."CycleHangarsAsDualRestrictions";

--

INSERT INTO mhtc_operations."Bays_split_with_cycle_hangars"(
	"RestrictionID", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "PayParkingAreaCode", "PermitCode", "PayParkingAreaID", "CreateDateTime", "CreatePerson", label_pos, label_ldr, "MatchDayEventDayZone", "Capacity", "BayWidth", geom)
SELECT uuid_generate_v4()::text, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "PayParkingAreaCode", "PermitCode", "PayParkingAreaID", "CreateDateTime", "CreatePerson", label_pos, label_ldr, "MatchDayEventDayZone", "Capacity", "BayWidth",
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM toms."Bays" s1, (SELECT ST_Union(ST_Snap(h.geom, s.geom, 0.00000001)) AS geom
									  FROM toms."Bays" s,
									  (SELECT geom
									  FROM "mhtc_operations"."CycleHangarCrossoverNodes"
									  ) h) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
union
SELECT "RestrictionID", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_Rotation", "label_TextChanged", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "PayParkingAreaCode", "PermitCode", "PayParkingAreaID", "CreateDateTime", "CreatePerson", label_pos, label_ldr, "MatchDayEventDayZone", "Capacity", "BayWidth",
    s1.geom
FROM toms."Bays" s1, (SELECT ST_Union(ST_Snap(h.geom, s.geom, 0.00000001)) AS geom
									  FROM toms."Bays" s,
									  (SELECT geom
									  FROM "mhtc_operations"."CycleHangarCrossoverNodes"
									  ) h) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25)

/*

-- set up triggers

-- Trigger: create_geometryid_bays

-- DROP TRIGGER create_geometryid_bays ON toms."Bays";

CREATE TRIGGER create_geometryid_bays
    BEFORE INSERT
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE public.create_geometryid();

-- Trigger: insert_mngmt

-- DROP TRIGGER insert_mngmt ON toms."Bays";

CREATE TRIGGER insert_mngmt
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE toms.labelling_for_restrictions();

-- Trigger: set_bay_geom_type_trigger

-- DROP TRIGGER set_bay_geom_type_trigger ON toms."Bays";

CREATE TRIGGER set_bay_geom_type_trigger
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_bay_geom_type();

-- Trigger: set_create_details_Bays

-- DROP TRIGGER "set_create_details_Bays" ON toms."Bays";

CREATE TRIGGER "set_create_details_Bays"
    BEFORE INSERT
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_create_details();

-- Trigger: set_last_update_details_Bays

-- DROP TRIGGER "set_last_update_details_Bays" ON toms."Bays";

CREATE TRIGGER "set_last_update_details_Bays"
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_last_update_details();

-- Trigger: set_restriction_length_Bays

-- DROP TRIGGER "set_restriction_length_Bays" ON toms."Bays";

CREATE TRIGGER "set_restriction_length_Bays"
    BEFORE INSERT OR UPDATE OF geom
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_restriction_length();

-- Trigger: update_capacity_bays

-- DROP TRIGGER update_capacity_bays ON toms."Bays";

CREATE TRIGGER update_capacity_bays
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Bays_split_with_cycle_hangars"
    FOR EACH ROW
    EXECUTE PROCEDURE public.update_capacity();
*/

DELETE FROM mhtc_operations."Bays_split_with_cycle_hangars"
WHERE ST_Length(geom) < 0.0001;
