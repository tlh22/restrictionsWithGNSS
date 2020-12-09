--	Merge sections that are broken
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
FROM (SELECT DISTINCT ON (s."gid") s."gid" AS id, cl."name1" AS "RoadName", ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom, ST_Distance(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, cl."RoadFrom", cl."RoadTo"
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

--

CREATE OR REPLACE FUNCTION "mhtc_operations".set_section_length()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
    BEGIN
	    -- round to two decimal places
        NEW."SectionLength" := ROUND(public.ST_Length (NEW."geom")::numeric,2);

        RETURN NEW;
    END;
$BODY$;

ALTER FUNCTION "mhtc_operations".set_section_length()
    OWNER TO postgres;

ALTER TABLE "mhtc_operations"."RC_Sections_merged"
    ADD COLUMN "SectionLength" double precision;

CREATE TRIGGER "set_section_length"
    BEFORE INSERT OR UPDATE
    ON "mhtc_operations"."RC_Sections_merged"
    FOR EACH ROW
    EXECUTE PROCEDURE "mhtc_operations".set_section_length();

-- trigger trigger
UPDATE "mhtc_operations"."RC_Sections_merged" SET "SectionLength" = "SectionLength";
ALTER TABLE "mhtc_operations"."RC_Sections_merged" ALTER COLUMN "SectionLength" SET NOT NULL;

ALTER TABLE "mhtc_operations"."RC_Sections_merged"
    ADD COLUMN "Photos_01" character varying(255);
ALTER TABLE "mhtc_operations"."RC_Sections_merged"
    ADD COLUMN "Photos_02" character varying(255);
ALTER TABLE "mhtc_operations"."RC_Sections_merged"
    ADD COLUMN "Photos_03" character varying(255);