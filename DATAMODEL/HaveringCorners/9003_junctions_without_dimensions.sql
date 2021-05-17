--

SELECT DISTINCT w."NAME", j."GeometryID" --, COUNT(*)
FROM havering_operations."HaveringJunctions" j INNER JOIN local_authority."Wards" w ON ST_Within(j.junction_point_geom, w.geom)
WHERE "JunctionProtectionCategoryTypeID" IN (2, 3)
AND "MHTC_CheckIssueTypeID" = 1
AND j."GeometryID" IN
    (SELECT "JunctionID"
    FROM havering_operations."CornersWithinJunctions"
    WHERE "CornerID" in
        (SELECT "GeometryID"
        FROM havering_operations."HaveringCorners"
        WHERE "ShowDimensions" = 'false')
    )
ORDER BY w."NAME"
--GROUP BY w."NAME"