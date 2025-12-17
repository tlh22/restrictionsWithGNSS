/***

Identify all the issues for a restriction in Supply

and then link the restriction back to the original Bay/Line details

***/

SELECT RiS1."SurveyID", RiS1."GeometryID", "SuspensionNotes", 
FROM 
	(
	SELECT RiS."SurveyID", RiS."GeometryID", c."Notes"
	FROM "demand"."RestrictionsInSurveys" AS RiS, demand."Counts" c
	WHERE RiS."SurveyID" = c."SurveyID"
	AND RiS.2GeometryID" = c."GeometryID"
	AND LENGTH (c."Notes") > 0
	) a1, 
	(
	SELECT RiS."SurveyID", RiS."GeometryID", c."Notes"
	FROM "demand"."RestrictionsInSurveys" AS RiS, demand."Counts" c
	WHERE RiS."SurveyID" = c."SurveyID"
	AND RiS.2GeometryID" = c."GeometryID"
	AND LENGTH (c."Notes") > 0
	) a2
WHERE a1."GeometryID" = a2."GeometryID"
AND a1."SurveyID" < a2."SurveyID"

"demand"."RestrictionsInSurveys" AS RiS2

UPDATE mhtc_operations."Restrictions_Audit_Issues" AS a
			SET "Reason" = CONCAT (duplicate_restriction."Reason1", '; ', duplicate_restriction."Reason2")
			WHERE a.gid = duplicate_restriction.gid1;

--

DROP TABLE IF EXISTS demand."DemandNotes" CASCADE;
DROP SEQUENCE IF EXISTS demand."DemandNotes_id_seq";

CREATE SEQUENCE IF NOT EXISTS demand."DemandNotes_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE demand."DemandNotes_id_seq"
    OWNER TO postgres;
	
CREATE TABLE IF NOT EXISTS demand."DemandNotes"
(
    id integer NOT NULL DEFAULT nextval('demand."DemandNotes_id_seq"'::regclass),
	"GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
	"AllDemandNotes" character varying(10000) COLLATE pg_catalog."default",
	geom geometry(LineString, 27700),
    CONSTRAINT "SiteArea_Single_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."DemandNotes"
    OWNER to postgres;


DO $$
DECLARE
	this_restriction RECORD;
	demand_note RECORD;
	curr_geometry_id TEXT;
	demand_note_text TEXT;
	i_count integer = 0;
	
BEGIN

	FOR this_restriction IN 
		SELECT "GeometryID", geom
		FROM mhtc_operations."Supply"
		
	LOOP

		--RAISE NOTICE 'Considering: %', this_restriction."GeometryID";
		i_count = 0;
		
		FOR demand_note IN
			SELECT RiS."SurveyID", RiS."GeometryID", c."Notes"
			FROM "demand"."RestrictionsInSurveys" AS RiS, demand."Counts" c
			WHERE RiS."SurveyID" = c."SurveyID"
			AND RiS."GeometryID" = c."GeometryID"
			AND RiS."GeometryID" = this_restriction."GeometryID"
			AND LENGTH (c."Notes") > 0
			ORDER BY RiS."GeometryID", RiS."SurveyID" ASC

		LOOP
		
			demand_note_text = CONCAT(demand_note."SurveyID", ': ', demand_note."Notes");
			i_count = i_count + 1;
			
		END LOOP;
		
		IF i_count > 0 THEN 
			RAISE NOTICE 'demand notes (%): %: %', this_restriction."GeometryID", i_count, demand_note_text;
			
			INSERT INTO demand."DemandNotes" ("GeometryID", "AllDemandNotes", geom)
			VALUES (this_restriction."GeometryID", demand_note_text, this_restriction.geom);
			
		END IF;
			
	END LOOP;
	
	--RAISE NOTICE 'i_count: %', i_count;

END; $$;