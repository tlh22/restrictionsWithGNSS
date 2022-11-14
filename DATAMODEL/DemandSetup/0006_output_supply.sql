
-- Make sure capacities are updated

UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

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
a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", "RC_Sections_merged"."SectionName", COALESCE("SurveyAreas"."SurveyAreaName", '')  AS "SurveyAreaName",

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
     (((((((
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
	 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")

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

ORDER BY "RestrictionTypeID", "GeometryID";


/**
For sections
**/

SELECT
s."GeometryID", s."RestrictionTypeID", 'Subsection' AS "RestrictionDescription",
10 AS "GeomShapeID", 'Parallel Line' AS "Restriction Shape Description",
a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", a."SectionName",
       NULL AS "DetailsOfControl",
       NULL AS "UnacceptabilityReason",
       "SectionLength" AS "KerblineLength",
       -1 AS "MarkedBays", NULL AS "TheoreticalBays",
       NULL AS "ParkingAvailableDuringSurveyHours",
       NULL AS "CPZ"

FROM "mhtc_operations"."RC_Sections_merged" a, "demand"."SupplyForDemand" s
WHERE ST_Equals(a.geom, s.geom)
ORDER BY s."GeometryID";

/***
For RBKC
***/

SELECT
a."GeometryID", a."RestrictionTypeID",
"BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",

a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", "RC_Sections_merged"."SectionName", COALESCE("SurveyAreas"."SurveyAreaName", '')  AS "SurveyAreaName",

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
            END AS "ParkingAvailableDuringSurveyHours", "CPZ", item_refs

FROM
     (((((((
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
	 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code"),
	 mhtc_operations."RBKC_RequestAreas" r, (SELECT "GeometryID", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links"
											 GROUP BY "GeometryID" ) l
	 --WHERE a."RoadName" NOT LIKE '%Car Park%'
	 WHERE ST_Within (a.geom, r.geom)
	 AND r."Name" = 'Area 2'
	 AND "RestrictionTypeID" < 200
	 AND a."GeometryID" = l."GeometryID"
	 --AND
ORDER BY "RestrictionTypeID", "GeometryID"
