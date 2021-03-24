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
(SELECT l."Description" AS "Category", "MHTC_CheckIssueTypeID" As "Status", j.junction_point_geom AS geom
FROM havering_operations."HaveringJunctions" j, havering_operations."JunctionProtectionCategoryTypes" l
WHERE j."JunctionProtectionCategoryTypeID" = l."Code"
) jn, local_authority."Wards" w
WHERE ST_Within(jn.geom, w.geom)
GROUP BY "Ward", "Category", "Status"
ORDER BY "Ward", "Category", "Status"