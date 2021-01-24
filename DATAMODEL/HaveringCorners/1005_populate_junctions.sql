

-- populate junctions

INSERT INTO havering_operations."HaveringJunctions" ("RestrictionID", junction_point_geom, "AssetConditionTypeID",
"LastUpdateDateTime", "LastUpdatePerson", "CreateDateTime", "CreatePerson")
SELECT uuid_generate_v4(), geom, 0, now(), current_user, now(), current_user
FROM highways_network."Nodes";

-- remove any junctions that are not close to corners

DELETE FROM havering_operations."HaveringJunctions"
WHERE "GeometryID" IN (
    SELECT j."GeometryID"
    FROM havering_operations."HaveringJunctions" j,
    (SELECT ST_Union(apex_point_geom) As geom
    FROM havering_operations."HaveringCorners") c
    WHERE NOT ST_DWithin (j.junction_point_geom, c.geom, 30.0)
);

-- Identify junctions that are close to other junctions - and choose first

DROP TABLE IF EXISTS havering_operations.unique_junction_points CASCADE;

CREATE TABLE havering_operations.unique_junction_points AS
  SELECT  "GeometryID", ST_ClusterDBSCAN(junction_point_geom, eps := 10.0, minpoints := 2)  over () AS cid
    FROM    havering_operations."HaveringJunctions";

DELETE FROM havering_operations.unique_junction_points a
WHERE a.ctid <> (SELECT min(b.ctid)
                 FROM   havering_operations.unique_junction_points b
                 WHERE  a.cid = b.cid)
AND a.cid IS NOT NULL;

DELETE FROM havering_operations."HaveringJunctions"
WHERE "GeometryID" NOT IN (
    SELECT j."GeometryID"
    FROM havering_operations.unique_junction_points j
);

DROP TABLE IF EXISTS havering_operations.unique_junction_points CASCADE;

-- Associate corners with junctions

INSERT INTO havering_operations."CornersWithinJunctions" ("CornerID", "JunctionID")
SELECT c."GeometryID" AS "CornerID", havering_operations."get_nearest_junction_to_corner"(c."GeometryID") AS "JunctionID"
FROM havering_operations."HaveringCorners" c
WHERE havering_operations."get_nearest_junction_to_corner"(c."GeometryID") IS NOT NULL;

-- ** need to classify junctions

UPDATE havering_operations."HaveringJunctions" AS j
    SET "JunctionProtectionCategoryTypeID" = 1
--SELECT "GeometryID"
--FROM havering_operations."HaveringJunctions" AS j
WHERE 0 = (
SELECT COUNT(*)
FROM havering_operations."CornersWithinJunctions" cj, havering_operations."HaveringCorners" c
WHERE cj."JunctionID" = j."GeometryID"
AND cj."CornerID" = c."GeometryID"
AND c."CornerProtectionCategoryTypeID" != 1
);

UPDATE havering_operations."HaveringJunctions" AS j
    SET "JunctionProtectionCategoryTypeID" = 2
    WHERE "JunctionProtectionCategoryTypeID" != 1
    OR "JunctionProtectionCategoryTypeID" IS NULL;

-- Add frames
UPDATE havering_operations."HaveringJunctions"
SET map_frame_geom = ST_MakeEnvelope(ST_X(junction_point_geom)-20.0, ST_Y(junction_point_geom)-25.0,
                                     ST_X(junction_point_geom)+20.0, ST_Y(junction_point_geom)+25.0, 27700)
WHERE "JunctionProtectionCategoryTypeID" != 1;

-- update road details
UPDATE havering_operations."HaveringJunctions" AS j
SELECT DISTINCT(name1)
FROM highways_network.roadlink r
WHERE ST_DWithin ST_Intersects (r.junction_point_geom, r.geom, 0.1);

-- triggers for junctions

-- if "JunctionProtectionCategoryTypeID" = 1 then delete frame - or set from if not

DROP TRIGGER IF EXISTS "update_corners_within_junctions" ON havering_operations."HaveringJunctions";

CREATE TRIGGER "update_corners_within_junctions"
    AFTER INSERT ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_corners_within_junctions"();

DROP TRIGGER IF EXISTS "update_junction_map_frame_geom" ON havering_operations."HaveringJunctions";

CREATE TRIGGER "update_junction_map_frame_geom"
    AFTER INSERT OR UPDATE OF "JunctionProtectionCategoryTypeID" ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_junction_map_frame_geom"();

DROP TRIGGER IF EXISTS "update_roads_for_junctions" ON havering_operations."HaveringJunctions";

CREATE TRIGGER "update_roads_for_junctions"
    AFTER INSERT OR UPDATE OF "junction_point_geom" ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_roads_for_junctions"();

-- now trigger this trigger
UPDATE havering_operations."HaveringJunctions"
SET "junction_point_geom" = "junction_point_geom";