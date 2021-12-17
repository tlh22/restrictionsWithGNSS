/**
Set up labels for Supply
**/

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_Rotation" double precision;
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_TextChanged" character varying(254) COLLATE pg_catalog."default";

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "labelLoading_Rotation" double precision;
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "labelLoading_TextChanged" character varying(254) COLLATE pg_catalog."default";

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "RestrictionID" character varying(254) COLLATE pg_catalog."default";

-- set label position to default

UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5));

UPDATE mhtc_operations."Supply"
SET label_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), ST_LineInterpolatePoint(geom, 0.5)));

UPDATE mhtc_operations."Supply"
SET label_loading_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5));

UPDATE mhtc_operations."Supply"
SET label_loading_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), ST_LineInterpolatePoint(geom, 0.5)));

-- get trigger working
DROP TRIGGER IF EXISTS "insert_mngmt" ON mhtc_operations."Supply";
CREATE TRIGGER insert_mngmt BEFORE INSERT OR UPDATE ON mhtc_operations."Supply" FOR EACH ROW EXECUTE PROCEDURE toms."labelling_for_restrictions"();

-- Run the trigger once to populate leaders
--UPDATE mhtc_operations."Supply" SET label_pos = label_pos;

-- include RestrictionPolygons
UPDATE "toms"."RestrictionPolygons"
SET label_pos = ST_Multi(ST_PointOnSurface(geom))
-- WHERE "RestrictionTypeID" IN (3, 25)
;

-- Enable trigger
ALTER TABLE toms."RestrictionPolygons" ENABLE TRIGGER insert_mngmt;

-- deal with leader bug?
/**
UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5))
WHERE "GeometryID" IN ('S_002716', 'S_002865', 'S_002925');

UPDATE mhtc_operations."Supply"
SET label_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), ST_LineInterpolatePoint(geom, 0.5)))
WHERE "GeometryID" IN ('S_002716', 'S_002865', 'S_002925');
**/

/**
SELECT ST_Collect(ST_MakeLine(p1, p2)) as p
        FROM (
            SELECT toms.midpoint_or_centroid(geom) as p1
            FROM mhtc_operations."Supply"
        ) as sub1
        JOIN (
            SELECT mg.id, lblpos.geom as p2
            FROM ST_Dump($2::geometry) lblpos
            JOIN toms."MapGrid" mg
            ON ST_Intersects(mg.geom, lblpos.geom)
        ) as sub2 ON sub2.id = sub1.id
;
**/

-- deal with leader bug?
/**
UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5))
WHERE "GeometryID" IN ('S_003033');

UPDATE mhtc_operations."Supply"
--SET label_ldr = NULL;
SET label_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), label_pos))
--WHERE "GeometryID" IN ('S_003033')
;
**/

/**
UPDATE mhtc_operations."Supply"
--SET label_ldr = NULL;
SET label_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), label_pos))
--WHERE "GeometryID" IN ('S_003033')
;
**/

-- ** Remove "dots", i.e., zero length leaders
ALTER TABLE mhtc_operations."Supply" DISABLE TRIGGER insert_mngmt;

UPDATE mhtc_operations."Supply"
SET label_ldr = NULL
WHERE ST_Length(label_ldr) < 0.001;

UPDATE mhtc_operations."Supply"
SET label_loading_ldr = NULL
WHERE ST_Length(label_ldr) < 0.001;

-- Enable trigger
ALTER TABLE mhtc_operations."Supply" ENABLE TRIGGER insert_mngmt;


-- ** Reset label position
/**
UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5))
WHERE "GeometryID" IN ('S_001033');
;
**/