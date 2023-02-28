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
    geom geometry(MultiPolygon,27700),
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

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "SurveyAreaID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "SurveyAreaID" = NULL;

