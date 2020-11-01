
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "SurveyArea" character varying(254);

UPDATE "mhtc_operations"."Supply" AS su
SET "SurveyArea" = a."sitename"
FROM local_authority."SiteArea" a
WHERE ST_Intersects(su.geom, a.geom);

ALTER TABLE mhtc_operations."RC_Sections_merged"
  ADD COLUMN "SurveyArea" character varying(254);

UPDATE "mhtc_operations"."RC_Sections_merged" AS se
SET "SurveyArea" = a."sitename"
FROM local_authority."SiteArea" a
WHERE ST_Intersects(se.geom, a.geom);



