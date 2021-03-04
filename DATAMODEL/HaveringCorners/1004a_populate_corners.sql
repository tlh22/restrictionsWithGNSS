-- Insert details into "HaveringCorners"

INSERT INTO havering_operations."HaveringCorners" ("RestrictionID", corner_point_geom, "AssetConditionTypeID",
"LastUpdateDateTime", "LastUpdatePerson", "CreateDateTime", "CreatePerson")
SELECT uuid_generate_v4(), geom, 0, now(), current_user, now(), current_user
FROM mhtc_operations."Corners";

-- get some segments and end points

WITH cornerDetails AS (
SELECT c."GeometryID" as "GeometryID", c.corner_point_geom As corner_geom, r.geom as road_casement_geom
FROM havering_operations."HaveringCorners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.corner_point_geom, 0.1))
 )
 INSERT INTO havering_operations."HaveringCornerSegments" ("GeometryID", "SegmentLength", geom)
 SELECT d."GeometryID", ST_Length(havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)),
                havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)
 FROM cornerDetails d;

DELETE FROM havering_operations."HaveringCornerSegments" c1
WHERE "GeometryID" IN (
    SELECT "GeometryID"
    FROM (
        SELECT "GeometryID", count(*)
        FROM havering_operations."HaveringCornerSegments"
        GROUP BY "GeometryID"
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY havering_operations."HaveringCornerSegments"
    ADD CONSTRAINT "HaveringCornerSegments_pkey" PRIMARY KEY ("GeometryID");

UPDATE havering_operations."HaveringCorners" AS c
 SET line_from_corner_point_geom = s.geom
 FROM havering_operations."HaveringCornerSegments" s
 WHERE s."GeometryID" = c."GeometryID";

--

INSERT INTO havering_operations."HaveringCornerSegmentEndPts" ("GeometryID", "StartPt", "EndPt")
SELECT d."GeometryID", ST_StartPoint(d.geom), ST_EndPoint(d.geom)
FROM havering_operations."HaveringCornerSegments" d;

ALTER TABLE ONLY havering_operations."HaveringCornerSegmentEndPts"
    ADD CONSTRAINT "HaveringCornerSegmentEndPts_pkey" PRIMARY KEY ("GeometryID");

-- include apex points

UPDATE havering_operations."HaveringCorners" AS c
SET apex_point_geom = havering_operations."getCornerApexPoint"(c."GeometryID", mhtc_operations."getParameter"('CornerProtectionDistance')::float);  -- need to check this works!

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

-- Now recalculate the corner point and redo the corner line ****

UPDATE havering_operations."HaveringCorners" AS c
SET corner_point_geom = ST_ClosestPoint(s.geom, c.apex_point_geom)
FROM havering_operations."HaveringCornerSegments" s
WHERE s."GeometryID" = c."GeometryID"
AND ST_ClosestPoint(s.geom, c.apex_point_geom) IS NOT NULL;

-- redo cornerSegments

DELETE FROM havering_operations."HaveringCornerSegments";

ALTER TABLE havering_operations."HaveringCornerSegments" DROP CONSTRAINT "HaveringCornerSegments_pkey";

WITH cornerDetails AS (
SELECT c."GeometryID" as "GeometryID", c.corner_point_geom As corner_geom, r.geom as road_casement_geom
FROM havering_operations."HaveringCorners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.corner_point_geom, 0.1))
 )
 INSERT INTO havering_operations."HaveringCornerSegments" ("GeometryID", "SegmentLength", geom)
 SELECT d."GeometryID", ST_Length(havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)),
                havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)
 FROM cornerDetails d;

