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
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "SurveyID" integer NOT NULL,
    "Value" float,
    CONSTRAINT "demand_results_unique_key" UNIQUE ("GeometryID", "SurveyID")
)
TABLESPACE pg_default;

ALTER TABLE demand.demand_results
    OWNER to postgres;

DROP TABLE IF EXISTS demand.demand_results_tmp CASCADE;

CREATE TABLE demand.demand_results_tmp
(
    id SERIAL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "SurveyID" character varying(250) COLLATE pg_catalog."default",
    "Value" character varying(250) COLLATE pg_catalog."default"
)
TABLESPACE pg_default;

ALTER TABLE demand.demand_results
    OWNER to postgres;

-- Now copy details into the tmp table

COPY demand.demand_results_tmp("GeometryID", "SurveyID", "Value")
FROM 'C:\Users\Public\Documents\FP_DemandResults.csv'
DELIMITER ','
CSV HEADER;

-- Move to main table

INSERT INTO demand.demand_results ("GeometryID", "SurveyID", "Value")
SELECT "GeometryID", "SurveyID"::integer, "Value"::float
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
        -- row_number() OVER (PARTITION BY true::boolean) AS id,
    d.id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."NrBays", s."Capacity",
    d."SurveyID", d."Value",
    CASE WHEN s."Capacity" = 0 THEN '-'
         ELSE TO_CHAR(d."Value"::float/s."Capacity"::float, '9D99')
    END AS "Stress"
	FROM mhtc_operations."Supply" s, demand.demand_results d
	WHERE d."GeometryID" = s."GeometryID"
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_id"
    ON demand."StressResults" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";
