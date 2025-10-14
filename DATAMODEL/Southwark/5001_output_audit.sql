/***

Output for Southwark audit

***/


-- Sort out commas

UPDATE toms."Signs"
SET "Notes" = REGEXP_REPLACE("Notes",',','.', 'g') 
WHERE "Notes" LIKE '%,%';

UPDATE toms."Signs"
SET "ComplianceNotes" = REGEXP_REPLACE("Notes",',','.', 'g') 
WHERE "ComplianceNotes" LIKE '%,%';

-- Line breaks ??


--

SELECT "GeometryID", "SignTypeDescription",
	   "Restriction_SignIssue_Description",
	   --"SignConditionTypes_Description",
	   "SignFadedTypes_Description",
	   "ComplianceNotes", "Notes", "Easting", "Northing" 
FROM
(
	 SELECT "GeometryID", "SignTypes"."Description" AS "SignTypeDescription",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   	--a."SignConditionTypeID",
	   --"SignConditionTypes"."Description" AS "SignConditionTypes_Description",
	   a."Compl_Signs_Faded",
	   "SignFadedTypes"."Description" AS "SignFadedTypes_Description",
	   "ComplianceNotes", "Notes", st_x(geom) AS "Easting", st_y(geom) AS "Northing", geom
	 FROM (((((toms."Signs" AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code") 
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")
	 LEFT JOIN "compliance_lookups"."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes" ON a."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
	 LEFT JOIN "compliance_lookups"."SignFadedTypes" AS "SignFadedTypes" ON a."Compl_Signs_Faded" is not distinct from "SignFadedTypes"."Code")
	WHERE ("ComplianceRestrictionSignIssue" > 1
	OR "SignConditionTypeID" > 1
	OR "Compl_Signs_Faded" > 1
	)
	AND "MHTC_CheckIssueTypeID" = 1
) p
	 , import_geojson."SouthwarkProposedDeliveryZones" z

WHERE (ST_Within(p.geom, z.geom)
	AND z.zonename IN ('A', 'B'))

ORDER BY "SignTypeDescription"

