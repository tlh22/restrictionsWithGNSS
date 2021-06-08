--

SELECT l."Description", Count(*)
FROM havering_operations."HaveringJunctions" j, havering_operations."JunctionProtectionCategoryTypes" l
WHERE j."JunctionProtectionCategoryTypeID" = l."Code"
AND "MHTC_CheckIssueTypeID" = 1
GROUP BY l."Description";


SELECT w."NAME" AS "Ward", jn."Category", Count(*) AS Total
FROM
    (SELECT l."Description" AS "Category", j.junction_point_geom AS geom
    FROM havering_operations."HaveringJunctions" j, havering_operations."JunctionProtectionCategoryTypes" l
    WHERE j."JunctionProtectionCategoryTypeID" = l."Code"
    AND "MHTC_CheckIssueTypeID" = 1 ) jn, local_authority."Wards" w
WHERE ST_Within(jn.geom, w.geom)
GROUP BY "Ward", "Category"
ORDER BY "Ward", "Category"


--
SELECT w."NAME" AS "Ward", jn."Category", jn."Status", Count(*) AS Total
FROM
(SELECT "JunctionProtectionCategoryTypes"."Description" AS "Category", "MHTC_CheckIssueTypes"."Description" As "Status", j.junction_point_geom AS geom
FROM ((havering_operations."HaveringJunctions" j
LEFT JOIN havering_operations."JunctionProtectionCategoryTypes" AS "JunctionProtectionCategoryTypes" ON j."JunctionProtectionCategoryTypeID" is not distinct from "JunctionProtectionCategoryTypes"."Code")
LEFT JOIN compliance_lookups."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes" ON j."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
) AS jn, local_authority."Wards" w
WHERE ST_Within(jn.geom, w.geom)
GROUP BY "Ward", "Category", "Status"
ORDER BY "Ward", "Category", "Status"



-- 210331

SELECT * FROM havering_operations."HaveringMapFrames"
WHERE "GeometryID" IN (SELECT "MapFrameID" FROM
(
SELECT w."NAME" AS "Ward", "MapFrameID", d."JunctionProtectionCategoryTypeID"
FROM
   (SELECT DISTINCT "MapFrameID", "JunctionProtectionCategoryTypeID", junction_point_geom As geom
    FROM havering_operations."JunctionsWithinMapFrames" l, havering_operations."HaveringJunctions" j
    WHERE j."GeometryID" = l."JunctionID"
    AND "JunctionProtectionCategoryTypeID" IN (2, 3)
    AND "MHTC_CheckIssueTypeID" = 1) d INNER JOIN local_authority."Wards" w ON ST_Within(d.geom, w.geom)
    WHERE w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
) m )


--
SELECT w."NAME" AS "Ward", "MapFrameID", d."JunctionProtectionCategoryTypeID"
FROM
(SELECT DISTINCT "MapFrameID", "JunctionProtectionCategoryTypeID", junction_point_geom As geom
    FROM havering_operations."JunctionsWithinMapFrames" l, havering_operations."HaveringJunctions" j
    WHERE j."GeometryID" = l."JunctionID"
    AND "JunctionProtectionCategoryTypeID" IN (2, 3)
    AND "MHTC_CheckIssueTypeID" = 1) d INNER JOIN local_authority."Wards" w ON ST_Within(d.geom, w.geom)
    WHERE w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
    AND "MapFrameID" NOT IN (SELECT "GeometryID" FROM havering_operations."HaveringMapFrames")


-- distinct map frames wtihin Ward

SELECT w."NAME", mf."GeometryID" --, COUNT(*)
FROM havering_operations."HaveringMapFrames" mf INNER JOIN local_authority."Wards" w ON ST_Within(mf.map_frame_centre_point_geom, w.geom)
WHERE w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
AND "HaveringMapFramesCategoryTypeID" IN (2, 3)



SELECT w."NAME", mf."MHTC_CheckIssueTypeID"
	   , COUNT(*)
FROM havering_operations."HaveringMapFrames" mf INNER JOIN local_authority."Wards" w ON ST_Within(mf.map_frame_centre_point_geom, w.geom)
WHERE w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
-- AND "HaveringMapFramesCategoryTypeID" IN (2, 3)
AND "MHTC_CheckIssueTypeID" = 1
GROUP BY w."NAME"
 --, mf."MHTC_CheckIssueTypeID"


-- distinct junctions


SELECT w."NAME", j."GeometryID" --, COUNT(*)
FROM havering_operations."HaveringJunctions" j INNER JOIN local_authority."Wards" w ON ST_Within(j.junction_point_geom, w.geom)
WHERE w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
AND "JunctionProtectionCategoryTypeID" IN (2, 3)
AND "MHTC_CheckIssueTypeID" = 1
GROUP BY w."NAME"


SELECT w."NAME"--, j."GeometryID" --
		, j."JunctionProtectionCategoryTypeID"
		, COUNT(*)
FROM havering_operations."HaveringJunctions" j INNER JOIN local_authority."Wards" w ON ST_Within(j.junction_point_geom, w.geom)
WHERE "MHTC_CheckIssueTypeID" = 1
--AND "JunctionProtectionCategoryTypeID" IN (2, 3)
--AND w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
GROUP BY w."NAME", j."JunctionProtectionCategoryTypeID"
ORDER BY w."NAME"


--

SELECT DISTINCT "JunctionID"
FROM havering_operations."JunctionsWithinMapFrames"
WHERE "MapFrameID" IN (


SELECT DISTINCT "GeometryID"
FROM havering_operations."HaveringMapFrames"
WHERE "GeometryID" IN
(SELECT DISTINCT "MapFrameID"
FROM havering_operations."JunctionsWithinMapFrames"
WHERE "JunctionID" IN
(
SELECT j."GeometryID" --, COUNT(*)
FROM havering_operations."HaveringJunctions" j INNER JOIN local_authority."Wards" w ON ST_Within(j.junction_point_geom, w.geom)
WHERE w."NAME" IN ('Havering Park Ward', 'Mawneys Ward')
AND "JunctionProtectionCategoryTypeID" IN (2, 3)
AND "MHTC_CheckIssueTypeID" = 1
--GROUP BY w."NAME"
	))
 AND "MHTC_CheckIssueTypeID" != 1

	)