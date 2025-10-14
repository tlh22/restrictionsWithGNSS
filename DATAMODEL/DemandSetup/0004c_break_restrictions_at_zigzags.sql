-- Supply_orig3

DROP TABLE IF EXISTS mhtc_operations."Supply_orig4" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig4" AS 
TABLE mhtc_operations."Supply";

ALTER TABLE mhtc_operations."Supply_orig4" ADD PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Supply_orig4_geom"
    ON mhtc_operations."Supply_orig4" USING gist
    (geom)
    TABLESPACE pg_default;


-- set up crossover nodes table
DROP TABLE IF EXISTS  mhtc_operations."ZigZagNodes" CASCADE;

CREATE TABLE mhtc_operations."ZigZagNodes"
(
  id SERIAL,
  geom public.geometry(Point,27700),
  CONSTRAINT "ZigZagNodes_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."ZigZagNodes"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."ZigZagNodes" TO postgres;

CREATE INDEX "sidx_ZigZagNodes_geom"
  ON mhtc_operations."ZigZagNodes"
  USING gist
  (geom);

/***
INSERT INTO mhtc_operations."ZigZagNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM mhtc_operations."Supply_orig3"
WHERE "RestrictionTypeID" = 220
AND "UnacceptableTypeID" IN (1, 4);

INSERT INTO mhtc_operations."ZigZagNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM mhtc_operations."Supply_orig3"
WHERE "RestrictionTypeID" = 220
AND "UnacceptableTypeID" IN (1, 4);
***/

INSERT INTO mhtc_operations."ZigZagNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM mhtc_operations."Supply"
WHERE "RestrictionTypeID" IN (203, 204, 205, 206, 207, 208);

INSERT INTO mhtc_operations."ZigZagNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM mhtc_operations."Supply"
WHERE "RestrictionTypeID" IN (203, 204, 205, 206, 207, 208);

-- Make "blade" public.geometry

DROP TABLE IF EXISTS  mhtc_operations."ZigZagNodes_Single" CASCADE;

CREATE TABLE mhtc_operations."ZigZagNodes_Single"
(
  id SERIAL,
  geom public.geometry(MultiPoint,27700),
  CONSTRAINT "ZigZagNodes_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."ZigZagNodes_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."ZigZagNodes_Single" TO postgres;

CREATE INDEX "sidx_ZigZagNodes_Single_geom"
  ON mhtc_operations."ZigZagNodes_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."ZigZagNodes_Single" (geom)
SELECT ST_Multi(ST_Collect(geom)) As geom
FROM mhtc_operations."ZigZagNodes";

-- ***

ALTER TABLE IF EXISTS demand."VRMs" DROP CONSTRAINT IF EXISTS "VRMs_GeometryID_fkey";

DELETE FROM mhtc_operations."Supply";

--


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
FROM "mhtc_operations"."Supply_orig4" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig4" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."ZigZagNodes_Single"
                                          ) cnr
									  ) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
AND "RestrictionTypeID" IN (201, 202, 216, 217, 218, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229)  -- Yellow and Red lines
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig4" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig4" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."ZigZagNodes_Single"
                                          ) cnr
									  ) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25)
AND "RestrictionTypeID" IN (201, 202, 216, 217, 218, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229)  -- Yellow and Red lines
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", --"label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr",
    "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig4" s1
WHERE "RestrictionTypeID" NOT IN (
SELECT "RestrictionTypeID" FROM "mhtc_operations"."Supply_orig4"
WHERE "RestrictionTypeID" IN (201, 202, 216, 217, 218, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229)  -- Yellow and Red lines
)
;

DELETE FROM "mhtc_operations"."Supply"
WHERE ST_Length(geom) < 0.0001;




-- Check for locations where restrictions have not broken restriction

SELECT "GeometryID", c.geom
FROM mhtc_operations."Supply" s, mhtc_operations."ZigZagNodes_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	)
--AND s."RestrictionTypeID" NOT IN (202, 108)   -- DYL, Bus Stop
ORDER BY "GeometryID";
