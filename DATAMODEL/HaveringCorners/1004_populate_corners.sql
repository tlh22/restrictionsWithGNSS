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
 SELECT d."GeometryID", ST_Length(havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance'))),
                havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance'))
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
SET apex_point_geom = havering_operations."getCornerApexPoint"(c."GeometryID", 10.0);  -- need to check this works!

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

-- Now recalculate the corner point ****

UPDATE havering_operations."HaveringCorners" AS c
SET corner_point_geom = ST_ClosestPoint(s.geom, c.apex_point_geom)
FROM havering_operations."HaveringCornerSegments" s
WHERE s."GeometryID" = c."GeometryID";

-- line_from_apex_point_geom

UPDATE havering_operations."HaveringCorners" AS c
SET line_from_apex_point_geom = ST_GeometryN(havering_operations."getCornerExtentsFromApex"(c."GeometryID"), 1);

-- new_junction_protection_geom

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
SET new_junction_protection_geom = ST_Multi(ST_Difference(ST_Multi(c.line_from_apex_point_geom), ST_Buffer(d.geom, 0.1)))
FROM havering_operations."HaveringCornerConformingSegments" d
WHERE d."GeometryID" = c."GeometryID";

UPDATE havering_operations."HaveringCorners" AS c
SET new_junction_protection_geom = ST_Multi(c.line_from_apex_point_geom)
WHERE c."GeometryID" NOT IN (
    SELECT d."GeometryID"
    FROM havering_operations."HaveringCornerConformingSegments" d);

-- classify corners

UPDATE havering_operations."HaveringCorners"
    SET "CornerProtectionCategoryTypeID" = 1
    WHERE ST_Length(new_junction_protection_geom) = 0.0
    OR ST_Length(new_junction_protection_geom) IS NULL;

UPDATE havering_operations."HaveringCorners"
    SET "CornerProtectionCategoryTypeID" = 2
    WHERE ST_Length(new_junction_protection_geom) > 0.0 and ST_Length(new_junction_protection_geom) < 16.0;

UPDATE havering_operations."HaveringCorners"
    SET "CornerProtectionCategoryTypeID" = 3
    WHERE ST_Length(new_junction_protection_geom) >= 16.0;

-- generate the dimensioning lines

UPDATE havering_operations."HaveringCorners" AS c
SET corner_dimension_lines_geom = ST_Multi(havering_operations."get_all_new_corner_dimension_lines"("GeometryID"))
WHERE havering_operations."get_all_new_corner_dimension_lines"("GeometryID") IS NOT NULL

-- Now set up triggers to update details

CREATE TRIGGER "update_corner_protection_line_from_corner_point"
    BEFORE INSERT OR UPDATE ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION "public"."set_last_update_details"();
