--

ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "SurveyArea" character varying(254);

UPDATE "mhtc_operations"."Supply" AS s
SET "SurveyArea" = a.id
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

ALTER TABLE mhtc_operations."RC_Sections_merged"
  ADD COLUMN "SurveyArea" character varying(254);


UPDATE "mhtc_operations"."RC_Sections_merged" AS s
SET "SurveyArea" = a.id
FROM local_authority."SiteArea" a
WHERE ST_WITHIN (s.geom, a.geom);


UPDATE "mhtc_operations"."RC_Sections_merged" AS s
SET "SurveyArea" = a.id
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

/***
 Plans for all survey areas for all survey times

DROP TABLE IF EXISTS mhtc_operations."SupplyPlansList";

CREATE TABLE mhtc_operations."SupplyPlansList" (
    id SERIAL,
    "SurveyID" integer NOT NULL,
	"SurveyDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "BeatStartTime" character varying (10) COLLATE pg_catalog."default",
    "BeatEndTime" character varying (10) COLLATE pg_catalog."default",
    "SurveyArea" character varying(32) COLLATE pg_catalog."default",
    geom geometry(MultiPolygon,27700),
    "SupplyPlanName" character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT "SupplyPlansList_pkey" PRIMARY KEY (id)
);

INSERT INTO mhtc_operations."SupplyPlansList" (
    "SurveyID", "SurveyDate", "BeatStartTime", "BeatEndTime", "SurveyArea", geom, "SupplyPlanName"
)
SELECT s."SurveyID", s."SurveyDate", s."BeatStartTime", s."BeatEndTime", sa."name", sa.geom, CONCAT('Area_', sa."name", '_', s."BeatTitle") AS "SurveyName"
	FROM demand."Surveys" s, mhtc_operations."SurveyAreas" sa
	ORDER BY "SurveyName";



