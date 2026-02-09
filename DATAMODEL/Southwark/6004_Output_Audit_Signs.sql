/***

Output for Southwark audit

***/

-- Add "CPZ"

ALTER TABLE IF EXISTS toms."Signs"
	ADD COLUMN IF NOT EXISTS "CPZ" character varying(40) COLLATE pg_catalog."default";
	
UPDATE toms."Signs" AS s
SET "CPZ" = NULL;

UPDATE toms."Signs" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom)
;

UPDATE toms."Signs" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_Intersects (s.geom, a.geom)
AND s."CPZ" IS NULL;

-- Add "SouthwarkProposedDeliveryZoneID"

ALTER TABLE IF EXISTS toms."Signs"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE toms."Signs"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE toms."Signs" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE toms."Signs" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

-- Sort out special characters

UPDATE toms."Signs"
SET "Notes" = REGEXP_REPLACE("Notes",',','.', 'g') 
WHERE "Notes" LIKE '%,%';

UPDATE toms."Signs"
SET "Notes" = regexp_replace("Notes", E'[\\n\\r]+', '; ', 'g' )
WHERE "Notes" LIKE E'%\n%';

UPDATE toms."Signs"
SET "ComplianceNotes" = REGEXP_REPLACE("ComplianceNotes",',','.', 'g') 
WHERE "ComplianceNotes" LIKE '%,%';

UPDATE toms."Signs"
SET "ComplianceNotes" = regexp_replace("ComplianceNotes", E'[\\n\\r]+', '; ', 'g' )
WHERE "ComplianceNotes" LIKE E'%\n%';

