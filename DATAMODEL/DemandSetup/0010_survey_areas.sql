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
SET "SurveyArea" = NULL;

UPDATE "mhtc_operations"."RC_Sections_merged" AS s
SET "SurveyArea" = a.id
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

--
-- Calculate length of section within area

SELECT a.name, ROUND(SUM(ST_Length(s.geom))::numeric, 2)
FROM mhtc_operations."RC_Sections_merged" s, mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom)
GROUP BY a.name
ORDER BY a.name::int;

SELECT a.name, SUM(s."SectionLength")
FROM mhtc_operations."RC_Sections_merged" s, mhtc_operations."SurveyAreas" a
WHERE a.id = s."SurveyArea"
GROUP BY a.name
ORDER BY a.name;

UPDATE "mhtc_operations"."Supply" AS s
SET  "SurveyArea" = a."name"
FROM mhtc_operations."SurveyAreas" a
WHERE s."SurveyArea" = a.id

SELECT s."SurveyArea", ROUND(SUM(ST_Length(s.geom))::numeric, 2) AS "Length of Restrictions", ROUND(SUM("Capacity")) AS "Capacity"
FROM mhtc_operations."Supply" s
GROUP BY s."SurveyArea"
ORDER BY s."SurveyArea";


