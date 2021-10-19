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


/***
Reimport details into table "VRMs_revised" - if required
***/
ALTER TABLE demand."VRMs_revised" ALTER COLUMN "SurveyID"  TYPE integer USING ("SurveyID"::integer);
ALTER TABLE demand."VRMs_revised" ALTER COLUMN "VehicleTypeID"  TYPE integer USING ("VehicleTypeID"::integer);

--

CREATE MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS

    SELECT row_number() OVER (PARTITION BY true::boolean) AS id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation",
    CASE WHEN d."Demand" > s."NrBays" THEN d."Demand"
         ELSE s."NrBays"
    END AS "NrBays",
    s."Capacity",
    d."SurveyID", d."Demand" AS "Demand"

    FROM demand."Supply_for_viewing_parking_locations" s,

        (SELECT d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
        d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
        d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", v."Demand"
        FROM
        (SELECT ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description",
        "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
        ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity"
        FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
        (mhtc_operations."Supply" AS a
         LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
         WHERE ris."SurveyID" = su."SurveyID"
         AND ris."GeometryID" = s."GeometryID"
         ) as d

         LEFT JOIN  (SELECT "SurveyID", "GeometryID",
           SUM(CASE WHEN "VehicleTypeID" = 0 or "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 or "VehicleTypeID" = 9 THEN 1.0  -- Car, LGV or Taxi
                    WHEN "VehicleTypeID" = 3 THEN 0.4  -- MCL
                    WHEN "VehicleTypeID" = 4 THEN 1.5  -- OGV
                    WHEN "VehicleTypeID" = 5 THEN 2.0  -- Bus
                    ELSE 1.0  -- Other or Null
              END) AS "Demand"
           FROM demand."VRMs_revised"
           GROUP BY "SurveyID", "GeometryID"
          ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
        ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID") as d

	WHERE d."GeometryID" = s."GeometryID"

WITH DATA;

ALTER TABLE demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";
