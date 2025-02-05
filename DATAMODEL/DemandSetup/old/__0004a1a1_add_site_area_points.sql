/****

Identify break points within restrictions where they are crossed by site area. Ignore when close to node or existing corner/section break (within 0.1m).

Steps:
1. Create table for points
2. Generate points using intersection
3. Check that they are not close to existing points
4. Break restrictions

***/

-- set up points table

DROP TABLE IF EXISTS mhtc_operations."SiteArea_BreakPoints_Single" CASCADE;

CREATE TABLE mhtc_operations."SiteArea_BreakPoints_Single"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "SiteArea_BreakPoints_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."SiteArea_BreakPoints_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."SiteArea_BreakPoints_Single" TO postgres;

-- Index: public."sidx_SiteArea_BreakPoints_Single_geom"

-- DROP INDEX public."sidx_SiteArea_BreakPoints_Single_geom";

CREATE INDEX "sidx_SiteArea_BreakPoints_Single_geom"
  ON mhtc_operations."SiteArea_BreakPoints_Single"
  USING gist
  (geom);

-- add intersection points

INSERT INTO mhtc_operations."SiteArea_BreakPoints_Single" (geom)
SELECT geom
FROM (

	SELECT (ST_DumpPoints(ST_Intersection(s.geom, ST_Boundary(a.geom)))).*
	FROM mhtc_operations."Supply" s, local_authority."SiteArea" a
	WHERE ST_Intersects(s.geom, a.geom)

	) j;

-- remove any that are close to the nodes of the supply features

DELETE FROM mhtc_operations."SiteArea_BreakPoints_Single" b
USING mhtc_operations."Supply" s
WHERE ST_DWithin(ST_StartPoint(s.geom), b.geom, 0.25);

DELETE FROM mhtc_operations."SiteArea_BreakPoints_Single" b
USING mhtc_operations."Supply" s
WHERE ST_DWithin(ST_EndPoint(s.geom), b.geom, 0.25);

DELETE FROM mhtc_operations."SiteArea_BreakPoints_Single" b
USING mhtc_operations."Corners_Single" s
WHERE ST_DWithin(s.geom, b.geom, 0.25);

-- can now add to existing points  prior to break

INSERT INTO mhtc_operations."Corners_Single" (geom)
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."SiteArea_BreakPoints_Single";