-- check that compliance issues have notes/photo etc

SELECT "GeometryID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes"
FROM toms."Bays"
WHERE "ComplianceRoadMarkingsFaded" <> 1
AND "ComplianceRestrictionSignIssue" <> 1
AND "Photos_01" IS NULL;

SELECT "GeometryID", "ComplianceRoadMarkingsFaded", "ComplianceLoadingMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Photos_01"
FROM toms."Lines"
WHERE "ComplianceRoadMarkingsFaded" <> 1
AND "ComplianceRestrictionSignIssue" <> 1
AND "ComplianceLoadingMarkingsFaded" <> 1
AND "Photos_01" IS NULL;

-- Find incorrect issue on Lines for LoadingMarkings - "Markings not correctly removed". There is no other issue and no photo.

SELECT "GeometryID", "BayLineTypes"."Description" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes1"."Description" AS "RoadMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "RestrictionRoadMarkingsFadedTypes2"."Description" AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes"
FROM
     ((((toms."Lines" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes1" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes1"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes2" ON a."ComplianceLoadingMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes2"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE
 "ComplianceLoadingMarkingsFaded" = 4
AND ("Photos_01" IS NULL AND "Photos_02" IS NULL AND "Photos_03" IS NULL)
AND "ComplianceRoadMarkingsFaded" = 1
AND "ComplianceRestrictionSignIssue" = 1;


ALTER TABLE toms."Lines" DISABLE TRIGGER all;

UPDATE toms."Lines"
SET "ComplianceLoadingMarkingsFaded" = 1
WHERE "ComplianceLoadingMarkingsFaded" = 4
AND "ComplianceRoadMarkingsFaded" = 1
AND "ComplianceRestrictionSignIssue" = 1
AND ("Photos_01" IS NULL AND "Photos_02" IS NULL AND "Photos_03" IS NULL);

ALTER TABLE toms."Lines" ENABLE TRIGGER all;

-- Check for incorrect "Lighting to be replaced" issue on Signs

SELECT "GeometryID", "SignTypes"."Description" AS "SignTypeDescription",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   	--a."SignConditionTypeID",
	   "SignConditionTypes"."Description" AS "SignConditionTypes_Description",
	   "ComplianceNotes", "Notes"
FROM
     (((toms."Signs" AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")

WHERE "ComplianceRestrictionSignIssue" = 1
AND "SignConditionTypeID" = 4
AND "ComplianceNotes" IS NULL
AND "Notes" IS NULL
;

ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "SignConditionTypeID" = 1
WHERE "SignConditionTypeID" = 4
AND "ComplianceRestrictionSignIssue" = 1
AND "ComplianceNotes" IS NULL
AND "Notes" IS NULL;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- *** Output issues

-- Bays

SELECT "GeometryID", "BayLineTypes"."Description" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     (((toms."Bays" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

--  Lines

UNION

SELECT "GeometryID", "BayLineTypes"."Description" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes1"."Description" AS "RoadMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "RestrictionRoadMarkingsFadedTypes2"."Description" AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((((toms."Lines" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes1" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes1"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes2" ON a."ComplianceLoadingMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes2"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceLoadingMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- RestrictionPolygons

UNION

SELECT "GeometryID", "BayLineTypes"."Description" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     (((toms."RestrictionPolygons" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

ORDER BY "GeometryID"
;

--  Signs

SELECT "GeometryID", "SignTypes"."Description" AS "SignTypeDescription",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   	--a."SignConditionTypeID",
	   "SignConditionTypes"."Description" AS "SignConditionTypes_Description",
	   "ComplianceNotes", "Notes"
FROM
     (((toms."Signs" AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")

WHERE "ComplianceRestrictionSignIssue" <> 1
OR "SignConditionTypeID" <> 1
;

-- ** Moving Restrictions

-- AccessRestrictions

SELECT "GeometryID", a.restriction AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((moving_traffic."AccessRestrictions" AS a
     --LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- HighwayDedications

UNION

SELECT "GeometryID", a.dedication AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((moving_traffic."HighwayDedications" AS a
     --LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- RestrictionsForVehicles

UNION

SELECT "GeometryID", a."restrictionType" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((moving_traffic."RestrictionsForVehicles" AS a
     --LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- SpecialDesignations

UNION

SELECT "GeometryID", a."designation" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((moving_traffic."SpecialDesignations" AS a
     --LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- TurnRestrictions

UNION

SELECT "GeometryID", a."restrictionType" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((moving_traffic."TurnRestrictions" AS a
     --LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1

ORDER BY "GeometryID"
;


-- ** HighwayAssets
