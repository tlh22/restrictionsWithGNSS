/**

**/

SELECT "GeometryID"
FROM havering_operations."HaveringJunctions"
WHERE "MHTC_CheckIssueTypeID" = 1
AND "JunctionProtectionCategoryTypeID" in (2,3)
AND "GeometryID" NOT IN (
	SELECT "JunctionID"
    FROM havering_operations."JunctionsWithinMapFrames" jmf, havering_operations."HaveringMapFrames" mf
    WHERE jmf."MapFrameID" = mf."GeometryID"
	AND mf."MHTC_CheckIssueTypeID" = 1
	AND mf."HaveringMapFramesCategoryTypeID" in (2,3)
)
ORDER BY "GeometryID"