-- Supply_orig5

DROP TABLE IF EXISTS mhtc_operations."Supply_orig5" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig5" AS 
TABLE mhtc_operations."Supply";

-- set up crossover nodes table
DROP TABLE IF EXISTS  mhtc_operations."CycleHangarNodes" CASCADE;

CREATE TABLE mhtc_operations."CycleHangarNodes"
(
  id SERIAL,
  geom public.geometry(Point,27700),
  CONSTRAINT "CycleHangarNodes_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CycleHangarNodes"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CycleHangarNodes" TO postgres;

CREATE INDEX "sidx_CycleHangarNodes_geom"
  ON mhtc_operations."CycleHangarNodes"
  USING gist
  (geom);

INSERT INTO mhtc_operations."CycleHangarNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM mhtc_operations."Supply"
WHERe "RestrictionTypeID" = 147;

INSERT INTO mhtc_operations."CycleHangarNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM mhtc_operations."Supply"
WHERe "RestrictionTypeID" = 147;

-- Make "blade" public.geometry

DROP TABLE IF EXISTS  mhtc_operations."CycleHangarNodes_Single" CASCADE;

CREATE TABLE mhtc_operations."CycleHangarNodes_Single"
(
  id SERIAL,
  geom public.geometry(MultiPoint,27700),
  CONSTRAINT "CycleHangarNodes_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CycleHangarNodes_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CycleHangarNodes_Single" TO postgres;

CREATE INDEX "sidx_CycleHangarNodes_Single_geom"
  ON mhtc_operations."CycleHangarNodes_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."CycleHangarNodes_Single" (geom)
SELECT ST_Multi(ST_Collect(geom)) As geom
FROM mhtc_operations."CycleHangarNodes";

-- ***

--ALTER TABLE IF EXISTS demand."VRMs" DROP CONSTRAINT IF EXISTS "VRMs_GeometryID_fkey";

DELETE FROM mhtc_operations."Supply";

INSERT INTO "mhtc_operations"."Supply" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
	"OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "mhtc_operations"."Supply_orig5" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig5" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."CycleHangarNodes_Single"
                                          ) cnr
									  ) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
AND "RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 224, 225, 226, 227, 229, 101, 102, 104, 105, 125, 126, 127, 129, 131, 133, 134, 135, 142, 152, 154, 203, 207, 208, 231)  -- SYLs, SRLs, Unmarked and general bays
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig5" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig5" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."CycleHangarNodes_Single"
                                          ) cnr
									  ) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25)
AND "RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 224, 225, 226, 227, 229, 101, 102, 104, 105, 125, 126, 127, 129, 131, 133, 134, 135, 142, 152, 154, 203, 207, 208, 231)  -- SYLs, SRLs, Unmarked and general bays
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig5" s1
WHERE "RestrictionTypeID" NOT IN (
SELECT "RestrictionTypeID" FROM "mhtc_operations"."Supply_orig5"
WHERE "RestrictionTypeID" IN (201, 216, 217, 220, 221, 222, 224, 225, 226, 227, 229, 101, 102, 104, 105, 125, 126, 127, 129, 131, 133, 134, 135, 142, 152, 154, 203, 207, 208, 231)
)
;

DELETE FROM "mhtc_operations"."Supply"
WHERE ST_Length(geom) < 0.0001;

-- delete unmarked unacceptable lines intersecting with bays


DELETE FROM "mhtc_operations"."Supply" AS s2
USING "mhtc_operations"."Supply" s1
WHERE s1."RestrictionTypeID" = 147
AND s2."GeometryID" != s1."GeometryID"
AND ST_Intersects(s1.geom, ST_Buffer(ST_LineInterpolatePoint(s2.geom, 0.5), 0.1))
;

-- Check for locations where crossovers have not broken restriction

SELECT "GeometryID", c.geom
FROM mhtc_operations."Supply" s, mhtc_operations."CycleHangarNodes_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	)
AND s."RestrictionTypeID" NOT IN (202, 108)   -- DYL, Bus Stop
ORDER BY "GeometryID";
