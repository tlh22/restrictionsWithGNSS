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

-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."Supply_view_to_show_demand";

CREATE MATERIALIZED VIEW demand."Supply_view_to_show_demand"
TABLESPACE pg_default
AS
    SELECT row_number() OVER (PARTITION BY true::boolean) AS id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation", s."NrBays", s."Capacity",
    d."SurveyID", d."Demand"
	FROM demand."Supply_for_viewing_demand" s, demand."Demand_Merged_Marie" d
	WHERE d."GeometryID" = s."GeometryID"
WITH DATA;

ALTER TABLE demand."Supply_view_to_show_demand"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_supply_view_to_show_demand_id"
    ON demand."Supply_view_to_show_demand" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Supply_view_to_show_demand";
