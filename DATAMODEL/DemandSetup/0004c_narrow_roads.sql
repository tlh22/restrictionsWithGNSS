--- Narrow roads

DROP TABLE IF EXISTS mhtc_operations."IntersectionWithin49m";
CREATE TABLE mhtc_operations."IntersectionWithin49m" (gid serial, geom geometry(Geometry,27700), PRIMARY KEY(gid));

INSERT INTO mhtc_operations."IntersectionWithin49m" (geom)
SELECT

      (ST_Dump(st_intersection(
        line1.geom,
        st_buffer(line2.geom,4.7)))).geom as geom

FROM
  (SELECT gid, "RoadName", geom from mhtc_operations."RC_Sections_merged") as line1,
  (SELECT gid, "RoadName", geom from mhtc_operations."RC_Sections_merged") as line2
WHERE
  st_Intersects(line1.geom, st_buffer(line2.geom, 4.7))
  AND NOT ST_DWithin(line1.geom, line2.geom, 0.25) -- make sure that they are not joined
  AND line1.gid <> line2.gid
  AND line1."RoadName" = line2."RoadName";

ALTER TABLE mhtc_operations."IntersectionWithin49m"
  OWNER TO postgres;

DROP TABLE IF EXISTS mhtc_operations."IntersectionWithin67m";
CREATE TABLE mhtc_operations."IntersectionWithin67m" (gid serial, geom geometry(Geometry,27700), PRIMARY KEY(gid));

INSERT INTO mhtc_operations."IntersectionWithin67m" (geom)
SELECT

      (ST_Dump(st_intersection(
        line1.geom,
        st_buffer(line2.geom,6.5)))).geom as geom

FROM
  (SELECT gid, "RoadName", geom from mhtc_operations."RC_Sections_merged") as line1,
  (SELECT gid, "RoadName", geom from mhtc_operations."RC_Sections_merged") as line2
WHERE
  st_intersects(line1.geom, st_buffer(line2.geom, 6.5))
  AND NOT ST_DWithin(line1.geom, line2.geom, 0.25) -- make sure that they are not joined
  AND line1.gid <> line2.gid
  AND line1."RoadName" = line2."RoadName";

ALTER TABLE mhtc_operations."IntersectionWithin67m"
  OWNER TO postgres;

DROP TABLE IF EXISTS mhtc_operations."IntersectionWithin10m";
CREATE TABLE mhtc_operations."IntersectionWithin10m" (gid serial, geom geometry(Geometry,27700));

INSERT INTO mhtc_operations."IntersectionWithin10m" (geom)
SELECT

      (ST_Dump(st_intersection(
        line1.geom,
        st_buffer(line2.geom,9.8)))).geom as geom

FROM
  (SELECT gid, "RoadName", geom from mhtc_operations."RC_Sections_merged") as line1,
  (SELECT gid, "RoadName", geom from mhtc_operations."RC_Sections_merged") as line2
WHERE
  st_intersects(line1.geom, st_buffer(line2.geom, 9.8))
  AND NOT ST_DWithin(line1.geom, line2.geom, 0.25) -- make sure that they are not joined
  AND line1.gid <> line2.gid
  AND line1."RoadName" = line2."RoadName";

ALTER TABLE mhtc_operations."IntersectionWithin10m"
  OWNER TO postgres;

/***

Consider bays opposite SYLs/Unmarked areas/ZigZags

***/

/***
DROP TABLE IF EXISTS mhtc_operations."IntersectionWithin49m_Bays";
CREATE TABLE mhtc_operations."IntersectionWithin49m_Bays" (
gid serial, 
geom geometry(Geometry,27700),
PRIMARY KEY(gid));
***/
  
INSERT INTO mhtc_operations."IntersectionWithin49m" (geom)
SELECT 
      (ST_Dump(st_intersection(
        line1.geom,
        st_buffer(line2.geom,6.5)))).geom as geom

FROM
  (SELECT "GeometryID" , "RoadName", geom from mhtc_operations."Supply" WHERE "RestrictionTypeID" IN (201, 203, 207, 208, 216, 224, 225, 227, 229)) as line1,
  (SELECT "GeometryID" , "RoadName", geom from mhtc_operations."Supply" WHERE "RestrictionTypeID" < 200) as line2
WHERE
  st_Intersects(line1.geom, st_buffer(line2.geom, 6.5))
  AND NOT ST_DWithin(line1.geom, line2.geom, 0.25) -- make sure that they are not joined
  AND line1."GeometryID" <> line2."GeometryID"
  AND line1."RoadName" = line2."RoadName";
  
  
-- Check for SYL/SRL/Unmarked areas that overlap

SELECT '4.9' AS "Distance", s."GeometryID", s."Description", s."RoadName"
FROM (mhtc_operations."Supply" a LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s,
      mhtc_operations."IntersectionWithin49m" d
WHERE ST_INTERSECTS(s.geom, ST_Buffer(d.geom, 0.1))
AND (s."RestrictionTypeID" IN (201, 216, 217)
--OR s."RestrictionTypeID" IN (220, 221, 222)
--OR s."RestrictionTypeID" IN (224, 225, 226)
	 )
--ORDER BY  s."Description"

UNION

SELECT '6.7' AS "Distance", s."GeometryID", s."Description", s."RoadName"
FROM (mhtc_operations."Supply" a LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s,
      mhtc_operations."IntersectionWithin67m" d
WHERE ST_INTERSECTS(s.geom, ST_Buffer(d.geom, 0.1))
AND (s."RestrictionTypeID" IN (201, 216, 217)
--OR s."RestrictionTypeID" IN (220, 221, 222)
--OR s."RestrictionTypeID" IN (224, 225, 226)
	 )
ORDER BY  "Description", "RoadName"
;

/***
 Add fields
***/

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN IF NOT EXISTS "IntersectionWithin49m" double precision;

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN IF NOT EXISTS "IntersectionWithin67m" double precision;

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN IF NOT EXISTS "IntersectionWithin10m" double precision;


UPDATE mhtc_operations."Supply" AS s1
SET "IntersectionWithin49m" = 
	(SELECT SUM (ST_LENGTH(ST_INTERSECTION(s2.geom, ST_Buffer(d.geom, 0.1))))
	FROM mhtc_operations."Supply" s2, mhtc_operations."IntersectionWithin49m" d 
	WHERE ST_INTERSECTS(s2.geom, ST_Buffer(d.geom, 0.1))
	AND s1."GeometryID" = s2."GeometryID");

UPDATE mhtc_operations."Supply" AS s1
SET "IntersectionWithin67m" = 
	(SELECT SUM (ST_LENGTH(ST_INTERSECTION(s2.geom, ST_Buffer(d.geom, 0.1))))
	FROM mhtc_operations."Supply" s2, mhtc_operations."IntersectionWithin67m" d 
	WHERE ST_INTERSECTS(s2.geom, ST_Buffer(d.geom, 0.1))
	AND s1."GeometryID" = s2."GeometryID");

UPDATE mhtc_operations."Supply" AS s1
SET "IntersectionWithin10m" = 
	(SELECT SUM (ST_LENGTH(ST_INTERSECTION(s2.geom, ST_Buffer(d.geom, 0.1))))
	FROM mhtc_operations."Supply" s2, mhtc_operations."IntersectionWithin10m" d 
	WHERE ST_INTERSECTS(s2.geom, ST_Buffer(d.geom, 0.1))
	AND s1."GeometryID" = s2."GeometryID");
