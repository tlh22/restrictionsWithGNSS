-- create road casement
-- may be required

UPDATE topography.os_mastermap_topography_polygons
   SET geom = ST_SnapToGrid(geom, 0.00001);

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

CREATE INDEX road_casement_geom_idx
  ON topography.road_casement
  USING GIST (geom);

INSERT INTO "topography"."road_casement" (geom)
SELECT (ST_Dump(ST_Multi(ST_Boundary(ST_Union (c.geom))))).geom AS geom
FROM (SELECT geom FROM "topography"."os_mastermap_topography_polygons" WHERE "FeatureCode" = 10172) AS c;

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
SELECT geom FROM "topography"."os_mastermap_topography_polygons"
WHERE "FeatureCode" = 10172;

-- now add additional polys here

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
FROM (SELECT geom FROM "topography"."RC_Polygons") AS c;

-- DROP INDEX IF EXISTS topography.sidx_road_casement_geom;

CREATE INDEX IF NOT EXISTS sidx_road_casement_geom
    ON topography.road_casement USING gist
    (geom)
    TABLESPACE pg_default;
	
***/