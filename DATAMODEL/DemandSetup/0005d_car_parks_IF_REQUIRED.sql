-- Add additional fields

ALTER TABLE "toms"."RestrictionPolygons"
  ADD COLUMN "NrBays" integer;

ALTER TABLE "toms"."RestrictionPolygons"
  ADD COLUMN "SectionID" integer;

-- Set road names

UPDATE "toms"."RestrictionPolygons" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, s.geom) AS geom,
        ST_Distance(c1.geom, s.geom) AS length, c1."RoadName"
      FROM "toms"."RestrictionPolygons" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 25.0)
      AND s."RestrictionTypeID" IN (3, 4, 5, 6, 9, 11, 25)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;