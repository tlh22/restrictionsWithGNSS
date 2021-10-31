
DROP TABLE IF EXISTS "RC_Sections" CASCADE;
DROP TABLE IF EXISTS "mhtc_operations"."RC_Sections" CASCADE;

CREATE TABLE "mhtc_operations"."RC_Sections"
(
  gid SERIAL,
  geom geometry(LineString,27700),
  "RoadName" character varying(100),
  "Az" double precision,
  "StartStreet" character varying(254),
  "EndStreet" character varying(254),
  "SideOfStreet" character varying(100),
  CONSTRAINT "RC_Sections_pkey" PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "mhtc_operations"."RC_Sections"
  OWNER TO postgres;

-- Index: public."sidx_RC_Sections_geom"

-- DROP INDEX public."sidx_RC_Sections_geom";

CREATE INDEX "sidx_RC_Sections_geom"
  ON "mhtc_operations"."RC_Sections"
  USING gist
  (geom);

-- This involves splitting the road casement at the corners. The query is:

INSERT INTO "mhtc_operations"."RC_Sections" (geom)
SELECT (ST_Dump(ST_Split(rc.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "topography"."road_casement" rc, (SELECT ST_Union(ST_Snap(cnr.geom, rc.geom, 0.00000001)) AS geom
									  FROM "topography"."road_casement" rc,
									  (SELECT geom
									  FROM "mhtc_operations"."Corners"
									  union
									  SELECT geom
									  FROM "mhtc_operations"."SectionBreakPoints") cnr) c
WHERE ST_DWithin(rc.geom, c.geom, 0.25);

DELETE FROM "mhtc_operations"."RC_Sections"
WHERE ST_Length(geom) < 0.0001;

GRANT SELECT ON TABLE "mhtc_operations"."RC_Sections" TO toms_admin, toms_operator;