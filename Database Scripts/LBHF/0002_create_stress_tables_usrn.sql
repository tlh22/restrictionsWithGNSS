DROP TABLE IF EXISTS  demand."MASTER_Demand_USRN" CASCADE;

CREATE TABLE demand."MASTER_Demand_USRN"
(
    id SERIAL,
    "SurveyID" integer,
    "USRN" double precision,
    "Capacity" double precision,
    "Demand" double precision,
    "Stress" double precision,
    "NrBaysSuspended" double precision,
    CONSTRAINT "MASTER_Demand_USRN_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE demand."MASTER_Demand_USRN"
    OWNER to postgres;


INSERT INTO demand."MASTER_Demand_USRN"(
	"SurveyID", "USRN", "Capacity", "Demand", "Stress", "NrBaysSuspended")
SELECT "SurveyID"::int, "USRN", SUM("Capacity"), SUM("Demand"),
    CASE WHEN SUM("Capacity") = 0 THEN
            CASE WHEN SUM("Demand") > 0.0 THEN 1.0
                ELSE 0.0
            END
        ELSE
            CASE
                WHEN SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0) > 0.0 THEN
                    SUM("Demand") / (SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0))
                ELSE
                    CASE
                        WHEN SUM("Demand") > 0.0 THEN 1.0
                        ELSE 0.0
                    END
            END
    END
    , SUM("sbays"::float)
FROM demand."MASTER_Demand_01_Weekday_Weekday_Overnight"
GROUP BY "SurveyID", "USRN";

INSERT INTO demand."MASTER_Demand_USRN"(
	"SurveyID", "USRN", "Capacity", "Demand", "Stress", "NrBaysSuspended")
SELECT "SurveyID"::int, "USRN", SUM("Capacity"), SUM("Demand"),
    CASE WHEN SUM("Capacity") = 0 THEN
            CASE WHEN SUM("Demand") > 0.0 THEN 1.0
                ELSE 0.0
            END
        ELSE
            CASE
                WHEN SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0) > 0.0 THEN
                    SUM("Demand") / (SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0))
                ELSE
                    CASE
                        WHEN SUM("Demand") > 0.0 THEN 1.0
                        ELSE 0.0
                    END
            END
    END
    , SUM("sbays"::float)

FROM demand."MASTER_Demand_02_Weekday_Weekday_Afternoon"
GROUP BY "SurveyID", "USRN";

INSERT INTO demand."MASTER_Demand_USRN"(
	"SurveyID", "USRN", "Capacity", "Demand", "Stress", "NrBaysSuspended")
SELECT "SurveyID"::int, "USRN", SUM("Capacity"), SUM("Demand"),
    CASE WHEN SUM("Capacity") = 0 THEN
            CASE WHEN SUM("Demand") > 0.0 THEN 1.0
                ELSE 0.0
            END
        ELSE
            CASE
                WHEN SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0) > 0.0 THEN
                    SUM("Demand") / (SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0))
                ELSE
                    CASE
                        WHEN SUM("Demand") > 0.0 THEN 1.0
                        ELSE 0.0
                    END
            END
    END
    , SUM("sbays"::float)
FROM demand."MASTER_Demand_03_Saturday_Saturday_Afternoon"
GROUP BY "SurveyID", "USRN";

INSERT INTO demand."MASTER_Demand_USRN"(
	"SurveyID", "USRN", "Capacity", "Demand", "Stress", "NrBaysSuspended")
SELECT "SurveyID"::int, "USRN", SUM("Capacity"), SUM("Demand"),
    CASE WHEN SUM("Capacity") = 0 THEN
            CASE WHEN SUM("Demand") > 0.0 THEN 1.0
                ELSE 0.0
            END
        ELSE
            CASE
                WHEN SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0) > 0.0 THEN
                    SUM("Demand") / (SUM("Capacity")::float - COALESCE(SUM("sbays"::float), 0.0))
                ELSE
                    CASE
                        WHEN SUM("Demand") > 0.0 THEN 1.0
                        ELSE 0.0
                    END
            END
    END
    , SUM("sbays"::float)
FROM demand."MASTER_Demand_04_Sunday_Sunday_Afternoon"
GROUP BY "SurveyID", "USRN";

/***
-- to create plans, use virtual layer ...
SELECT r.*, s."usrn", s."SurveyID", s."Stress"
FROM "StreetGazetteer" r, "MASTER_Demand_USRN" s
WHERE r."usrn" = s."usrn"

-- ensure that geomtry type is "linestring"
***/

