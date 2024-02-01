/***
 
 Survey Area
 
 ***/

UPDATE "mhtc_operations"."Supply" AS s
SET "SurveyAreaID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom)
AND "SurveyAreaID" IS NULL;

-- need to tidy ...

/***

section details to pick up side of street, etc

***/

-- set road details

UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
	  AND LENGTH(c1."RoadName") > 0
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."RoadName" = closest."RoadName";


-- Deal with narrow roads within Supply ...

-- Short sections ...
