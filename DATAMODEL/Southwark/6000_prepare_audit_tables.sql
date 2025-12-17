

--
DROP TABLE IF EXISTS mhtc_operations."Restrictions_Audit_Issues" CASCADE;

CREATE TABLE IF NOT EXISTS mhtc_operations."Restrictions_Audit_Issues"
(
	gid SERIAL, 
	"GeometryID" character varying COLLATE pg_catalog."default" NOT NULL,
	ogc_fid integer,
	"SouthwarkProposedDeliveryZoneName" character varying COLLATE pg_catalog."default",
	"Reason" text COLLATE pg_catalog."default",
	"RoadName_orig" character varying COLLATE pg_catalog."default",
	"RoadName_new" character varying COLLATE pg_catalog."default",
	"RestrictionDescription_orig" character varying COLLATE pg_catalog."default",
	"RestrictionDescription_new" character varying COLLATE pg_catalog."default",
	"RestrictionShapeDescription_orig" character varying COLLATE pg_catalog."default",
	"RestrictionShapeDescription_new" character varying COLLATE pg_catalog."default",
	"NrBays_orig" integer,
	"NrBays_new" integer,
	"TimePeriodDescription_orig" character varying COLLATE pg_catalog."default",
	"TimePeriodDescription_new" character varying COLLATE pg_catalog."default",
	"MaxStayDescription_orig" character varying COLLATE pg_catalog."default",
	"MaxStayDescription_new" character varying COLLATE pg_catalog."default",
	"NoReturnDescription_orig" character varying COLLATE pg_catalog."default",
	"NoReturnDescription_new" character varying COLLATE pg_catalog."default",
	"Length orig" double precision,
	"Length new" double precision,
	geom geometry(LineString,27700),
	CONSTRAINT "Restrictions_Audit_Issues_pkey" PRIMARY KEY ("gid")
)

TABLESPACE pg_default;

--

CREATE INDEX "sidx_Restrictions_Audit_Issues_geom"
    ON mhtc_operations."Restrictions_Audit_Issues" USING gist
    (geom)
    TABLESPACE pg_default;


--

DROP TABLE IF EXISTS mhtc_operations."Signs_Audit_Issues" CASCADE;

CREATE TABLE IF NOT EXISTS mhtc_operations."Signs_Audit_Issues"
(
	gid SERIAL, 
	"GeometryID" character varying COLLATE pg_catalog."default" NOT NULL,
	"SouthwarkProposedDeliveryZoneName" character varying COLLATE pg_catalog."default",
	"RoadName" character varying COLLATE pg_catalog."default",
	"SignTypeDescription" character varying COLLATE pg_catalog."default",
	"Restriction_Sign_Issue" character varying COLLATE pg_catalog."default",
	"Sign_Condition_Issue" character varying COLLATE pg_catalog."default",
	"ComplianceNotes" character varying COLLATE pg_catalog."default",
	"Notes" character varying COLLATE pg_catalog."default",
	"Easting" double precision,
	"Northing" double precision,
	"Photo" character varying COLLATE pg_catalog."default",
	geom geometry(Point,27700),
	CONSTRAINT "Signs_Audit_Issues_pkey" PRIMARY KEY ("gid")
)

TABLESPACE pg_default;

--

CREATE INDEX "sidx_Signs_Audit_Issues_geom"
    ON mhtc_operations."Signs_Audit_Issues" USING gist
    (geom)
    TABLESPACE pg_default;

-- Permissions

GRANT ALL ON SCHEMA mhtc_operations TO postgres;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_admin;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_operator;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_public;

REVOKE ALL ON ALL TABLES IN SCHEMA mhtc_operations FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;