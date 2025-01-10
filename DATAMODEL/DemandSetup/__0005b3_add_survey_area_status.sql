/***
Add status
***/

DROP TABLE IF EXISTS "demand_lookups"."MHTC_SurveyAreaCheckStatus" CASCADE;

DROP SEQUENCE IF EXISTS demand_lookups."MHTC_SurveyAreaCheckStatus_id_seq";

CREATE SEQUENCE demand_lookups."MHTC_SurveyAreaCheckStatus_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE demand_lookups."MHTC_SurveyAreaCheckStatus_id_seq"
    OWNER TO postgres;
	
CREATE TABLE IF NOT EXISTS demand_lookups."MHTC_SurveyAreaCheckStatus"
(
    "Code" integer NOT NULL DEFAULT nextval('demand_lookups."MHTC_SurveyAreaCheckStatus_id_seq"'::regclass),
    "Description" character varying COLLATE pg_catalog."default",
    CONSTRAINT "MHTC_SurveyAreaCheckStatus_pkey" PRIMARY KEY ("Code")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand_lookups."MHTC_SurveyAreaCheckStatus"
    OWNER to postgres;

REVOKE ALL ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" FROM toms_admin;
REVOKE ALL ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" FROM toms_operator;
REVOKE ALL ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" FROM toms_public;

GRANT ALL ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" TO postgres;

GRANT DELETE, INSERT, UPDATE, SELECT ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" TO toms_admin;

GRANT SELECT ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" TO toms_operator;

GRANT SELECT ON TABLE demand_lookups."MHTC_SurveyAreaCheckStatus" TO toms_public;


INSERT INTO "demand_lookups"."MHTC_SurveyAreaCheckStatus" ("Code", "Description") VALUES (0, 'Complete');
INSERT INTO "demand_lookups"."MHTC_SurveyAreaCheckStatus" ("Code", "Description") VALUES (1, 'Few queries');
INSERT INTO "demand_lookups"."MHTC_SurveyAreaCheckStatus" ("Code", "Description") VALUES (2, 'around 75% complete');
INSERT INTO "demand_lookups"."MHTC_SurveyAreaCheckStatus" ("Code", "Description") VALUES (3, 'around 50% complete');

-- 

DROP TABLE IF EXISTS "demand"."SurveyAreaStatus" CASCADE;

DROP SEQUENCE IF EXISTS demand."SurveyAreaStatus_id_seq";

CREATE SEQUENCE demand."SurveyAreaStatus_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE demand."SurveyAreaStatus_id_seq"
    OWNER TO postgres;
	
CREATE TABLE IF NOT EXISTS demand."SurveyAreaStatus"
(
    "id" integer NOT NULL DEFAULT nextval('demand."SurveyAreaStatus_id_seq"'::regclass),
	"SurveyID" INTEGER,
	"SurveyAreaID" INTEGER,
	geom geometry(Polygon,27700),
	"MHTC_SurveyAreaCheckStatusID" INTEGER,
    CONSTRAINT "SurveyAreaStatus_pkey" PRIMARY KEY ("id")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."SurveyAreaStatus"
    OWNER to postgres;

REVOKE ALL ON TABLE demand."SurveyAreaStatus" FROM toms_admin;
REVOKE ALL ON TABLE demand."SurveyAreaStatus" FROM toms_operator;
REVOKE ALL ON TABLE demand."SurveyAreaStatus" FROM toms_public;

GRANT ALL ON TABLE demand."SurveyAreaStatus" TO postgres;

GRANT DELETE, INSERT, UPDATE, SELECT ON TABLE demand."SurveyAreaStatus" TO toms_admin;

GRANT SELECT ON TABLE demand."SurveyAreaStatus" TO toms_operator;

GRANT SELECT ON TABLE demand."SurveyAreaStatus" TO toms_public;

INSERT INTO demand."SurveyAreaStatus" ("SurveyID", "SurveyAreaID", geom)
SELECT "SurveyID", "Code", r.geom As geom
FROM mhtc_operations."SurveyAreas" r, demand."Surveys"
ORDER BY "SurveyID", "Code";

/***

Try to assign status based on number of bays completed in an area:

***/

SELECT ss."SurveyAreaID", sa."SurveyAreaName", ss."SurveyID"
FROM demand."SurveyAreaStatus" ss, mhtc_operations."SurveyAreas" sa, demand."RestrictionsInSurveys" ris
WHERE ss."SurveyAreaID" = sa."Code"
AND ris."SurveyID" = 
ORDER BY sa."SurveyAreaName", ss."SurveyID"


SELECT ss."SurveyAreaID", sa."SurveyAreaName", COUNT(s."RestrictionTypeID")
FROM demand."SurveyAreaStatus" ss, mhtc_operations."SurveyAreas" sa, demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
WHERE ris."GeometryID" = s."GeometryID"
AND ss."SurveyID" = ris."SurveyID"
AND ss."SurveyAreaID" = sa."Code"
AND s."SurveyAreaID" = sa."Code"
AND  (ris."Done" =  'false' OR ris."Done" IS NULL) 
AND s."RestrictionTypeID" IN (101,	103, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 124, 128, 130, 160, 163, 164, 165, 166, 167, 168, 169, 170)
AND "SurveyID" > 0
GROUP BY sa."SurveyAreaName"
ORDER BY sa."SurveyAreaName"

-- clear all values
UPDATE demand."SurveyAreaStatus"
SET "MHTC_SurveyAreaCheckStatusID" = NULL;

-- calculate status
DO
$do$
DECLARE
   row RECORD;
   survey_details RECORD;
BEGIN
    FOR row IN SELECT a."SurveyAreaID", a."SurveyAreaName", "Total_Count" FROM
				(SELECT ss."SurveyAreaID", sa."SurveyAreaName", COUNT(s."RestrictionTypeID") AS "Total_Count"
				FROM demand."SurveyAreaStatus" ss, mhtc_operations."SurveyAreas" sa, demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
				WHERE ris."GeometryID" = s."GeometryID"
				AND ss."SurveyID" = ris."SurveyID"
				AND ss."SurveyAreaID" = sa."Code"
				AND s."SurveyAreaID" = sa."Code"
				--AND  (ris."Done" =  'false' OR ris."Done" IS NULL) 
				AND s."RestrictionTypeID" IN (101,	103, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 124, 128, 130, 160, 163, 164, 165, 166, 167, 168, 169, 170)
				AND ss."SurveyID" = 0
				GROUP BY ss."SurveyAreaID", sa."SurveyAreaName"
				ORDER BY sa."SurveyAreaName") a
    LOOP
	
		RAISE NOTICE '***** Considering: SurveyArea(%) with % bays', row."SurveyAreaName", row."Total_Count";
		
		FOR survey_details IN
			SELECT "SurveyID", "Done_Count" FROM (
			SELECT ss."SurveyID", COUNT(s."RestrictionTypeID") AS "Done_Count"
			FROM demand."SurveyAreaStatus" ss, mhtc_operations."SurveyAreas" sa, demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
			WHERE ris."GeometryID" = s."GeometryID"
			AND ss."SurveyID" = ris."SurveyID"
			AND ss."SurveyAreaID" = sa."Code"
			AND s."SurveyAreaID" = sa."Code"
			AND  (ris."Done" =  'true') 
			AND s."RestrictionTypeID" IN (101,	103, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 124, 128, 130, 160, 163, 164, 165, 166, 167, 168, 169, 170)
			AND ss."SurveyID" > 0
			AND ss."SurveyAreaID" = row."SurveyAreaID"
			GROUP BY ss."SurveyID"
			) b
		LOOP
				
			UPDATE demand."SurveyAreaStatus" AS ss
			SET "MHTC_SurveyAreaCheckStatusID" =
				CASE 
					WHEN survey_details."Done_Count" = row."Total_Count" THEN 0
					WHEN survey_details."Done_Count"::float/row."Total_Count"::float > 0.9 THEN 1
					WHEN survey_details."Done_Count"::float/row."Total_Count"::float > 0.75 THEN 2
					WHEN survey_details."Done_Count"::float/row."Total_Count"::float > 0.5 THEN 3
					WHEN survey_details."Done_Count" > 0 THEN 3
				END
			WHERE ss."SurveyAreaID" = row."SurveyAreaID"
			AND ss."SurveyID" = survey_details."SurveyID";
							
			RAISE NOTICE '***** SurveyID(%) Done: %', survey_details."SurveyID", survey_details."Done_Count";
			
		END LOOP;		

    END LOOP;
END
$do$;