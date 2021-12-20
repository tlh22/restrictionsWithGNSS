/*
To create stress maps, steps are:
1.	Generate a .csv with the relevant street names, survey ids and stress values
    a.	Copy the table from the results sheet
    b.	Change the column titles of the Stress results to match the survey id (1-…)
    c.	Then unpivot the table
        i.	Data -> From table/range
        ii.	This then opens the Power query editor
        iii.	Select the Roads/GeometryID column
        iv.	Right click in the column header and choose “unpivot other columns”
        v.	Close and Load
    d.	Change the name of the “Attribute” column to “SurveyID”
    e.	Save as .csv

2. Prepare table with script below and load csv
NB: There maybe an issue reading the file, in which case, put it into the user/public folder
-- https://www.neilwithdata.com/copy-permission-denied#:~:text=The%20most%20common%20reason%20permission,the%20server%2C%20not%20the%20client.&text=It%20therefore%20can't%20read,your%20own%20personal%20home%20directory.

3. 


*/

DROP TABLE IF EXISTS demand.demand_results CASCADE;

CREATE TABLE demand.demand_results
(
    id SERIAL,
    "RoadName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "SurveyID" integer NOT NULL,
    "Value" float,
    CONSTRAINT "demand_results_unique_key" UNIQUE ("RoadName", "SurveyID")
)
TABLESPACE pg_default;

ALTER TABLE demand.demand_results
    OWNER to postgres;

DROP TABLE IF EXISTS demand.demand_results_tmp CASCADE;

CREATE TABLE demand.demand_results_tmp
(
    id SERIAL,
    "RoadName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "SurveyID" character varying(250) COLLATE pg_catalog."default",
    "Value" character varying(250) COLLATE pg_catalog."default"
)
TABLESPACE pg_default;

ALTER TABLE demand.demand_results_tmp
    OWNER to postgres;

-- Now copy details into the tmp table

COPY demand.demand_results_tmp("RoadName", "SurveyID", "Value")
FROM 'C:\Users\Public\Documents\PC2108_StressResults.csv'
DELIMITER ','
CSV HEADER;

CREATE OR REPLACE FUNCTION convert_to_float(v_input text)
RETURNS FLOAT AS $$
DECLARE v_float_value FLOAT DEFAULT 0.0;
BEGIN
    BEGIN
        v_float_value := v_input::FLOAT;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', v_input;
        RETURN 0;
    END;
RETURN v_float_value;
END;
$$ LANGUAGE plpgsql;

-- Move to main table

INSERT INTO demand.demand_results ("RoadName", "SurveyID", "Value")
SELECT "RoadName", "SurveyID"::integer, convert_to_float("Value")
FROM demand.demand_results_tmp
WHERE "SurveyID" ~ E'^\\d+$'
;

-- https://stackoverflow.com/questions/2082686/how-do-i-cast-a-string-to-integer-and-have-0-in-case-of-error-in-the-cast-with-p

DROP TABLE IF EXISTS demand.demand_results_tmp CASCADE;

-- Create view

-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    d.id,
    s."name1" AS "RoadName", s.geom,
    d."SurveyID", d."Value" AS "Stress"
	FROM highways_network."roadlink" s, demand.demand_results d
	WHERE s."name1" = d."RoadName"
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";
