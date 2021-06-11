-- report all junctions

SELECT "GeometryID", "RoadsAtJunction", "Wards"."NAME" AS "Ward",
	   "JunctionProtectionCategoryTypes"."Description" AS "CategoryType",
	   "JunctionTypes"."Description" AS "JunctionType",
	   	"RestrictionRoadMarkingsFadedTypes_2"."Description" AS "StatusOtherRestrictions",
	   "RestrictionRoadMarkingsFadedTypes_1"."Description" AS "StatusExistingCornerProtection",
	   "RestrictionRoadMarkingsFadedTypes_2"."Description" AS "StatusOtherRestrictions",
	   "MHTC_CheckIssueTypes"."Description" AS "Status", "MHTC_CheckNotes", to_char("LastUpdateDateTime", 'DD Mon YY') AS "LastUpdated"

	FROM ((((((havering_operations."HaveringJunctions" j
     LEFT JOIN "havering_operations"."JunctionProtectionCategoryTypes" AS "JunctionProtectionCategoryTypes"
			ON j."JunctionProtectionCategoryTypeID" is not distinct from "JunctionProtectionCategoryTypes"."Code")
     LEFT JOIN "havering_operations"."JunctionTypes" AS "JunctionTypes"
			ON j."JunctionTypeID" is not distinct from "JunctionTypes"."Code")
     LEFT JOIN "compliance_lookups"."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes"
			ON j."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
	 LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes_1"
		    ON j."ExistingCornerProtectionRoadMarkingsConditionTypeID" is not distinct from "RestrictionRoadMarkingsFadedTypes_1"."Code")
	 LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes_2"
		    ON j."ExistingOtherRestrictionRoadMarkingsConditionTypeID" is not distinct from "RestrictionRoadMarkingsFadedTypes_2"."Code")
     INNER JOIN local_authority."Wards" AS "Wards" ON ST_Intersects(j.junction_point_geom, "Wards".geom))

