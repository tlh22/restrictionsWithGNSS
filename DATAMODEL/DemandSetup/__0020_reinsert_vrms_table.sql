/***
 * re-insert VRMs table
 ***/

DROP TABLE IF EXISTS demand."vrms_final" CASCADE;
CREATE TABLE demand."vrms_final"
(
  "ID" SERIAL,
  "SurveyID" integer,
  "SectionID" integer,
  "GeometryID" character varying(12),
  "PositionID" integer,
  "VRM" character varying(12),
  "VehicleTypeID" integer,
  "RestrictionTypeID" integer,
  "PermitTypeID" integer,
  "Notes" character varying(255),
  CONSTRAINT "vrms_final_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."vrms_final"
  OWNER TO postgres;

DROP TABLE IF EXISTS demand.vrms_final_tmp CASCADE;

CREATE TABLE demand.vrms_final_tmp
(
    id SERIAL,
    "ID" character varying(250) COLLATE pg_catalog."default",
    "SurveyID" character varying(250) COLLATE pg_catalog."default",
    "SurveyDay" character varying(250) COLLATE pg_catalog."default",
    "SurveyTime" character varying(250) COLLATE pg_catalog."default",
    "Position" character varying(250) COLLATE pg_catalog."default",
    "Roadname" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "Restriction Type" character varying(250) COLLATE pg_catalog."default",
    "SideofStreet" character varying(250) COLLATE pg_catalog."default",
    "GeometryID" character varying(250) COLLATE pg_catalog."default",
    "VRM" character varying(250) COLLATE pg_catalog."default",
    "Orig VRM" character varying(250) COLLATE pg_catalog."default",
    "Vehicle Type" character varying(250) COLLATE pg_catalog."default",
    "Vehicle Type Description" character varying(250) COLLATE pg_catalog."default",
    "PCU" character varying(250) COLLATE pg_catalog."default",
    "User Type" character varying(250) COLLATE pg_catalog."default",
    "Notes" character varying(250) COLLATE pg_catalog."default",
    "Enumerator" character varying(250) COLLATE pg_catalog."default",
    "Time" character varying(250) COLLATE pg_catalog."default",
    "Vehicle Type Helper" character varying(250) COLLATE pg_catalog."default"
)
TABLESPACE pg_default;

ALTER TABLE demand.vrms_final_tmp
    OWNER to postgres;

-- Now copy details into the tmp table

COPY demand.vrms_final_tmp(
    "ID",
    "SurveyID",
    "SurveyDay",
    "SurveyTime",
    "Position",
    "Roadname",
    "Restriction Type",
    "SideofStreet",
    "GeometryID",
    "VRM",
    "Orig VRM",
    "Vehicle Type",
    "Vehicle Type Description",
    "PCU",
    "User Type",
    "Notes",
    "Enumerator",
    "Time",
    "Vehicle Type Helper"
)
FROM 'C:\Users\Public\Documents\PC2108c_VRMs.csv'
DELIMITER ','
CSV HEADER;

-- Move to main table

INSERT INTO demand."vrms_final"("SurveyID", "GeometryID", "PositionID",
  "VRM", "VehicleTypeID", "Notes")
SELECT "SurveyID"::integer, "GeometryID", "Position"::integer,
  "VRM", "Vehicle Type"::integer, "Notes"
FROM demand.vrms_final_tmp
--WHERE "SurveyID" ~ E'^\\d+$'
;