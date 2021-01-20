-- lookups

INSERT INTO "havering_operations"."JunctionProtectionCategoryTypes" ("Code", "Description") VALUES (1, 'No action required');
INSERT INTO "havering_operations"."JunctionProtectionCategoryTypes" ("Code", "Description") VALUES (2, 'Current markings correct - condition issues');
INSERT INTO "havering_operations"."JunctionProtectionCategoryTypes" ("Code", "Description") VALUES (3, 'Current markings not in compliance');

-- Insert details into "HaveringCorners"

INSERT INTO havering_operations."HaveringCorners" ("CornerID", corner_point_geom)
SELECT id, geom
FROM mhtc_operations."Corners";

-- get some segments and end points

WITH cornerDetails AS (
SELECT c."CornerID" as id, c.corner_point_geom As corner_geom, r.geom as road_casement_geom
FROM havering_operations."HaveringCorners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.corner_point_geom, 0.1))
 )
 INSERT INTO havering_operations."HaveringCornerSegments" ("CornerID", "SegmentLength", geom)
 SELECT d.id, ST_Length(mhtc_operations."get_road_casement_section"(d.id, d.road_casement_geom, d.corner_geom, 10.0)),
                mhtc_operations."get_road_casement_section"(d.id, d.road_casement_geom, d.corner_geom, 10.0)
 FROM cornerDetails d;

DELETE FROM havering_operations."HaveringCornerSegments" c1
WHERE "CornerID" IN (
    SELECT "CornerID"
    FROM (
        SELECT "CornerID", count(*)
        FROM havering_operations."HaveringCornerSegments"
        GROUP BY "CornerID"
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY havering_operations."HaveringCornerSegments"
    ADD CONSTRAINT "HaveringCornerSegments_pkey" PRIMARY KEY ("CornerID");

UPDATE havering_operations."HaveringCorners" AS c
 SET line_from_corner_point_geom = s.geom
 FROM havering_operations."HaveringCornerSegments" s
 WHERE s."CornerID" = c."CornerID";

--

INSERT INTO havering_operations."HaveringCornerSegmentEndPts" ("CornerID", "StartPt", "EndPt")
SELECT d."CornerID", ST_StartPoint(d.geom), ST_EndPoint(d.geom)
FROM havering_operations."HaveringCornerSegments" d;

ALTER TABLE ONLY havering_operations."HaveringCornerSegmentEndPts"
    ADD CONSTRAINT "HaveringCornerSegmentEndPts_pkey" PRIMARY KEY ("CornerID");

-- include apex points

UPDATE havering_operations."HaveringCorners" AS c
SET apex_point_geom = havering_operations."getCornerApexPoint"(c."CornerID", 10.0);  -- need to check this works!

-- include line_from_corner_point_geom

/*
WITH cornerDetails AS (
SELECT c."CornerID", c.corner_point_geom As corner_geom, r.geom as road_casement_geom
FROM havering_operations."HaveringCorners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.corner_point_geom, 0.1))
 )
     UPDATE havering_operations."HaveringCorners" AS c
     SET line_from_corner_point_geom = mhtc_operations."get_road_casement_section"(d."CornerID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)
     FROM cornerDetails d
     WHERE d."CornerID" = c."CornerID";
*/

-- line_from_apex_point_geom

UPDATE havering_operations."HaveringCorners" AS c
SET line_from_apex_point_geom = ST_GeometryN(havering_operations."getCornerExtentsFromApex"(c."CornerID"), 1);

-- new_junction_protection_geom

INSERT INTO havering_operations."HaveringCornerConformingSegments" ("CornerID", geom)
SELECT u."CornerID", ST_Multi(ST_Union(u.geom))
FROM
(SELECT c."CornerID" as "CornerID", r.geom as geom
FROM havering_operations."HaveringCorners" c, "toms"."Lines" r
WHERE ST_Intersects(r.geom, ST_Buffer(ST_SetSRID(c.line_from_apex_point_geom, 27700), 0.1))
AND r."RestrictionTypeID" NOT IN (201, 221, 224, 216, 220)
UNION
SELECT c."CornerID" as id, ST_Multi(r.geom)
FROM havering_operations."HaveringCorners" c, "toms"."Bays" r
WHERE ST_Intersects(r.geom, ST_Buffer(ST_SetSRID(c.line_from_apex_point_geom, 27700), 0.1))
 ) AS u
 GROUP BY u."CornerID";

UPDATE havering_operations."HaveringCorners" AS c
SET new_junction_protection_geom = ST_Multi(ST_Difference(ST_Multi(c.line_from_apex_point_geom), ST_Buffer(d.geom, 0.1)))
FROM havering_operations."HaveringCornerConformingSegments" d
WHERE d."CornerID" = c."CornerID";







