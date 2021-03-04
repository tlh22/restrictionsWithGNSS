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




