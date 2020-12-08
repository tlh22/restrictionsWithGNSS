
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

--9.	Merge sections that are broken
DROP TABLE IF EXISTS "mhtc_operations"."RC_Sections_merged" CASCADE;

CREATE TABLE "mhtc_operations"."RC_Sections_merged"
(
  gid SERIAL,
  geom geometry(LineString,27700),
  "RoadName" character varying(100),
  "Az" double precision,
  "StartStreet" character varying(254),
  "EndStreet" character varying(254),
  "SideOfStreet" character varying(100),
  CONSTRAINT "RC_Sections_merged_pkey" PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "mhtc_operations"."RC_Sections_merged"
  OWNER TO postgres;

-- Index: public."sidx_RC_Sections_merged_geom"

-- DROP INDEX public."sidx_RC_Sections_merged_geom";

CREATE INDEX "sidx_RC_Sections_merged_geom"
  ON "mhtc_operations"."RC_Sections_merged"
  USING gist
  (geom);

INSERT INTO "mhtc_operations"."RC_Sections_merged" (geom)
SELECT (ST_Dump(ST_LineMerge(ST_Collect(a.geom)))).geom As geom

FROM "mhtc_operations"."RC_Sections" as a
LEFT JOIN "mhtc_operations"."RC_Sections" as b ON
ST_Touches(a.geom,b.geom)
GROUP BY ST_Touches(a.geom,b.geom);


UPDATE "mhtc_operations"."RC_Sections_merged" AS c
SET "RoadName" = closest."RoadName", "Az" = ST_Azimuth(ST_LineInterpolatePoint(c.geom, 0.5), closest.geom), "StartStreet" = closest."RoadFrom", "EndStreet" = closest."RoadTo"
FROM (SELECT DISTINCT ON (s."gid") s."gid" AS id, cl."name1" AS "RoadName", ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
                                   ST_Distance(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, cl."RoadFrom", cl."RoadTo"
      FROM "highways_network"."roadlink" cl, "mhtc_operations"."RC_Sections_merged" s
      ORDER BY s."gid", length) AS closest
WHERE c."gid" = closest.id;


UPDATE "mhtc_operations"."RC_Sections_merged"
SET "SideOfStreet" = 'North'
WHERE degrees("Az") > 135.0
AND degrees("Az") <= 225.0;

UPDATE "mhtc_operations"."RC_Sections_merged"
SET "SideOfStreet" = 'South'
WHERE degrees("Az") > 315.0
OR  degrees("Az") <= 45.0;

UPDATE "mhtc_operations"."RC_Sections_merged"
SET "SideOfStreet" = 'East'
WHERE degrees("Az") > 225.0
AND degrees("Az") <= 315.0;

UPDATE "mhtc_operations"."RC_Sections_merged"
SET "SideOfStreet" = 'West'
WHERE degrees("Az") > 45.0
AND degrees("Az") <= 135.0;

