
-- Create new table

DROP TABLE IF EXISTS mhtc_operations."SurveyAreas_Single" CASCADE;
DROP SEQUENCE IF EXISTS mhtc_operations."SurveyAreas_Single_id_seq";

CREATE SEQUENCE IF NOT EXISTS mhtc_operations."SurveyAreas_Single_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE mhtc_operations."SurveyAreas_Single_id_seq"
    OWNER TO postgres;
	
CREATE TABLE IF NOT EXISTS mhtc_operations."SurveyAreas_Single"
(
    "Code" integer NOT NULL DEFAULT nextval('mhtc_operations."SurveyAreas_Single_id_seq"'::regclass),
    "SurveyAreaName" character varying(32) COLLATE pg_catalog."default",
    geom geometry(Polygon,27700),
    CONSTRAINT "SurveyAreas_Single_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS mhtc_operations."SurveyAreas_Single"
    OWNER to postgres;
-- Index: sidx_SurveyAreas_geom

DROP INDEX IF EXISTS mhtc_operations."sidx_SurveyAreas_Single_geom";

CREATE INDEX IF NOT EXISTS "sidx_SurveyAreas_Single_geom"
    ON mhtc_operations."SurveyAreas_Single" USING gist
    (geom)
    TABLESPACE pg_default;

-- Populate

INSERT INTO mhtc_operations."SurveyAreas_Single"(
	geom)
	SELECT (ST_DUMP(geom)).geom::geometry(Polygon,27700) AS geom FROM mhtc_operations."SurveyAreas";

-- Rename

DROP TABLE mhtc_operations."SurveyAreas" CASCADE;
DROP SEQUENCE IF EXISTS mhtc_operations."SurveyAreas_id_seq";

ALTER TABLE mhtc_operations."SurveyAreas_Single" RENAME TO "SurveyAreas";
ALTER SEQUENCE mhtc_operations."SurveyAreas_Single_id_seq" RENAME TO "SurveyAreas_id_seq";
ALTER INDEX mhtc_operations."sidx_SurveyAreas_Single_geom" RENAME TO "sidx_SurveyAreas_geom";



