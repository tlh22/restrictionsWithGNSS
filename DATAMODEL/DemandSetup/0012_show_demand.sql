-- create supply table that shows bay divisions

DROP TABLE IF EXISTS demand."Supply_for_viewing_demand";

CREATE TABLE demand."Supply_for_viewing_demand"
(
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700) NOT NULL,
    "RestrictionLength" double precision NOT NULL,
    "RestrictionTypeID" integer NOT NULL,
    "GeomShapeID" integer NOT NULL,
    "AzimuthToRoadCentreLine" double precision,
    "BayOrientation" double precision,
    "NrBays" integer NOT NULL DEFAULT '-1'::integer,
    "Capacity" integer,
    CONSTRAINT "Supply_for_viewing_demand_pkey" UNIQUE ("GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE demand."Supply_for_viewing_demand"
    OWNER to postgres;
-- Index: sidx_Supply_geom

-- DROP INDEX mhtc_operations."sidx_Supply_geom";

CREATE INDEX "sidx_Supply_for_viewing_demand_geom"
    ON demand."Supply_for_viewing_demand" USING gist
    (geom)
    TABLESPACE pg_default;


-- populate

INSERT INTO demand."Supply_for_viewing_demand"(
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "BayOrientation", "NrBays", "Capacity")
SELECT "GeometryID", geom, "RestrictionLength", "RestrictionTypeID",
        CASE WHEN "GeomShapeID" < 10 THEN "GeomShapeID" + 20
             WHEN "GeomShapeID" >= 10 AND "GeomShapeID" < 20 THEN 21
             ELSE "GeomShapeID"
         END
         , "AzimuthToRoadCentreLine", "BayOrientation", "Capacity", "Capacity"
	FROM mhtc_operations."Supply";
