
INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth"
	FROM toms."Bays";

INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID"
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

--
DROP MATERIALIZED VIEW IF EXISTS toms_lookups."BayLineTypesInUse_View" CASCADE;

--DROP MATERIALIZED VIEW IF EXISTS toms_lookups."BayLineTypesInUse_View" CASCADE;

CREATE MATERIALIZED VIEW toms_lookups."BayLineTypesInUse_View"
TABLESPACE pg_default
AS
 SELECT "BayTypesInUse"."Code",
    "BayLineTypes"."Description"
   FROM toms_lookups."BayTypesInUse",
    toms_lookups."BayLineTypes"
  WHERE "BayTypesInUse"."Code" = "BayLineTypes"."Code" AND "BayTypesInUse"."Code" < 200
  UNION
  SELECT "LineTypesInUse"."Code",
    "BayLineTypes"."Description"
   FROM toms_lookups."LineTypesInUse",
    toms_lookups."BayLineTypes"
  WHERE "LineTypesInUse"."Code" = "BayLineTypes"."Code" AND "LineTypesInUse"."Code" > 200
WITH DATA;

ALTER TABLE toms_lookups."BayLineTypesInUse_View"
    OWNER TO postgres;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE toms_lookups."BayLineTypesInUse_View" TO toms_admin;
GRANT ALL ON TABLE toms_lookups."BayLineTypesInUse_View" TO postgres;
GRANT SELECT ON TABLE toms_lookups."BayLineTypesInUse_View" TO toms_public;
GRANT SELECT ON TABLE toms_lookups."BayLineTypesInUse_View" TO toms_operator;

CREATE UNIQUE INDEX "BayLineTypesInUse_View_key"
    ON toms_lookups."BayLineTypesInUse_View" USING btree
    ("Code")
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW toms_lookups."BayLineTypesInUse_View" WITH DATA;