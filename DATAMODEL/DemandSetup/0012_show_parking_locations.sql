-- create supply table that shows bay divisions

-- create view with to show stress

DROP MATERIALIZED VIEW IF EXISTS demand."Demand_view_to_show_parking_locations";

DROP TABLE IF EXISTS demand."Supply_for_viewing_parking_locations" CASCADE;

CREATE TABLE demand."Supply_for_viewing_parking_locations"
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
    CONSTRAINT "Supply_for_viewing_parking_locations_pkey" UNIQUE ("GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE demand."Supply_for_viewing_parking_locations"
    OWNER to postgres;
-- Index: sidx_Supply_geom

-- DROP INDEX mhtc_operations."sidx_Supply_geom";

CREATE INDEX "sidx_Supply_for_viewing_parking_locations_geom"
    ON demand."Supply_for_viewing_parking_locations" USING gist
    (geom)
    TABLESPACE pg_default;


-- populate

INSERT INTO demand."Supply_for_viewing_parking_locations"(
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "BayOrientation", "NrBays", "Capacity")
SELECT "GeometryID", geom, "RestrictionLength", "RestrictionTypeID",
        CASE WHEN "GeomShapeID" < 10 THEN "GeomShapeID" + 20
             WHEN "GeomShapeID" >= 10 AND "GeomShapeID" < 20 THEN 21
             ELSE "GeomShapeID"
         END
         , "AzimuthToRoadCentreLine", "BayOrientation",
         CASE WHEN "NrBays" = -1 THEN "Capacity"
              ELSE "NrBays"
         END AS "NrBays", "Capacity"  -- increase the NrBays value to deal with over parked areas

	FROM mhtc_operations."Supply";

CREATE MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS
/** -- Using demand_Merged
    SELECT row_number() OVER (PARTITION BY true::boolean) AS id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation", s."NrBays", s."Capacity",
    d."SurveyID", --d."sbays" AS "BaysSuspended",
    d."Demand" AS "Demand",

    --What to do about suspensions
    CASE
        WHEN s."Capacity"::float = 0 THEN
            CASE
                WHEN d."Demand"::float > 0.0 THEN 1.0
                ELSE 0.0
                END
        ELSE
            CASE
                WHEN s."Capacity"::float > 0.0 THEN
                    d."Demand"::float / (s."Capacity"::float) * 1.0
                ELSE
                    CASE
                        WHEN d."Demand"::float > 0.0 THEN 1.0
                        ELSE  0.0
                        END
                END
        END AS "Stress"

	FROM demand."Supply_for_viewing_parking_locations" s, demand."Demand_Merged_Final" d
	WHERE d."GeometryID" = s."GeometryID"

	**/
    SELECT row_number() OVER (PARTITION BY true::boolean) AS id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation",
    CASE WHEN d."Demand" > s."NrBays" THEN d."Demand"
         ELSE s."NrBays"
    END AS "NrBays",
    d."Capacity",
    d."SurveyID", d."NrVehicles" AS "Demand"

    FROM demand."Supply_for_viewing_parking_locations" s, demand."Demand_Merged" d
	WHERE d."GeometryID" = s."GeometryID"

WITH DATA;

ALTER TABLE demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";
