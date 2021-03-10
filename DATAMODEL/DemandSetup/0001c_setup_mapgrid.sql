-- set up a map across the whole area to deal with labels

INSERT INTO toms."MapGrid" (id, geom)
SELECT id, ST_Multi(ST_Buffer(geom, 100.0)) AS geom
FROM local_authority."SiteArea" s;

