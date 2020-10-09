--

SELECT
"GeometryID", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
"RoadName", "StartStreet" AS "RoadFrom", "EndStreet" AS "RoadTo", "SideOfStreet", "SectionID", --"Area",

       CASE WHEN "RestrictionTypeID" < 200 THEN COALESCE("TimePeriods1"."Description", '')
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
            END AS "ParkingAvailableDuringSurveyHours"

FROM
     (((((mhtc_operations."Supply" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code")
	 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")

ORDER BY "RestrictionTypeID", "GeometryID"