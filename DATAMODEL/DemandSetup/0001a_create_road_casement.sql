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

/***
DROP TABLE IF EXISTS "topography"."RC_Polygons" CASCADE;

CREATE TABLE "topography"."RC_Polygons"
(
    geom geometry,
    id SERIAL,
    CONSTRAINT "rc_polygons_pkey" PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE "topography"."RC_Polygons"
    OWNER to postgres;

INSERT INTO "topography"."RC_Polygons" (geom)
SELECT geom FROM "topography"."TopographicArea"
WHERE "featurecod" = 10172;

-- can add additional polys here

CREATE TABLE "topography"."RC_Polygons_single"
(
    geom geometry,
    id SERIAL,
    CONSTRAINT "rc_polygons_single_pkey" PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE "topography"."RC_Polygons"
    OWNER to postgres;

INSERT INTO "topography"."RC_Polygons_single" (geom)
SELECT ST_Union(geom) FROM "topography"."RC_Polygons"
WHERE "featureCode" = 10172;
***/