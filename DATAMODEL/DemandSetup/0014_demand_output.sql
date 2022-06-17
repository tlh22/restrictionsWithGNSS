/***
 * Output details suitable for using in Dashboard
 ***/

SELECT
            d."SurveyID", s."SurveyDay" As "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" As "Survey Time", d."GeometryID",
       (COALESCE("ncars"::float, 0)+COALESCE("ntaxis"::float, 0)) As "Nr Cars", COALESCE("nlgvs"::float, 0) As "Nr LGVs",
       COALESCE("nmcls"::float, 0) AS "Nr MCLs", COALESCE("nogvs"::float, 0) AS "Nr OGVs", COALESCE("nbuses"::float, 0) AS "Nr Buses",
       COALESCE(d."sbays"::integer, 0) AS "Bays Suspended", "Demand" As "Demand",
        "RestrictionDescription", "Restriction Shape Description",
        y."RoadName", y."RoadFrom", y."RoadTo", y."SideOfStreet", y."SectionName",  y."UnacceptabilityReason",
       y."KerblineLength", y."MarkedBays",  y."TheoreticalBays", y."ParkingAvailableDuringSurveyHours", y."CPZ"

FROM
(
SELECT
"GeometryID",
        CASE WHEN "RestrictionTypeID" = 225 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 220
                    ELSE 216
                 END
                 WHEN "RestrictionTypeID" = 224 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 221
                    ELSE 201
                 END
             ELSE "RestrictionTypeID"
        END AS "RestrictionTypeID",
"BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", "RC_Sections_merged"."SectionName", --COALESCE("SurveyArea", '')  AS "SurveyArea",

       CASE WHEN ("RestrictionTypeID" < 200 OR "RestrictionTypeID" IN (227, 228, 229, 231)) THEN COALESCE("TimePeriods1"."Description", '')
            ELSE COALESCE("TimePeriods2"."Description", '')
            END  AS "DetailsOfControl",
       COALESCE("UnacceptableTypes"."Description", '') AS "UnacceptabilityReason",
       "RestrictionLength" AS "KerblineLength",
       "NrBays" AS "MarkedBays", "Capacity" AS "TheoreticalBays",

       CASE WHEN "RestrictionTypeID" IN (122, 162, 107, 161, 202, 218, 220, 221, 222, 209, 210, 211, 212, 213, 214, 215) THEN 0
            --WHEN "RestrictionTypeID" IN (201, 217) THEN
                --CASE WHEN "Allowable" IS NULL THEN "Capacity"
                     --ELSE 0
                     --END
            ELSE
                "Capacity"
            END AS "ParkingAvailableDuringSurveyHours", "CPZ"

FROM
     ((((((
     (SELECT CASE WHEN "RestrictionTypeID" = 225 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 220
                    ELSE 216
                 END
                 WHEN "RestrictionTypeID" = 224 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 221
                    ELSE 201
                 END
             ELSE "RestrictionTypeID"
        END AS "RestrictionTypeID_Amended", *
        FROM mhtc_operations."Supply") AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID_Amended" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code")
	 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
	 LEFT JOIN "mhtc_operations"."RC_Sections_merged" AS "RC_Sections_merged" ON a."SectionID" is not distinct from "RC_Sections_merged"."gid")
) AS y,
      demand."Demand_Merged" d, demand."Surveys" s  -- include Supply to ensure that only current supply elements are included
WHERE s."SurveyID" = d."SurveyID"
AND d."GeometryID" = y."GeometryID"

ORDER BY s."SurveyID", "RestrictionDescription", "RoadName"

