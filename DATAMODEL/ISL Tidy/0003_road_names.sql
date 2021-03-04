ALTER TABLE "highways_network"."roadlink"
    RENAME COLUMN wkb_geometry to geom;

ALTER TABLE "highways_network"."roadlink"
    RENAME COLUMN ogc_fid to id;

ALTER SEQUENCE highways_network.road_ogc_fid_seq
    RENAME TO roadlink_id_seq;

ALTER TABLE "highways_network"."roadlink"
    RENAME COLUMN roadname to name1;

ALTER TABLE "highways_network"."roadlink"
    ALTER COLUMN geom TYPE geometry(linestring, 27700) USING ST_Force2D(ST_GeometryN(geom, 1));

-- then run 0001b_setup_roadlink.sql, 0002a_create_sections.sql, 0002b_create_sections_merged.sql

-- deal with USRN
ALTER TABLE "mhtc_operations"."RC_Sections_merged"
    ADD COLUMN "USRN" bigint;

DROP FUNCTION IF EXISTS mhtc_operations."get_nearest_roadlink_to_section"(section_id integer);
CREATE OR REPLACE FUNCTION mhtc_operations."get_nearest_roadlink_to_section"(section_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	 roadlink_id integer;
BEGIN

    -- find nearest junction

    SELECT cl."id"
	INTO roadlink_id
    FROM "highways_network"."roadlink" cl, "mhtc_operations"."RC_Sections_merged" s
    WHERE s.gid = section_id
    AND ST_DWithin(ST_LineInterpolatePoint(s.geom, 0.5), cl.geom, 30.0)
    ORDER BY
      ST_Distance(ST_LineInterpolatePoint(s.geom, 0.5), ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)))
    LIMIT 1;

    RETURN roadlink_id;

END;
$BODY$;

UPDATE "mhtc_operations"."RC_Sections_merged" AS c
SET "USRN" = r."localid"
FROM "highways_network"."roadlink" r
WHERE r."id" = mhtc_operations."get_nearest_roadlink_to_section"(c.gid);
