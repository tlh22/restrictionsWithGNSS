-- create road casement

INSERT INTO "RC_Polyline" (geom)
SELECT (ST_Dump(ST_Multi(ST_Boundary(ST_Union (c.geom))))).geom AS geom
FROM (SELECT geom FROM "topography"."os_mastermap_topography_polygons" WHERE "featurecode" = 10172) AS c

