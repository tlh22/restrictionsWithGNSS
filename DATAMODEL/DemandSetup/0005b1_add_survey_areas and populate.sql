--

DROP TABLE IF EXISTS "mhtc_operations"."SurveyAreas" CASCADE;

DROP SEQUENCE IF EXISTS mhtc_operations."SurveyAreas_id_seq";

CREATE SEQUENCE mhtc_operations."SurveyAreas_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE mhtc_operations."SurveyAreas_id_seq"
    OWNER TO postgres;

CREATE TABLE mhtc_operations."SurveyAreas"
(
    "Code" integer NOT NULL DEFAULT nextval('mhtc_operations."SurveyAreas_id_seq"'::regclass),
    "SurveyAreaName" character varying(32) COLLATE pg_catalog."default",
    geom geometry(Polygon,27700),
    CONSTRAINT "SurveyAreas_pkey" PRIMARY KEY ("Code")
);

ALTER TABLE "mhtc_operations"."SurveyAreas" OWNER TO "postgres";

GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "mhtc_operations"."SurveyAreas" TO toms_operator, toms_admin;

/***
ALTER TABLE IF EXISTS mhtc_operations."SurveyAreas"
    RENAME id TO "Code";

ALTER TABLE IF EXISTS mhtc_operations."SurveyAreas"
    RENAME name TO "SurveyAreaName";
***/

-- Add to Supply

ALTER TABLE IF EXISTS mhtc_operations."Supply"
  ADD COLUMN IF NOT EXISTS "SurveyAreaID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "SurveyAreaID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SurveyAreaID" IS NULL;

/***
-- Calculate length/capacity within area

SELECT a."SurveyAreaName", SUM(s."RestrictionLength") AS "RestrictionLength", SUM("Capacity") AS "Total Capacity",
SUM (CASE WHEN "RestrictionTypeID" > 200 THEN 0 ELSE s."Capacity" END) AS "Bay Capacity"
FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE a."Code" = s."SurveyAreaID"
--AND a."SurveyAreaName" LIKE 'V%'
GROUP BY a."SurveyAreaName"
ORDER BY a."SurveyAreaName";

***/

-- Add to RC_Sections_merged

ALTER TABLE IF EXISTS mhtc_operations."RC_Sections_merged"
  ADD COLUMN IF NOT EXISTS "SurveyAreaID" INTEGER;

UPDATE mhtc_operations."RC_Sections_merged"
SET "SurveyAreaID" = NULL;

UPDATE "mhtc_operations"."RC_Sections_merged" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."RC_Sections_merged" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SurveyAreaID" IS NULL;

/***
-- Calculate length of section within area

SELECT a."SurveyAreaName", SUM(s."SectionLength")
FROM mhtc_operations."RC_Sections_merged" s, mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom)
GROUP BY a."SurveyAreaName"
ORDER BY a."SurveyAreaName";

***/