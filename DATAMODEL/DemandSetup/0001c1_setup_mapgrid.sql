-- set up a map across the whole area to deal with labels

DELETE FROM toms."MapGrid";

INSERT INTO toms."MapGrid" (id, geom)
SELECT 1, ST_Multi(ST_Union(ST_Buffer(geom, 100.0))) AS geom
FROM local_authority."SiteArea" s;