DELETE FROM havering_operations."HaveringCornerSegments" c1
WHERE "GeometryID" IN (
    SELECT "GeometryID"
    FROM (
        SELECT "GeometryID", count(*)
        FROM havering_operations."HaveringCornerSegments"
        GROUP BY "GeometryID"
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY havering_operations."HaveringCornerSegments"
    ADD CONSTRAINT "HaveringCornerSegments_pkey" PRIMARY KEY ("GeometryID");

-- line_from_apex_point_geom

UPDATE havering_operations."HaveringCorners" AS c
SET line_from_apex_point_geom = ST_GeometryN(havering_operations."getCornerExtentsFromApex"(c."GeometryID"), 1);

-- new_corner_protection_geom

INSERT INTO havering_operations."HaveringCornerConformingSegments" ("GeometryID", geom)
SELECT u."GeometryID", ST_Multi(ST_Union(u.geom))
FROM
(SELECT c."GeometryID" as "GeometryID", r.geom as geom
FROM havering_operations."HaveringCorners" c, "toms"."Lines" r
WHERE ST_Intersects(r.geom, ST_Buffer(ST_SetSRID(c.line_from_apex_point_geom, 27700), 0.1))
AND r."RestrictionTypeID" NOT IN (201, 221, 224, 216, 220)
UNION
SELECT c."GeometryID" as id, ST_Multi(r.geom)
FROM havering_operations."HaveringCorners" c, "toms"."Bays" r
WHERE ST_Intersects(r.geom, ST_Buffer(ST_SetSRID(c.line_from_apex_point_geom, 27700), 0.1))
 ) AS u
 GROUP BY u."GeometryID";

UPDATE havering_operations."HaveringCorners" AS c
SET new_corner_protection_geom = ST_Multi(ST_CollectionExtract(ST_Difference(ST_Multi(c.line_from_apex_point_geom), ST_Buffer(d.geom, 0.1)), 2))
FROM havering_operations."HaveringCornerConformingSegments" d
WHERE d."GeometryID" = c."GeometryID";

UPDATE havering_operations."HaveringCorners" AS c
SET new_corner_protection_geom = ST_Multi(c.line_from_apex_point_geom)
WHERE c."GeometryID" NOT IN (
    SELECT d."GeometryID"
    FROM havering_operations."HaveringCornerConformingSegments" d);

-- havering_operations."HaveringCorners_Output"

INSERT INTO havering_operations."HaveringCorners_Output" ("GeometryID", new_corner_protection_geom)
SELECT "GeometryID", (ST_Dump(new_corner_protection_geom)).geom
FROM havering_operations."HaveringCorners";

UPDATE havering_operations."HaveringCorners_Output"
SET "AzimuthToRoadCentreLine" = degrees(mhtc_operations."AzToNearestRoadCentreLine"(ST_AsText(ST_LineInterpolatePoint(new_corner_protection_geom, 0.5)), 25.0));

-- classify corners

UPDATE havering_operations."HaveringCorners"
    SET "CornerProtectionCategoryTypeID" = 1
    WHERE ST_Length(new_corner_protection_geom) = 0.0
    OR ST_Length(new_corner_protection_geom) IS NULL;

UPDATE havering_operations."HaveringCorners"
    SET "CornerProtectionCategoryTypeID" = 2
    WHERE ST_Length(new_corner_protection_geom) > 0.0 and ST_Length(new_corner_protection_geom) < 16.0;

UPDATE havering_operations."HaveringCorners"
    SET "CornerProtectionCategoryTypeID" = 3
    WHERE ST_Length(new_corner_protection_geom) >= 16.0;

-- generate the dimensioning lines

UPDATE havering_operations."HaveringCorners" AS c
SET corner_dimension_lines_geom = ST_Multi(havering_operations."get_all_new_corner_dimension_lines"(c."GeometryID"))
WHERE havering_operations."get_all_new_corner_dimension_lines"(c."GeometryID") IS NOT NULL;

-- Now set up triggers to update details
/*
Triggers to be:
 - when corner_point_geom updated, update line_from_corner_point_geom. NB: The update of corner_point_geom should happen only once - and should happen before the trigger is create ??
 - when apex_point_geom updated, update line_from_apex_point_geom
 - when line_from_apex_point_geom updated, update new_corner_protection_geom and length_conforming_within_line_from_corner_point (and CornerProtectionCategoryTypeID??)
 - when new_corner_protection_geom updated, update corner_dimension_lines_geom
*/
