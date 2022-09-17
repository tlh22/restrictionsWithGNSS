/*
To create stress maps, steps are:

*/


-- Create view

-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByGeometryID";

CREATE MATERIALIZED VIEW demand."StressResults_ByGeometryID"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS id,

    s."GeometryID", s.geom, s."RestrictionTypeID", s."CapacityFromDemand" AS "Capacity", d."Demand",
    d."SurveyID", d."Stress"
	FROM mhtc_operations."Supply" s, demand."Counts" d
	WHERE d."GeometryID" = s."GeometryID"
	AND s."SurveyArea" IS NOT NULL
	AND LENGTH(s."RoadName") > 0
WITH DATA;

ALTER TABLE demand."StressResults_ByGeometryID"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByGeometryID_id"
    ON demand."StressResults_ByGeometryID" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByGeometryID";