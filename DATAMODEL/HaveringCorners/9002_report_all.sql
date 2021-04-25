-- report all junctions

SELECT "GeometryID", "RoadsAtJunction", "Wards"."NAME" AS "Ward",
	   "JunctionProtectionCategoryTypes"."Description",
	   "MHTC_CheckIssueTypes"."Description" AS "Status", "MHTC_CheckNotes", to_char("LastUpdateDateTime", 'DD Mon YY') AS "LastUpdated"

	FROM (((havering_operations."HaveringJunctions" j
     LEFT JOIN "havering_operations"."JunctionProtectionCategoryTypes" AS "JunctionProtectionCategoryTypes"
			ON j."JunctionProtectionCategoryTypeID" is not distinct from "JunctionProtectionCategoryTypes"."Code")
     LEFT JOIN "compliance_lookups"."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes"
			ON j."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
	 INNER JOIN local_authority."Wards" AS "Wards" ON ST_Intersects(j.junction_point_geom, "Wards".geom))