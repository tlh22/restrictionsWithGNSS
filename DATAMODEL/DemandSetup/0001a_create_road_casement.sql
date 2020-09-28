-- create road casement

INSERT INTO "RC_Polyline" (geom)
SELECT (ST_Dump(ST_Multi(ST_Boundary(ST_Union (c.geom))))).geom AS geom
FROM (SELECT geom FROM "topography"."os_mastermap_topography_polygons" WHERE "featureCode" = 10172) AS c

-- set up road names
ALTER TABLE "highways_network"."roadlink"
  ADD COLUMN "RoadFrom" character varying(100);
ALTER TABLE "highways_network"."roadlink"
  ADD COLUMN "RoadTo" character varying(100);

ALTER TABLE "highways_network"."roadlink"
ALTER COLUMN geom TYPE geometry(linestring, 27700) USING ST_GeometryN(geom, 1);

CREATE SEQUENCE "highways_network"."roadlink_id_seq"
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE "highways_network"."roadlink_id_seq"
  OWNER TO postgres;

ALTER TABLE "highways_network"."roadlink"
   ALTER COLUMN id SET DEFAULT nextval('"highways_network"."roadlink_id_seq"'::regclass);

UPDATE highways_network."roadlink" AS c1
SET "RoadFrom" = c2."name1", "RoadTo" = c3."name1"
FROM highways_network."roadlink" c2, highways_network."roadlink" c3
WHERE ((ST_Intersects (ST_EndPoint(c1.geom), ST_EndPoint(c2.geom)) OR ST_Intersects (ST_EndPoint(c1.geom), ST_StartPoint(c2.geom))) AND c2."name1" <> c1."name1")
AND ((ST_Intersects (ST_StartPoint(c1.geom), ST_EndPoint(c3.geom)) OR ST_Intersects (ST_startPoint(c1.geom), ST_StartPoint(c3.geom)))AND c3."name1" <> c1."name1");
