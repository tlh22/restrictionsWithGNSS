-- create view with to show stress

DROP MATERIALIZED VIEW IF EXISTS demand."Demand_view_to_show_parking_locations";

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
    d."SurveyID", d."Demand"

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
