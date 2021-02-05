--

SELECT l."Description", Count(*)
FROM havering_operations."HaveringJunctions" j, havering_operations."JunctionProtectionCategoryTypes" l
WHERE j."JunctionProtectionCategoryTypeID" = l."Code"
AND "MHTC_CheckIssueTypeID" = 1
GROUP BY l."Description"