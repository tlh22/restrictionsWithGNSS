
--
--DROP TABLE IF EXISTS mhtc_operations."Supply_Copy";

CREATE TABLE mhtc_operations."Supply_Copy_I_J" AS 
TABLE mhtc_operations."Supply";

ALTER TABLE mhtc_operations."Supply_Copy_I_J" ADD CONSTRAINT "Supply_Copy_I_J_pkey" PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Supply_Copy_I_J_geom"
    ON mhtc_operations."Supply_Copy_I_J" USING gist
    (geom)
    TABLESPACE pg_default;

--

ALTER TABLE IF EXISTS mhtc_operations."Supply"
	ADD COLUMN IF NOT EXISTS ogc_fid integer;

---

CREATE TABLE mhtc_operations."Supply_tmp_C_D_E_F_G_H_K" AS 
TABLE mhtc_operations."Supply" WITH NO DATA;

ALTER TABLE mhtc_operations."Supply_tmp_C_D_E_F_G_H_K" ADD CONSTRAINT "Supply_tmp_C_D_E_F_G_H_K_pkey" PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Supply_tmp_C_D_E_F_G_H_K_geom"
    ON mhtc_operations."Supply_tmp_C_D_E_F_G_H_K" USING gist
    (geom)
    TABLESPACE pg_default;

---

CREATE TRIGGER "create_geometryid_supply" BEFORE INSERT ON mhtc_operations."Supply_tmp_C_D_E_F_G_H_K" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();

INSERT INTO mhtc_operations."Supply_tmp_C_D_E_F_G_H_K"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth", ogc_fid)
SELECT
    --"RestrictionID",
    "GeometryID", r.geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth", r.ogc_fid
	FROM toms."Bays" r, import_geojson."SouthwarkProposedDeliveryZones" z
	WHERE ST_Within(r.geom, z.geom)
	AND z.zonename IN ('C', 'D', 'E', 'F', 'G', 'H', 'K')
	;

INSERT INTO mhtc_operations."Supply_tmp_C_D_E_F_G_H_K"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID", ogc_fid)
SELECT
    --"RestrictionID",
    "GeometryID", r.geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID", r.ogc_fid
	FROM toms."Lines" r, import_geojson."SouthwarkProposedDeliveryZones" z
	WHERE ST_Within(r.geom, z.geom)
	AND z.zonename IN ('C', 'D', 'E', 'F', 'G', 'H', 'K')
	;
