-- survey areas
--DROP TABLE IF EXISTS mhtc_operations."SurveyAreas";
CREATE TABLE mhtc_operations."SurveyAreas"
(
    id SERIAL,
    name character varying(32) COLLATE pg_catalog."default",
    geom geometry(MultiPolygon,27700),
    CONSTRAINT "SurveyAreas_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."SurveyAreas"
    OWNER to postgres;

ALTER TABLE "mhtc_operations"."RC_Sections_merged"
    ADD COLUMN "SurveyArea" integer;

UPDATE "mhtc_operations"."RC_Sections_merged" AS s
SET "SurveyArea" = a.id
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

--
-- Calculate length of section within area

SELECT a.name, SUM(s."SectionLength")
FROM mhtc_operations."RC_Sections_merged" s, mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom)
GROUP BY a.name;

SELECT a.name, SUM(s."SectionLength")
FROM mhtc_operations."RC_Sections_merged" s, mhtc_operations."SurveyAreas" a
WHERE a.id = s."SurveyArea"
GROUP BY a.name;
