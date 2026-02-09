/***
 
 Survey Area
 
 ***/

UPDATE "mhtc_operations2"."Supply" AS s
SET "SurveyAreaID" = NULL;

UPDATE "mhtc_operations2"."Supply" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom)
AND "SurveyAreaID" IS NULL;

-- need to tidy ...


-- set road details

UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
	  AND LENGTH(c1."RoadName") > 0
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."RoadName" IS NULL


-- Deal with narrow roads within Supply ...

-- Short sections ...

-- No Waiting Times 

SELECT s."GeometryID", c."CPZ"
FROM mhtc_operations."Supply" s, toms."ControlledParkingZones" c
WHERE s."NoWaitingTimeID" IS NULL
AND ST_Within(s.geom, c.geom)


UPDATE mhtc_operations."Supply" AS s
SET "CPZ" = c."CPZ", "NoWaitingTimeID" = c."TimePeriodID"
FROM toms."ControlledParkingZones" c
WHERE s."NoWaitingTimeID" IS NULL
AND ST_Within(s.geom, c.geom)





--- Control times 
-- Add any extras
INSERT INTO demand."TimePeriodsControlledDuringSurveyHours" ("SurveyID", "TimePeriodID")
SELECT "SurveyID", "TimePeriodID"
FROM demand."Surveys" s,
(SELECT DISTINCT "TimePeriodID"
 FROM mhtc_operations."Supply" a
  LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
 WHERE "RestrictionTypeID" < 200
 AND "TimePeriodID" IS NOT NULL
 AND a."SouthwarkProposedDeliveryZoneName" IN ('J')
 UNION
SELECT DISTINCT "NoWaitingTimeID" AS "TimePeriodID"
 FROM mhtc_operations."Supply" a
  LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
 WHERE "RestrictionTypeID" > 200
 AND "NoWaitingTimeID" IS NOT NULL
  AND a."SouthwarkProposedDeliveryZoneName" IN ('J')
  ) AS t
WHERE "TimePeriodID" NOT IN
    (SELECT DISTINCT "TimePeriodID"
    FROM demand."TimePeriodsControlledDuringSurveyHours")
AND s."SurveyID" > 0;


-- 

-- Unmarked
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (216, 225)
AND "Capacity" = 0;

-- SYLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (201, 224)
AND "Capacity" = 0;

