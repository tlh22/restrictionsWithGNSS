-- Table: mhtc_operations.Supply

SET search_path TO toms, mhtc_operations, highways_assets, moving_traffic, public;

DROP TABLE IF EXISTS mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" CASCADE;

CREATE TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" AS 
TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";

ALTER TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" ADD PRIMARY KEY ("GeometryID");

CREATE INDEX Supply_tmp_L_M_N_O_P_Q_S2_S3_orig_geom_idx
  ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig"
  USING GIST (geom);
  

---***
-- set up corner table

DROP TABLE IF EXISTS mhtc_operations."Corners_Single" CASCADE;

CREATE TABLE mhtc_operations."Corners_Single"
(
  id SERIAL,
  geom public.geometry(Point,27700),
  CONSTRAINT "Corners_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."Corners_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."Corners_Single" TO postgres;

-- Index: public."sidx_Corners_Single_geom"

-- DROP INDEX public."sidx_Corners_Single_geom";

CREATE INDEX "sidx_Corners_Single_geom"
  ON mhtc_operations."Corners_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."Corners_Single" (geom)
SELECT DISTINCT((ST_Dump(c.geom)).geom) As geom
FROM mhtc_operations."Corners" /***c, import_geojson."SouthwarkProposedDeliveryZones" z
WHERE ST_Within(c.geom, z.geom)
AND z.zonename IN ('L', 'M', 'N', 'O', 'P', 'Q', 'S2', 'S3') ***/
UNION
SELECT (ST_Dump(c.geom)).geom As geom
FROM mhtc_operations."SectionBreakPoints" /***c, import_geojson."SouthwarkProposedDeliveryZones" z
WHERE ST_Within(c.geom, z.geom)
AND z.zonename IN ('L', 'M', 'N', 'O', 'P', 'Q', 'S2', 'S3') ***/
;
-- ***

DELETE FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";

/***
May need to vary the size of the buffer and the snapping tolerance. Not sure why, but ... (possibly buffer size of 0.1?, and snap tolerance of 0.24)
***/



/***
May need to vary the size of the buffer and the snapping tolerance. Not sure why, but ... (possibly buffer size of 0.1?, and snap tolerance of 0.24)
***/

INSERT INTO "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",  ogc_fid,
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",  s1.ogc_fid,
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s2.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" s2,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners_Single"
									  ) cnr) c
    , import_geojson."SouthwarkProposedDeliveryZones" z
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
AND ST_Within(s1.geom, z.geom)
AND z.zonename IN ('M') --('L', 'M', 'N', 'O', 'P', 'Q', 'S2', 'S3')
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",  s1.ogc_fid,
    s1.geom
FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s2.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig" s2,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners_Single"
									  ) cnr) c
	, import_geojson."SouthwarkProposedDeliveryZones" z
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25)
AND ST_Within(s1.geom, z.geom)
AND z.zonename IN ('M') --('L', 'M', 'N', 'O', 'P', 'Q', 'S2', 'S3');

DELETE FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3"
WHERE ST_Length(geom) < 0.0001;

-- set road details

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

-- Check any locations where the corners have not broken

SELECT "GeometryID", c.geom
FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" s, "mhtc_operations"."Corners_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	)
AND ST_Contains(s.geom, c.geom)
ORDER BY "GeometryID";

/*** Southwark



--

INSERT INTO mhtc_operations."CornerIssues" (geom, "GeometryID")
SELECT DISTINCT (c.geom), "GeometryID"
FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" s, "mhtc_operations"."Corners_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	)
AND ST_Contains(s.geom, c.geom)
ORDER BY "GeometryID";

***/