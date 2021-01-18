-- set up a map across the whole area to deal with labels

INSERT INTO toms."MapGrid" (geom)
SELECT ST_Buffer(s.geom, 100.0)
FROM local_authority."SiteArea" s;

