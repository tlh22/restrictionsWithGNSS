/***

Investigate possible issues with dual restrictions

***/

SELECT d1."GeometryID"
, d1."RestrictionDescription"
, d1."Capacity"
, d2."RestrictionDescription"
, d1.geom
FROM 
(
SELECT d.id
, d."GeometryID"
, s."RestrictionTypeID"
, s."RoadName"
, s."Capacity"
, s.geom
, "BayLineTypes"."Description" As "RestrictionDescription"
, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
FROM mhtc_operations."DualRestrictions" d, mhtc_operations."Supply" s
	LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON s."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
	LEFT JOIN "import_geojson"."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE d."GeometryID" = s."GeometryID"
) d1,
(
SELECT d.id
, d."GeometryID"
, s."RestrictionTypeID"
, s."RoadName"
, s."Capacity"
, s.geom
, "BayLineTypes"."Description" As "RestrictionDescription"
, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
FROM mhtc_operations."DualRestrictions" d, mhtc_operations."Supply" s
	LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON s."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
	LEFT JOIN "import_geojson"."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE d."LinkedTo" = s."GeometryID"
) d2
WHERE d1.id = d2.id
AND (d1."RestrictionTypeID" IN (216, 220, 225, 227, 228, 229) -- any unmarked areas
OR d2."RestrictionTypeID" IN (216, 220, 225, 227, 228, 229))
AND d1."SouthwarkProposedDeliveryZoneName" = 'J'
AND d1."RoadName" = 'East Street'


-- check RiS

SELECT "SurveyID", "GeometryID", "Demand"
FROM demand."RestrictionsInSurveys"
WHERE "GeometryID" = 'S_023076'

-- 

INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
VALUES ('S_028265', 'S_028263');


UPDATE mhtc_operations."DualRestrictions" AS d
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."GeometryID" = 'S_028265';