--

ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs" AS c
SET "RoadName" = closest."RoadName"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id,
        ST_ClosestPoint(c1.geom, s.geom) AS geom,
        ST_Distance(c1.geom, s.geom) AS length, c1."name1" AS "RoadName"
      FROM toms."Signs" s, highways_network."roadlink" c1
      WHERE ST_DWithin(c1.geom, s.geom, 10.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;

--
ALTER TABLE IF EXISTS mhtc_operations."Signs_Audit_Issues"
	ADD COLUMN IF NOT EXISTS "CPZ" character varying(40) COLLATE pg_catalog."default";
	
INSERT INTO mhtc_operations."Signs_Audit_Issues"(
	"GeometryID"
	, "SouthwarkProposedDeliveryZoneName"
	, "RoadName"
	, "CPZ"
	, "SignTypeID"
	, "SignTypeDescription"
	, "ComplianceRestrictionSignIssueID"
	, "Restriction_Sign_Issue"
	, "SignConditionIssueID"
	, "Sign_Condition_Issue"
	, "ComplianceNotes"
	, "Notes"
	, "Easting"
	, "Northing"
	, "Photo"
	, geom)

SELECT "GeometryID"
	, "SouthwarkProposedDeliveryZoneName"
	, "RoadName"
	, "CPZ"
	, "SignTypeID"
	, "SignTypeDescription" AS "Sign_Type_Description"
	, "ComplianceRestrictionSignIssue" AS "ComplianceRestrictionSignIssueID"
	, "Restriction_SignIssue_Description" As "Restriction_Sign_Issue"
	, "Compl_Signs_Faded" AS "SignConditionIssueID"
	, "SignFadedTypes_Description" As "Sign_Condition_Issue"
	, "ComplianceNotes"
	, "Notes"
	, "Easting"
	, "Northing"
	, COALESCE("Photos_01", "Photos_02")  AS "Photo"
	, p.geom
FROM
(
	 SELECT "GeometryID", "RoadName"
	   , COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"
	   , "CPZ"
	   , a."SignType_1" AS "SignTypeID"
	   , "SignTypes"."Description" AS "SignTypeDescription"
	   , a."ComplianceRestrictionSignIssue"
	   , "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description"
	   	--a."SignConditionTypeID",
	   --"SignConditionTypes"."Description" AS "SignConditionTypes_Description",
	   , a."Compl_Signs_Faded"
	   , "SignFadedTypes"."Description" AS "SignFadedTypes_Description"
	   , "ComplianceNotes", "Notes", st_x(a.geom) AS "Easting", st_y(a.geom) AS "Northing", a.geom
	   , "Photos_01", "Photos_02"
	 FROM ((((((toms."Signs" AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code") 
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")
	 LEFT JOIN "compliance_lookups"."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes" ON a."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
	 LEFT JOIN "compliance_lookups"."SignFadedTypes" AS "SignFadedTypes" ON a."Compl_Signs_Faded" is not distinct from "SignFadedTypes"."Code")
	 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid")
	WHERE (	
	"ComplianceRestrictionSignIssue" > 1 OR
	"SignConditionTypeID" > 1 OR
	"Compl_Signs_Faded" > 1
	)
	--AND COALESCE("ComplianceRestrictionSignIssue", 1) = 1
	AND COALESCE("MHTC_CheckIssueTypeID", 1) = 1
) p
--	 , import_geojson."SouthwarkProposedDeliveryZones" z

--WHERE (ST_Within(p.geom, z.geom))
	--AND z.zonename IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'))
	--AND z.zonename IN ('A', 'B', 'S1'))

ORDER BY "SignTypeDescription"

/***
-- Copy photos ...

--SELECT CONCAT('copy ', su."Photos_01", ' "../Photos_Audit_Signs/', su."RoadName", '_', su."Photos_01", '"')
SELECT CONCAT('copy ', su."Photos_01", ' "../Photos_Audit_Signs/', su."Photos_01", '"')
FROM toms."Signs" su, import_geojson."SouthwarkProposedDeliveryZones" z
WHERE su."Photos_01" IS NOT NULL
AND (ST_Within(su.geom, z.geom)
AND z.zonename IN ('A', 'B'))

UNION

SELECT CONCAT('copy ', su."Photos_02", ' "../Photos_Audit_Signs/', su."Photos_02", '"')
FROM toms."Signs" su, import_geojson."SouthwarkProposedDeliveryZones" z
WHERE su."Photos_02" IS NOT NULL
AND (ST_Within(su.geom, z.geom)
AND z.zonename IN ('A', 'B'))




SELECT CONCAT('copy ', "Photos_01", ' "../Photos_Audit_Signs/', "Photos_01", '"')
FROM
(
	 SELECT "GeometryID", "RoadName", "SignTypes"."Description" AS "SignTypeDescription",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   	--a."SignConditionTypeID",
	   --"SignConditionTypes"."Description" AS "SignConditionTypes_Description",
	   a."Compl_Signs_Faded",
	   "SignFadedTypes"."Description" AS "SignFadedTypes_Description",
	   "ComplianceNotes", "Notes", st_x(geom) AS "Easting", st_y(geom) AS "Northing", geom
	   , "Photos_01", "Photos_02"
	 FROM (((((toms."Signs" AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code") 
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")
	 LEFT JOIN "compliance_lookups"."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes" ON a."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
	 LEFT JOIN "compliance_lookups"."SignFadedTypes" AS "SignFadedTypes" ON a."Compl_Signs_Faded" is not distinct from "SignFadedTypes"."Code")
	WHERE (	
	"ComplianceRestrictionSignIssue" > 1 OR
	"SignConditionTypeID" > 1 OR
	"Compl_Signs_Faded" > 1
	)
	--AND COALESCE("ComplianceRestrictionSignIssue", 1) = 1
	AND COALESCE("MHTC_CheckIssueTypeID", 1) = 1
) p
	 , import_geojson."SouthwarkProposedDeliveryZones" z

WHERE (ST_Within(p.geom, z.geom)
	--AND z.zonename IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'))
	AND z.zonename IN ('A', 'B', 'S1'))

ORDER BY "SignTypeDescription"


***/

/***

To get an idea of the total number - taking account of those that are linked


SELECT "GeometryID", "RoadName", "SignTypeDescription" AS "Sign_Type_Description",
	   "Restriction_SignIssue_Description" As "Restriction_Sign_Issue",
	   --"SignConditionTypes_Description",
	   "SignFadedTypes_Description" As "Sign_Condition_Issue",
	   "ComplianceNotes", "Notes", "Easting", "Northing"
	   , COALESCE("Photos_01", "Photos_02")  AS "Photo"
	   , p.geom
FROM
(
	 SELECT "GeometryID", "RoadName", "SignTypes"."Description" AS "SignTypeDescription",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   	--a."SignConditionTypeID",
	   --"SignConditionTypes"."Description" AS "SignConditionTypes_Description",
	   a."Compl_Signs_Faded",
	   "SignFadedTypes"."Description" AS "SignFadedTypes_Description",
	   "ComplianceNotes", "Notes", st_x(geom) AS "Easting", st_y(geom) AS "Northing", geom
	   , "Photos_01", "Photos_02"
	 FROM (((((toms."Signs" AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code") 
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")
	 LEFT JOIN "compliance_lookups"."MHTC_CheckIssueTypes" AS "MHTC_CheckIssueTypes" ON a."MHTC_CheckIssueTypeID" is not distinct from "MHTC_CheckIssueTypes"."Code")
	 LEFT JOIN "compliance_lookups"."SignFadedTypes" AS "SignFadedTypes" ON a."Compl_Signs_Faded" is not distinct from "SignFadedTypes"."Code")
	WHERE (	
	"ComplianceRestrictionSignIssue" > 1 --OR
	--"SignConditionTypeID" > 1 OR
	--"Compl_Signs_Faded" > 1
	)
	--AND COALESCE("ComplianceRestrictionSignIssue", 1) > 1
	--AND COALESCE("MHTC_CheckIssueTypeID", 1) = 1
) p
	 , import_geojson."SouthwarkProposedDeliveryZones" z

WHERE (ST_Within(p.geom, z.geom)
	--AND z.zonename IN ('C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'))
	--AND z.zonename IN ('A', 'B', 'S1'))

ORDER BY "SignTypeDescription"

***/


