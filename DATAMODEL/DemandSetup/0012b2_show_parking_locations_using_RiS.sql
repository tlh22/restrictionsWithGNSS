-- create view with to show stress

drop materialized view IF EXISTS demand."Demand_view_to_show_parking_locations";

/***
Reimport details into table "VRMs_revised" - if required

1. Save All VRMs worksheet and keep columns
ID, SurveyID, SurveyDay, SurveyTime, Roadname, Restriction Type, SideofStreet, GeometryID, VRM, Vehicle Type, Vehicle Type Description, PCU, User Type, Notes

DROP TABLE IF EXISTS demand."VRMs_revised" CASCADE;

CREATE TABLE IF NOT EXISTS demand."VRMs_revised"
(
    "ID" integer NOT NULL,
    "SurveyID" character varying(50) COLLATE pg_catalog."default",
    "SurveyDay" character varying(100) COLLATE pg_catalog."default",
    "SurveyTime" character varying(100) COLLATE pg_catalog."default",
    "Roadname" character varying(100) COLLATE pg_catalog."default",
    "RestrictionType" character varying(100) COLLATE pg_catalog."default",
    "SideofStreet" character varying(100) COLLATE pg_catalog."default",
    "GeometryID" character varying(12) COLLATE pg_catalog."default",
    "VRM" character varying(12) COLLATE pg_catalog."default",
    "VehicleTypeID"  character varying(50) COLLATE pg_catalog."default",
    "VehicleTypeDescription"  character varying(100) COLLATE pg_catalog."default",
    "PCU"  character varying(50) COLLATE pg_catalog."default",
    "UserType"  character varying(100) COLLATE pg_catalog."default",
    "Notes" character varying(255) COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE demand."VRMs_revised"
    OWNER to postgres;

-- Import
COPY demand."VRMs_revised"("ID", "SurveyID", "SurveyDay", "SurveyTime", "Roadname", "RestrictionType",
                               "SideofStreet", "GeometryID", "VRM", "VehicleTypeID",
                               "VehicleTypeDescription", "PCU", "UserType", "Notes")
FROM 'C:\Users\Public\Documents\PC2108b_All_VRMs.csv'
DELIMITER ','
CSV HEADER;

alter table demand."VRMs_revised" alter COLUMN "SurveyID"  TYPE integer USING ("SurveyID"::integer);
alter table demand."VRMs_revised" alter COLUMN "VehicleTypeID"  TYPE integer USING ("VehicleTypeID"::integer);
***/

--

create MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS

    select row_number() over (partition by true::boolean) as id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation",
    case when d."Demand" > s."NrBays" then d."Demand"
         else s."NrBays"
    end as "NrBays",
    s."Capacity",
    d."SurveyID", d."Demand" as "Demand"

    from demand."Supply_for_viewing_parking_locations" s,

        (select d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
        d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
        d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", v."Demand"
        from
        (select ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" as "RestrictionType Description",
        "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
        ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity"
        from demand."RestrictionsInSurveys" ris, demand."Surveys" su,
        (mhtc_operations."Supply" as a
         left join "toms_lookups"."BayLineTypes" as "BayLineTypes" on a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") as s
         where ris."SurveyID" = su."SurveyID"
         and ris."GeometryID" = s."GeometryID"
         ) as d

         left join  (select "SurveyID", "GeometryID",
           sum(case when "VehicleTypeID" = 0 or "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 or "VehicleTypeID" = 9 then 1.0  -- Car, LGV or Taxi
                    when "VehicleTypeID" = 3 then 0.4  -- MCL
                    when "VehicleTypeID" = 4 then 1.5  -- OGV
                    when "VehicleTypeID" = 5 then 2.0  -- Bus
                    else 1.0  -- Other or Null
              end) as "Demand"
           from demand."VRMs_revised"
           group by "SurveyID", "GeometryID"
          ) as v on d."SurveyID" = v."SurveyID" and d."GeometryID" = v."GeometryID"
        order by d."RestrictionTypeID", d."GeometryID", d."SurveyID") as d

	WHERE d."GeometryID" = s."GeometryID"

with DATA;

alter table demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

create UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";


-- or using vrms_final

drop materialized view IF EXISTS demand."Demand_view_to_show_parking_locations";
create MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS

    select row_number() over (partition by true::boolean) as id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation",
    case when d."Demand" > s."NrBays" then d."Demand"
         else s."NrBays"
    end as "NrBays",
    s."Capacity",
    d."SurveyID", d."Demand" as "Demand"

    from demand."Supply_for_viewing_parking_locations" s,

        (select d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
        d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
        d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", v."Demand"
        from
        (select ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" as "RestrictionType Description",
        "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
        ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity"
        from demand."RestrictionsInSurveys" ris, demand."Surveys" su,
        (mhtc_operations."Supply" as a
         left join "toms_lookups"."BayLineTypes" as "BayLineTypes" on a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") as s
         where ris."SurveyID" = su."SurveyID"
         and ris."GeometryID" = s."GeometryID"
         ) as d

         left join  (select "SurveyID", "GeometryID",
           sum(case when "VehicleTypeID" = 0 or "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 or "VehicleTypeID" = 9 then 1.0  -- Car, LGV or Taxi
                    when "VehicleTypeID" = 3 then 0.4  -- MCL
                    when "VehicleTypeID" = 4 then 1.5  -- OGV
                    when "VehicleTypeID" = 5 then 2.0  -- Bus
                    else 1.0  -- Other or Null
              end) as "Demand"
           from demand."VRMs_Final"
           group by "SurveyID", "GeometryID"
          ) as v on d."SurveyID" = v."SurveyID" and d."GeometryID" = v."GeometryID"
        order by d."RestrictionTypeID", d."GeometryID", d."SurveyID") as d

	WHERE d."GeometryID" = s."GeometryID"

with DATA;

alter table demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

create UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";
