
--
--DROP TABLE IF EXISTS mhtc_operations."Supply_Copy";

CREATE TABLE mhtc_operations."Supply_Copy" AS 
TABLE mhtc_operations."Supply";

ALTER TABLE mhtc_operations."Supply_Copy" ADD CONSTRAINT "Supply_Copy_pkey" PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Supply_Copy_geom"
    ON mhtc_operations."Supply_Copy" USING gist
    (geom)
    TABLESPACE pg_default;

--

ALTER TABLE mhtc_operations."Supply"
	ADD COLUMN ogc_fid integer;

---

INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth", ogc_fid)
SELECT
    --"RestrictionID",
    "GeometryID", r.geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth", r.ogc_fid
	FROM toms."Bays" r, import_geojson."SouthwarkProposedDeliveryZones" z
	WHERE ST_Within(r.geom, z.geom)
	AND z.zonename IN ('I', 'J')
	;

INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID", ogc_fid)
SELECT
    --"RestrictionID",
    "GeometryID", r.geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID", r.ogc_fid
	FROM toms."Lines" r, import_geojson."SouthwarkProposedDeliveryZones" z
	WHERE ST_Within(r.geom, z.geom)
	AND z.zonename IN ('I', 'J')
	;

CREATE TRIGGER "create_geometryid_supply" BEFORE INSERT ON mhtc_operations."Supply" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();