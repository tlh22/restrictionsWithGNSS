-- update 10m end end points

DELETE FROM havering_operations."HaveringCornerSegments"
WHERE "GeometryID" NOT IN (
SELECT "GeometryID" FROM havering_operations."HaveringCorners");

DELETE FROM havering_operations."HaveringCornerSegmentEndPts";

INSERT INTO havering_operations."HaveringCornerSegmentEndPts" ("GeometryID", "StartPt", "EndPt")
SELECT d."GeometryID", ST_StartPoint(d.geom), ST_EndPoint(d.geom)
FROM havering_operations."HaveringCornerSegments" d;

-- change structure of EndPts

ALTER TABLE havering_operations."HaveringCornerSegmentEndPts"
    RENAME "StartPt" TO "StartPt_10m";

ALTER TABLE havering_operations."HaveringCornerSegmentEndPts"
    RENAME "EndPt" TO "EndPt_10m";

ALTER TABLE havering_operations."HaveringCornerSegmentEndPts"
    ADD COLUMN "StartPt_15m" geometry(Point, 27700);

ALTER TABLE havering_operations."HaveringCornerSegmentEndPts"
    ADD COLUMN "EndPt_15m" geometry(Point, 27700);

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
                havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float+5.0)
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

-- update segment points
DELETE FROM havering_operations."HaveringCornerSegments"
WHERE "GeometryID" NOT IN (
SELECT "GeometryID" FROM havering_operations."HaveringCorners");

ALTER TABLE havering_operations."HaveringCornerSegmentEndPts" DROP CONSTRAINT "HaveringCornerSegmentEndPts_pkey";

INSERT INTO havering_operations."HaveringCornerSegmentEndPts" ("GeometryID", "StartPt_15m", "EndPt_15m")
SELECT d."GeometryID", ST_StartPoint(d.geom), ST_EndPoint(d.geom)
FROM havering_operations."HaveringCornerSegments" d;

DELETE FROM havering_operations."HaveringCornerSegmentEndPts" c1
WHERE "GeometryID" IN (
    SELECT "GeometryID"
    FROM (
        SELECT "GeometryID", count(*)
        FROM havering_operations."HaveringCornerSegmentEndPts"
        GROUP BY "GeometryID"
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY havering_operations."HaveringCornerSegmentEndPts"
    ADD CONSTRAINT "HaveringCornerSegmentEndPts_pkey" PRIMARY KEY ("GeometryID");

-- Also extend the corner area ...

UPDATE havering_operations."HaveringCorners" AS c
 SET line_from_corner_point_geom = s.geom
 FROM havering_operations."HaveringCornerSegments" s
 WHERE s."GeometryID" = c."GeometryID";