-- survey areas
--DROP TABLE IF EXISTS mhtc_operations."SurveyAreas";
CREATE TABLE demand."Demand_VRMs"
(
    "ID" SERIAL,
    "SurveyID" integer,
    "SectionID" integer,
    "GeometryID" character varying(12) COLLATE pg_catalog."default",
    "PositionID" integer,
    "VRM" character varying(12) COLLATE pg_catalog."default",
    "VehicleTypeID" integer,
    "RestrictionTypeID" integer,
    "PermitType" integer,
    "Notes" character varying(255) COLLATE pg_catalog."default",
    "Surveyor" character varying(255),
    CONSTRAINT "Demand_VRMs_pkey" PRIMARY KEY ("ID")
)

TABLESPACE pg_default;

ALTER TABLE demand."Demand_VRMs"
    OWNER to postgres;
