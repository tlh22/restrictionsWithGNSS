
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
---

--DROP TABLE IF EXISTS mhtc_operations."Bays_tmp_L_M_N_O_P_Q_S2_S3";

CREATE TABLE mhtc_operations."Bays_tmp_L_M_N_O_P_Q_S2_S3" AS 
SELECT r.* FROM toms."Bays" r, import_geojson."SouthwarkProposedDeliveryZones" z
	WHERE ST_Within(r.geom, z.geom)
	AND z.zonename IN ('L', 'M', 'N', 'O', 'P', 'Q', 'S2', 'S3');

ALTER TABLE mhtc_operations."Bays_tmp_L_M_N_O_P_Q_S2_S3" ADD CONSTRAINT "Bays_tmp_L_M_N_O_P_Q_S2_S3_pkey" PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Bays_tmp_L_M_N_O_P_Q_S2_S3_geom"
    ON mhtc_operations."Bays_tmp_L_M_N_O_P_Q_S2_S3" USING gist
    (geom)
    TABLESPACE pg_default;

--DROP TABLE IF EXISTS mhtc_operations."Lines_tmp_L_M_N_O_P_Q_S2_S3";

CREATE TABLE mhtc_operations."Lines_tmp_L_M_N_O_P_Q_S2_S3" AS 
SELECT r.* FROM toms."Lines" r, import_geojson."SouthwarkProposedDeliveryZones" z
	WHERE ST_Within(r.geom, z.geom)
	AND z.zonename IN ('L', 'M', 'N', 'O', 'P', 'Q', 'S2', 'S3');

ALTER TABLE mhtc_operations."Lines_tmp_L_M_N_O_P_Q_S2_S3" ADD CONSTRAINT "Lines_tmp_L_M_N_O_P_Q_S2_S3_pkey" PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Lines_tmp_L_M_N_O_P_Q_S2_S3_geom"
    ON mhtc_operations."Lines_tmp_L_M_N_O_P_Q_S2_S3" USING gist
    (geom)
    TABLESPACE pg_default;
	
	

---

DROP TABLE IF EXISTS mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";
CREATE TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS 
TABLE mhtc_operations."Supply" WITH NO DATA;

ALTER TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" ADD CONSTRAINT "Supply_tmp_L_M_N_O_P_Q_S2_S3_pkey" PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Supply_tmp_L_M_N_O_P_Q_S2_S3_geom"
    ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" USING gist
    (geom)
    TABLESPACE pg_default;

---

CREATE TRIGGER "create_geometryid_supply" BEFORE INSERT ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();

INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth", ogc_fid)
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth", ogc_fid
	FROM mhtc_operations."Bays_tmp_L_M_N_O_P_Q_S2_S3"
	;

INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID", ogc_fid)
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "ParkingTariffArea", "label_loading_pos", "label_loading_ldr", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "ComplianceLoadingMarkingsFaded", "MatchDayTimePeriodID", ogc_fid
	FROM mhtc_operations."Lines_tmp_L_M_N_O_P_Q_S2_S3_v2"
	;

--
	
DROP TRIGGER IF EXISTS "update_capacity_supply" ON "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3";
CREATE TRIGGER "update_capacity_supply" BEFORE INSERT OR UPDATE OF geom, "RestrictionTypeID", "RestrictionLength", "NrBays" ON "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3" FOR EACH ROW EXECUTE FUNCTION "public"."update_capacity"();

UPDATE "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

DROP TRIGGER IF EXISTS "set_restriction_length_Lines" ON mhtc_operations."Supply";

CREATE OR REPLACE TRIGGER "set_restriction_length_Lines"
    BEFORE INSERT OR UPDATE 
    ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
    FOR EACH ROW
    EXECUTE FUNCTION public.set_restriction_length();