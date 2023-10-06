-- Check how well match was made

-- Find any where there is 1:1 match

SELECT "RestrictionGeometryID"
FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_RoadMarkings_Lines" l
WHERE SfR."RestrictionGeometryID" = l."GeometryID"
GROUP BY "RestrictionGeometryID"
HAVING COUNT("RestrictionGeometryID") = 1

-- Find any where there is more than one sign and that all the signs are the same

SELECT p."RestrictionGeometryID", l.geom
FROM local_authority."Gaist_RoadMarkings_Lines" l, 
	(SELECT "RestrictionGeometryID"
	 FROM (SELECT SfR."RestrictionGeometryID", s."Dft Diagra", s."MHTC_TimePeriodCode", s."MHTC_MaxStayCode", s."MHTC_NoReturnCode"
		  FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_Signs" s
		  WHERE SfR."SignGeometryID" = s."GeometryID") d
	 GROUP BY "RestrictionGeometryID"
	 HAVING COUNT("RestrictionGeometryID") = 1
	) p
WHERE l."GeometryID" = p."RestrictionGeometryID"

SELECT "RestrictionGeometryID"
FROM (SELECT SfR."RestrictionGeometryID", s."Dft Diagra", s."MHTC_TimePeriodCode", s."MHTC_MaxStayCode", s."MHTC_NoReturnCode"
	  FROM "mhtc_operations"."SignsForRestrictions" SfR, local_authority."Gaist_Signs" s
	  WHERE SfR."SignGeometryID" = s."GeometryID")
HAVING COUNT("RestrictionGeometryID") = 1

-- signs without restriction
SELECT "GeometryID"
FROM local_authority."Gaist_Signs" s
WHERE s."GeometryID" NOT IN (
	SELECT "Sign_geometryID"
	FROM "mhtc_operations"."SignsForRestrictions" SfR)
	
	
-- List of sign types found
SELECT DISTINCT s."Dft Diagra", t.*
FROM local_authority."Gaist_Signs" s LEFT JOIN toms_lookups."SignTypes" t ON s."Dft Diagra" = t."TSRGD_Diagram"
ORDER BY s."Dft Diagra"

-- List of sign types found
SELECT DISTINCT s."Dft Diagra", t.*
FROM local_authority."Gaist_Signs" s LEFT JOIN toms_lookups."SignTypes" t ON s."Dft Diagra" = t."TSRGD_Diagram"
ORDER BY s."Dft Diagra"

SELECT DISTINCT s."Dft Diagra", t."Code", t."Description", t."TSRGD_Diagram", COUNT(s."Dft Diagra")
FROM local_authority."Gaist_Signs" s LEFT JOIN toms_lookups."SignTypes" t ON s."Dft Diagra" = t."TSRGD_Diagram"
GROUP BY s."Dft Diagra", t."Code", t."Description", t."TSRGD_Diagram"
ORDER BY s."Dft Diagra"

-- List of restriction types provided

SELECT "Dft Diagra", COUNT("Dft Diagra")
--, "RestrictionTypeID", "TimePeriodID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID"
	FROM local_authority."Gaist_RoadMarkings_Lines"
	GROUP BY "Dft Diagra"
	;
