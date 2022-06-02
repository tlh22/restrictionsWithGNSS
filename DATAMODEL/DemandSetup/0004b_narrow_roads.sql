--- Narrow roads

DROP TABLE IF EXISTS mhtc_operations."IntersectionWithin49m";
CREATE TABLE mhtc_operations."IntersectionWithin49m" (gid serial, geom geometry(Geometry,27700));

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
CREATE TABLE mhtc_operations."IntersectionWithin67m" (gid serial, geom geometry(Geometry,27700));

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