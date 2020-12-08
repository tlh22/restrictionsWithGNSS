-- create road casement
DROP TABLE IF EXISTS topography.road_casement CASCADE;

CREATE TABLE topography.road_casement
(
    geom geometry,
    id SERIAL,
    CONSTRAINT "road_casement_pkey" PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE topography.road_casement
    OWNER to postgres;

INSERT INTO "topography"."road_casement" (geom)
SELECT (ST_Dump(ST_Multi(ST_Boundary(ST_Union (c.geom))))).geom AS geom
FROM (SELECT geom FROM "topography"."os_mastermap_topography_polygons" WHERE "featureCode" = 10172) AS c;

