-- Table: mhtc_operations.Supply


SET search_path TO toms, mhtc_operations, highways_assets, moving_traffic, public;

DROP TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions_orig" CASCADE;

CREATE TABLE local_authority."WaitingLoadingStoppingRestrictions_orig"
(
    "GeometryID" integer NOT NULL,
    image character varying COLLATE pg_catalog."default",
    type character varying COLLATE pg_catalog."default",
    road_marking character varying COLLATE pg_catalog."default",
    days_of_operation character varying COLLATE pg_catalog."default",
    hours_of_operation character varying COLLATE pg_catalog."default",
    length_m double precision,
    tsrgd character varying COLLATE pg_catalog."default",
    spec character varying COLLATE pg_catalog."default",
    zone character varying COLLATE pg_catalog."default",
    street character varying COLLATE pg_catalog."default",
    featid integer,
    notes character varying COLLATE pg_catalog."default",
    photo character varying COLLATE pg_catalog."default",
    id character varying COLLATE pg_catalog."default",
    fault_rpt character varying COLLATE pg_catalog."default",
    geom geometry(LineString,27700),
    "RestrictionTypeID" integer,
    "GeomShapeID" integer,
    "NoWaitingTimeID" integer,
    CONSTRAINT "WaitingLoadingStoppingRestrictions_orig_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO local_authority."WaitingLoadingStoppingRestrictions_orig"(
	"GeometryID", image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, geom, "RestrictionTypeID", "GeomShapeID", "NoWaitingTimeID")
SELECT
	"GeometryID", image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, geom, "RestrictionTypeID", "GeomShapeID", "NoWaitingTimeID"
	FROM local_authority."WaitingLoadingStoppingRestrictions";

DROP INDEX IF EXISTS local_authority."sidx_WaitingLoadingStoppingRestrictions_orig_geom";

CREATE INDEX IF NOT EXISTS "sidx_WaitingLoadingStoppingRestrictions_orig_geom"
    ON local_authority."WaitingLoadingStoppingRestrictions_orig" USING gist
    (geom)
    TABLESPACE pg_default;


DELETE FROM local_authority."WaitingLoadingStoppingRestrictions";


/***
May need to vary the size of the buffer and the snapping tolerance. Not sure why, but ... (possibly buffer size of 0.1?, and snap tolerance of 0.24)
***/

/***
INSERT INTO local_authority."WaitingLoadingStoppingRestrictions" (
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", geom)
SELECT
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", 
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM local_authority."WaitingLoadingStoppingRestrictions_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s2.geom, 0.00000001)) AS geom
									  FROM local_authority."WaitingLoadingStoppingRestrictions_orig" s2,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners_Single"
									  ) cnr) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
union
SELECT
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", 
    s1.geom
FROM local_authority."WaitingLoadingStoppingRestrictions_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM local_authority."WaitingLoadingStoppingRestrictions_orig" s1,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners_Single"
									  ) cnr) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25);



***/


---

INSERT INTO local_authority."WaitingLoadingStoppingRestrictions" (
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeomShapeID", "NoWaitingTimeID", geom)
SELECT 
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeomShapeID", "NoWaitingTimeID", 
(ST_Dump(ST_Split(rc.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM local_authority."WaitingLoadingStoppingRestrictions_orig" rc, 
									(SELECT ST_Union(ST_Snap(cnr.geom, rc.geom, 0.00000001)) AS geom
									  FROM local_authority."WaitingLoadingStoppingRestrictions_orig" rc,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners"
									  union
									  SELECT geom
									  FROM "mhtc_operations"."SectionBreakPoints") cnr) c
WHERE ST_DWithin(rc.geom, c.geom, 0.25);
union
SELECT
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", 
    s1.geom
FROM local_authority."WaitingLoadingStoppingRestrictions_orig" s1, 
									(SELECT ST_Union(ST_Snap(cnr.geom, rc.geom, 0.00000001)) AS geom
									  FROM local_authority."WaitingLoadingStoppingRestrictions_orig" rc,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners"
									  union
									  SELECT geom
									  FROM "mhtc_operations"."SectionBreakPoints") cnr) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25);
---

DELETE FROM local_authority."WaitingLoadingStoppingRestrictions"
WHERE ST_Length(geom) < 0.0001;

-- set road and section details

ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN "DemandSection_GeometryID" character varying(12);
	
UPDATE local_authority."WaitingLoadingStoppingRestrictions" AS c
SET "DemandSection_GeometryID" = closest."DemandSection_GeometryID", "street" = closest."RoadName"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."DemandSection_GeometryID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName"
      FROM local_authority."WaitingLoadingStoppingRestrictions" s, mhtc_operations."Supply" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."DemandSection_GeometryID" IS NULL;

-- Check any locations where the corners have not broken

SELECT "GeometryID", c.geom
FROM local_authority."WaitingLoadingStoppingRestrictions" s, "mhtc_operations"."Corners_Single" c
WHERE ST_DWithin(s.geom, c.geom, 0.25)
AND NOT (
	ST_DWithin(ST_StartPoint(s.geom), c.geom, 0.25) OR
	ST_Dwithin(ST_EndPoint(s.geom), c.geom, 0.25)
	);
	