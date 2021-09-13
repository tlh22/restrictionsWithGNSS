--

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
            END AS "ParkingAvailableDuringSurveyHours"

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

ORDER BY "RestrictionTypeID", "GeometryID"


--- used in Haringey
--

SELECT
"GeometryID", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
"RoadName", "StartStreet" AS "RoadFrom", "EndStreet" AS "RoadTo", "SideOfStreet", "SectionID", COALESCE("SurveyArea", ''),

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


--- used in Haringey

SELECT
"GeometryID", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", COALESCE("SectionName", '') AS "SectionName", COALESCE(a."SurveyArea", '') AS "SurveyArea",

       CASE WHEN "RestrictionTypeID" < 200 THEN COALESCE("TimePeriods1"."Description", '')
            ELSE COALESCE("TimePeriods2"."Description", '')
            END  AS "DetailsOfControl",
       COALESCE("UnacceptableTypes"."Description", '') AS "UnacceptabilityReason",
       "RestrictionLength" AS "KerblineLength",
       "NrBays" AS "MarkedBays", "Capacity" AS "TheoreticalBays",

       CASE WHEN "RestrictionTypeID" IN (107, 122, 161, 162, 202, 209, 210, 211, 212, 213, 214, 215, 218, 220, 221, 222) THEN 0
            -- exclude bus stops/bus stands
            -- include acceptable SYLs, SRLs
            --WHEN "RestrictionTypeID" IN (201, 217) THEN
                --CASE WHEN "Allowable" IS NULL THEN "Capacity"
                     --ELSE 0
                     --END
            ELSE
                "Capacity"
            END AS "ParkingAvailableDuringSurveyHours"
	, "CPZ", "Notes"


FROM
     ((((((mhtc_operations."Supply" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code")
	 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
	 LEFT JOIN mhtc_operations."RC_Sections_merged" As "Sections" ON a."SectionID" is not distinct from "Sections"."gid")

	WHERE a."CPZ" IN ('FP')

ORDER BY "RestrictionTypeID", "GeometryID"


/*
For car parks
*/

SELECT
"GeometryID", "RestrictionTypeID", "RestrictionPolygonTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", "RC_Sections_merged"."SectionName", --COALESCE("SurveyArea", ''),

       COALESCE("TimePeriods1"."Description", '') AS "DetailsOfControl",
       "NrBays" AS "MarkedBays", "Capacity" AS "TheoreticalBays"


FROM
     ((((mhtc_operations."Supply" AS a
     LEFT JOIN "toms_lookups"."RestrictionPolygonTypes" AS "RestrictionPolygonTypes" ON a."RestrictionTypeID" is not distinct from "RestrictionPolygonTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
	 LEFT JOIN "mhtc_operations"."RC_Sections_merged" AS "RC_Sections_merged" ON a."SectionID" is not distinct from "RC_Sections_merged"."gid")

WHERE "RestrictionTypeID" = 25 -- car park

ORDER BY "RestrictionTypeID", "GeometryID"