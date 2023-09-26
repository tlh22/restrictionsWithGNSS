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
