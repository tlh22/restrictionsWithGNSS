-- Table: mhtc_operations.Supply

SET search_path TO toms, mhtc_operations, highways_assets, moving_traffic, public;

DROP TABLE IF EXISTS mhtc_operations."Supply_orig" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig" AS 
TABLE mhtc_operations."Supply";

/***
CREATE TABLE mhtc_operations."Supply_orig"
(
    --"RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom public.geometry(LineString,27700) NOT NULL,
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
	label_pos public.geometry(MultiPoint,27700),
    label_ldr public.geometry(MultiLineString,27700),
	label_loading_pos public.geometry(MultiPoint,27700),
    label_loading_ldr public.geometry(MultiLineString,27700),
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
    --CONSTRAINT "Supply_orig_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_orig_GeometryID_key" UNIQUE ("GeometryID")
    CONSTRAINT "Supply_orig_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Supply_orig"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";

***/

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
SELECT DISTINCT((ST_Dump(geom)).geom) As geom
FROM mhtc_operations."Corners"
UNION
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."SectionBreakPoints";

/***
INSERT INTO mhtc_operations."Corners_Single" (geom)
SELECT DISTINCT ((ST_Dump(ST_Snap(cnr.geom, rc.geom, 0.25))).geom) AS geom
FROM "topography"."road_casement" rc,
	(SELECT geom, id
	 FROM "mhtc_operations"."Corners"
	 union
	 SELECT geom, id
	 FROM "mhtc_operations"."SectionBreakPoints") cnr;
***/

/*
CREATE OR REPLACE FUNCTION mhtc_operations.cnrPoint(public.geometry) RETURNS public.geometry AS
'SELECT ST_ClosestPoint($1, c.geom) AS geom
FROM mhtc_operations."Corners_Single" c
WHERE ST_Intersects($1, ST_Buffer(c.geom, 2.0))
AND ST_DWithin($1, c.geom, 1.0)'
LANGUAGE SQL;
*/
-- ***


DELETE FROM mhtc_operations."Supply";

/***
May need to vary the size of the buffer and the snapping tolerance. Not sure why, but ... (possibly buffer size of 0.1?, and snap tolerance of 0.24)
***/

INSERT INTO "mhtc_operations"."Supply" (
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom)
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "mhtc_operations"."Supply_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s2.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig" s2,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners_Single"
									  ) cnr) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
union
SELECT
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    s1.geom
FROM "mhtc_operations"."Supply_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Supply_orig" s1,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners_Single"
									  ) cnr) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25);

/***
SELECT ST_Union(ST_Snap(cnr.geom, s2.geom, 0.00000001)) AS geom
FROM "mhtc_operations"."Supply_orig" s2, (
	SELECT geom
	FROM "mhtc_operations"."Corners_Single"
	WHERE ST_DWithin(s2.geom, cnr.geom, 0.25)
	) cnr 
WHERE s2."GeometryID" = 'L_0002114'
AND ST_DWithin(s2.geom, cnr.geom, 0.25)

SELECT 


do $$
DECLARE
	supply_orig_restriction RECORD;
	split_blade geometry;
	
begin

    FOR supply_orig_restriction IN
		SELECT
			"GeometryID"
		FROM "mhtc_operations"."Supply_orig"
		WHERE "GeometryID" = 'L_0002114'
			
	LOOP

		INSERT INTO "mhtc_operations"."Supply" (
				"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
				"SectionID", "StartStreet", "EndStreet", "SideOfStreet",
				geom)
			SELECT
				"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
				"SectionID", "StartStreet", "EndStreet", "SideOfStreet",
				(ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
			FROM "mhtc_operations"."Supply_orig" s1, (
				SELECT ST_Union(ST_Snap(cnr.geom, s2.geom, 0.00000001)) AS geom 
				FROM "mhtc_operations"."Supply_orig" s2, "mhtc_operations"."Corners_Single" cnr
				WHERE s2."GeometryID" = supply_orig_restriction."GeometryID"
				AND ST_DWithin(s2.geom, cnr.geom, 0.25)
					) c
			WHERE ST_DWithin(s1.geom, c.geom, 0.25)
			AND s1."GeometryID" = supply_orig_restriction."GeometryID";

		raise notice 'record: %:%', supply_orig_restriction."GeometryID", found;
		
		IF NOT found THEN
		
			INSERT INTO "mhtc_operations"."Supply" (
				"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
				"SectionID", "StartStreet", "EndStreet", "SideOfStreet",
				geom)
			SELECT
				"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
				"SectionID", "StartStreet", "EndStreet", "SideOfStreet", geom
			FROM "mhtc_operations"."Supply_orig"
			WHERE "GeometryID" = supply_orig_restriction."GeometryID";
		
		END IF;
		
    END LOOP;

end; $$;			
***/


DELETE FROM "mhtc_operations"."Supply"
WHERE ST_Length(geom) < 0.0001;

-- set road details

UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

-- Check any locations where the corners have not broken

SELECT "GeometryID", c.geom
FROM mhtc_operations."Supply" s, "mhtc_operations"."Corners_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	)
AND ST_Contains(s.geom, c.geom)
ORDER BY "GeometryID";

