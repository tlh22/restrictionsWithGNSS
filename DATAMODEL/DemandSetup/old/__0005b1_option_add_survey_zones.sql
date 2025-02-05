--

DROP TABLE IF EXISTS "mhtc_operations"."SurveyZones" CASCADE;

DROP SEQUENCE IF EXISTS mhtc_operations."SurveyZones_id_seq";

CREATE SEQUENCE mhtc_operations."SurveyZones_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE mhtc_operations."SurveyZones_id_seq"
    OWNER TO postgres;

CREATE TABLE mhtc_operations."SurveyZones"
(
    "Code" integer NOT NULL DEFAULT nextval('mhtc_operations."SurveyAreas_id_seq"'::regclass),
    "SurveyZoneName" character varying(32) COLLATE pg_catalog."default",
	"SurveyType" character varying(32) COLLATE pg_catalog."default",
    geom geometry(MultiPolygon,27700),
    CONSTRAINT "SurveyZones_pkey" PRIMARY KEY ("Code")
);

ALTER TABLE "mhtc_operations"."SurveyZones" OWNER TO "postgres";

GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "mhtc_operations"."SurveyZones" TO toms_operator, toms_admin;

/***
ALTER TABLE IF EXISTS mhtc_operations."SurveyAreas"
    RENAME id TO "Code";

ALTER TABLE IF EXISTS mhtc_operations."SurveyAreas"
    RENAME name TO "SurveyAreaName";
***/

-- Add to Supply

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "SurveyZoneID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "SurveyZoneID" = NULL;

/***
UPDATE "mhtc_operations"."Supply" AS s
SET "SurveyZoneID" = a."Code"
FROM mhtc_operations."SurveyZones" a
WHERE ST_WITHIN (s.geom, a.geom);

SELECT a."SurveyZoneName", SUM(s."RestrictionLength") AS "RestrictionLength", SUM("Capacity") AS "Total Capacity",
SUM (CASE WHEN "RestrictionTypeID" > 200 THEN 0 ELSE s."Capacity" END) AS "Bay Capacity"
FROM mhtc_operations."Supply" s, mhtc_operations."SurveyZones" a
WHERE a."Code" = s."SurveyZoneID"
--AND a."SurveyAreaName" LIKE 'V%'
GROUP BY a."SurveyZoneName"
ORDER BY a."SurveyZoneName";

***/

/***

-- Create new table

DROP TABLE IF EXISTS mhtc_operations."SurveyZones_Single" CASCADE;
DROP SEQUENCE IF EXISTS mhtc_operations."SurveyZones_Single_id_seq";

CREATE SEQUENCE IF NOT EXISTS mhtc_operations."SurveyZones_Single_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE mhtc_operations."SurveyZones_Single_id_seq"
    OWNER TO postgres;
	
CREATE TABLE IF NOT EXISTS mhtc_operations."SurveyZones_Single"
(
    "Code" integer NOT NULL DEFAULT nextval('mhtc_operations."SurveyAreas_id_seq"'::regclass),
    "SurveyZoneName" character varying(32) COLLATE pg_catalog."default",
	"SurveyType" character varying(32) COLLATE pg_catalog."default",
    geom geometry(MultiPolygon,27700),
    CONSTRAINT "SurveyZones_Single_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS mhtc_operations."SurveyZones_Single"
    OWNER to postgres;
-- Index: sidx_SurveyZones_geom

DROP INDEX IF EXISTS mhtc_operations."sidx_SurveyZones_Single_geom";

CREATE INDEX IF NOT EXISTS "sidx_SurveyZones_Single_geom"
    ON mhtc_operations."SurveyZones_Single" USING gist
    (geom)
    TABLESPACE pg_default;

-- Populate

INSERT INTO mhtc_operations."SurveyZones_Single"(
	geom)
	SELECT (ST_DUMP(geom)).geom::geometry(Polygon,27700) AS geom FROM mhtc_operations."SurveyZones";

-- Rename

DROP TABLE mhtc_operations."SurveyZones" CASCADE;
DROP SEQUENCE IF EXISTS mhtc_operations."SurveyZones_id_seq";

ALTER TABLE mhtc_operations."SurveyZones_Single" RENAME TO "SurveyZones";
ALTER SEQUENCE mhtc_operations."SurveyZones_Single_id_seq" RENAME TO "SurveyZones_id_seq";
ALTER INDEX mhtc_operations."sidx_SurveyZones_Single_geom" RENAME TO "sidx_SurveyZones_geom";


***/
