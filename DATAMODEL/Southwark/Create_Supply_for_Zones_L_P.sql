/***

Earlier supply was based on sections. 

Need to split around new restrictions and then remove.

***/

--- Prepare supply table from bays/lines

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

/***
-- Now consider the supply from the uncontrolled areas
***/

-- Create a blade from the new restrictions

DROP TABLE IF EXISTS mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2" CASCADE;

CREATE TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2" AS 
TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" WITH NO DATA;

ALTER TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2" ADD PRIMARY KEY ("GeometryID");

CREATE INDEX Supply_tmp_L_M_N_O_P_Q_S2_S3_v2_geom_idx
  ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2"
  USING GIST (geom);

CREATE TRIGGER "create_geometryid_Supply_tmp_L_M_N_O_P_Q_S2_S3_v2" BEFORE INSERT ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();

INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	--"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", -- ogc_fid,
    geom)

SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	--"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", -- ogc_fid,
	(ST_Dump(COALESCE(ST_Difference(geom, (SELECT ST_Buffer(ST_Union(geom), 1, 'endcap=flat')
											 FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
											 )), geom))).geom
	FROM mhtc_operations."Supply_Uncontrolled_Sections_2023"  
;

/***
SELECT "RoadName" FROM mhtc_operations."Lines_tmp_L_M_N_O_P_Q_S2_S3"
WHERE  "RoadName" = UPPER("RoadName") ;
***/

---

-- Now add these details to Supply

INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
	geom
	FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v2"  
;


/***
Now consider Zone P - use sections
***/

--- create a blade around the existing restrictions

DROP TABLE IF EXISTS mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3" CASCADE;

CREATE TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3" AS 
TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" WITH NO DATA;

ALTER TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3" ADD PRIMARY KEY ("GeometryID");

CREATE INDEX Supply_tmp_L_M_N_O_P_Q_S2_S3_v3_geom_idx
  ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3"
  USING GIST (geom);

CREATE TRIGGER "create_geometryid_Supply_tmp_L_M_N_O_P_Q_S2_S3_v3" BEFORE INSERT ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();

INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	--"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", -- ogc_fid,
    geom)

SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	--"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", -- ogc_fid,
	(ST_Dump(COALESCE(ST_Difference(geom, (SELECT ST_Buffer(ST_Union(geom), 1, 'endcap=flat')
											 FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
											 )), geom))).geom
	FROM mhtc_operations."RC_Sections_merged_Zone_P"  
;

-- Now add these details to Supply

INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", 
	"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", 
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
	geom
	FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_v3"  
;

---

DROP TRIGGER IF EXISTS "set_restriction_length_Lines" ON "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3";

CREATE TRIGGER "set_restriction_length_Lines"
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_restriction_length();
	
DROP TRIGGER IF EXISTS "update_capacity_supply" ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";
CREATE TRIGGER "update_capacity_supply" BEFORE INSERT OR UPDATE OF geom, "RestrictionTypeID", "RestrictionLength", "NrBays" ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" FOR EACH ROW EXECUTE FUNCTION "public"."update_capacity"();

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);


/***

-- Add to Supply

ALTER TABLE IF EXISTS mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
  ADD COLUMN IF NOT EXISTS "SurveyAreaID" INTEGER;

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "SurveyAreaID" = NULL;

UPDATE "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SurveyAreaID" IS NULL;


-- Calculate length/capacity within area

SELECT a."SurveyAreaName", SUM(s."RestrictionLength") AS "RestrictionLength", SUM("Capacity") AS "Total Capacity",
SUM (CASE WHEN "RestrictionTypeID" > 200 THEN 0 ELSE s."Capacity" END) AS "Bay Capacity"
FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" s, mhtc_operations."SurveyAreas" a
WHERE a."Code" = s."SurveyAreaID"
--AND a."SurveyAreaName" LIKE 'V%'
GROUP BY a."SurveyAreaName"
ORDER BY a."SurveyAreaName";

***/