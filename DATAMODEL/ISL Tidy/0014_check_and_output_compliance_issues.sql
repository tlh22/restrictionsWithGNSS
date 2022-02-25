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
	   "RoadName", "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     ((((SELECT "GeometryID", "RestrictionTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes"
         FROM toms."Bays"
         WHERE "ComplianceRoadMarkingsFaded" IN (2,3,5,6)
         OR "ComplianceRestrictionSignIssue" IN (2,3,4,5) ) AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

--AND "Photos_01" IS NULL

--  Lines

UNION

SELECT "GeometryID", "BayLineTypes"."Description" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RoadName", "RestrictionRoadMarkingsFadedTypes1"."Description" AS "RoadMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "RestrictionRoadMarkingsFadedTypes2"."Description" AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     (((((SELECT "GeometryID", "RestrictionTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceLoadingMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes"
         FROM toms."Lines"
         WHERE "ComplianceRoadMarkingsFaded" IN (2,3,5,6)
         OR "ComplianceRestrictionSignIssue" IN (2,3,4,5)
         OR "ComplianceLoadingMarkingsFaded" IN (2,3,5,6) ) AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes1" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes1"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes2" ON a."ComplianceLoadingMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes2"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

--AND "Photos_01" IS NULL

-- RestrictionPolygons

UNION

SELECT "GeometryID", "RestrictionPolygonTypes"."Description" AS "RestrictionDescription", --a."ComplianceRoadMarkingsFaded",
	   "RoadName", "RestrictionRoadMarkingsFadedTypes"."Description" AS "RoadMarkingsFaded_Description",
	   '' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction_SignIssue_Description",
	   "ComplianceNotes", "Notes"
FROM
     (((toms."RestrictionPolygons" AS a
     LEFT JOIN "toms_lookups"."RestrictionPolygonTypes" AS "RestrictionPolygonTypes" ON a."RestrictionTypeID" is not distinct from "RestrictionPolygonTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
OR NOT (a."ComplianceRoadMarkingsFaded" = 4 AND a."ComplianceRestrictionSignIssue" = 1)
--AND "Photos_01" IS NULL

ORDER BY "GeometryID"
;

--  Signs

SELECT "GeometryID", "SignTypes"."Description" AS "Sign Type Description",
	   --a."ComplianceRestrictionSignIssue",
	   "RoadName", "Restriction_SignIssueTypes"."Description" AS "Restriction-Sign Issue Description",
	   	--a."SignConditionTypeID",
	   "SignConditionTypes"."Description" AS "Sign Condition Type Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((SELECT "GeometryID", "SignType_1", "RoadName", "SignConditionTypeID", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", geom
         FROM toms."Signs"
         WHERE "SignConditionTypeID" IN (2,3,5,6, 10)
         OR "ComplianceRestrictionSignIssue" IN (3,4,5) ) AS a
     LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON a."SignType_1" is not distinct from "SignTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")
     LEFT JOIN "compliance_lookups"."SignConditionTypes" AS "SignConditionTypes" ON a."SignConditionTypeID" is not distinct from "SignConditionTypes"."Code")

WHERE "ComplianceRestrictionSignIssue" <> 1
OR "SignConditionTypeID" <> 1
ORDER BY "GeometryID"
;

-- ** Moving Restrictions

--  CarriagewayMarkings

SELECT "GeometryID", 'CarriagewayMarkings' AS "Moving Traffic Type", "CarriagewayMarkingTypes"."Description" AS "Carriageway Type Description",

	   --a."ComplianceRestrictionSignIssue",
	   "RoadName" AS "Road Name", "Restriction_SignIssueTypes"."Description" AS "Restriction-Carriageway Marking Issue Description",
	   	--a."SignConditionTypeID",
	   	"RestrictionRoadMarkingsFadedTypes"."Description" AS "Road Markings Faded Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((SELECT "GeometryID", "CarriagewayMarkingType_1", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", geom
         FROM moving_traffic."CarriagewayMarkings"
         WHERE "MHTC_CheckIssueTypeID" = 1) AS a
     LEFT JOIN "moving_traffic_lookups"."CarriagewayMarkingTypes" AS "CarriagewayMarkingTypes" ON a."CarriagewayMarkingType_1" is not distinct from "CarriagewayMarkingTypes"."Code")
	 LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
ORDER BY "GeometryID"
;

-- AccessRestrictions

SELECT "GeometryID", 'AccessRestrictions' AS "Moving Traffic Type", "AccessRestrictionValues"."Description" AS "Restriction Description", --a."ComplianceRoadMarkingsFaded",
	   "RoadName" AS "Road Name",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "Road Markings Faded Description",
	   --'' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction-Sign Issue Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((
         SELECT "GeometryID", "AccessRestrictionTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", mt_capture_geom as geom
         FROM moving_traffic."AccessRestrictions"
         WHERE "MHTC_CheckIssueTypeID" = 1
         ) AS a
     LEFT JOIN moving_traffic_lookups."AccessRestrictionValues" AS "AccessRestrictionValues" ON a."AccessRestrictionTypeID" is not distinct from "AccessRestrictionValues"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- HighwayDedications

UNION

SELECT "GeometryID", 'HighwayDedications' AS "Moving Traffic Type", "DedicationValues"."Description" AS "Restriction Description", --a."ComplianceRoadMarkingsFaded",
	   "RoadName" AS "Road Name",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "Road Markings Faded Description",
	   --'' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction-Sign Issue Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((
         SELECT "GeometryID", "HighwayDedicationTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", ST_StartPoint(mt_capture_geom) as geom
         FROM moving_traffic."HighwayDedications" AS a
         WHERE "MHTC_CheckIssueTypeID" = 1
         ) AS a
     LEFT JOIN moving_traffic_lookups."DedicationValues" AS "DedicationValues" ON a."HighwayDedicationTypeID" is not distinct from "DedicationValues"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- RestrictionsForVehicles

UNION

SELECT "GeometryID", 'RestrictionsForVehicles' AS "Moving Traffic Type", "RestrictionTypeValues"."Description" AS "Restriction Description", --a."ComplianceRoadMarkingsFaded",
	   "RoadName" AS "Road Name",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "Road Markings Faded Description",
	   --'' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction-Sign Issue Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((
         SELECT "GeometryID", "RestrictionsForVehiclesTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", COALESCE(mt_capture_geom, ST_StartPoint(geom_linestring)) as geom
         FROM moving_traffic."RestrictionsForVehicles" AS a
         WHERE "MHTC_CheckIssueTypeID" = 1
         ) AS a
     LEFT JOIN moving_traffic_lookups."RestrictionTypeValues" AS "RestrictionTypeValues" ON a."RestrictionsForVehiclesTypeID" is not distinct from "RestrictionTypeValues"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- SpecialDesignations

UNION

SELECT "GeometryID", 'SpecialDesignations' AS "Moving Traffic Type", "SpecialDesignationTypes"."Description" AS "Restriction Description", --a."ComplianceRoadMarkingsFaded",
	   "RoadName" AS "Road Name",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "Road Markings Faded Description",
	   --'' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction-Sign Issue Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((
         SELECT "GeometryID", "SpecialDesignationTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", ST_StartPoint(mt_capture_geom)  as geom
         FROM moving_traffic."SpecialDesignations" AS a
         WHERE "MHTC_CheckIssueTypeID" = 1
         ) AS a
     LEFT JOIN moving_traffic_lookups."SpecialDesignationTypes" AS "SpecialDesignationTypes" ON a."SpecialDesignationTypeID" is not distinct from "SpecialDesignationTypes"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1
--AND "Photos_01" IS NULL

-- TurnRestrictions

UNION

SELECT "GeometryID", 'TurnRestrictions' AS "Moving Traffic Type", "TurnRestrictionValues"."Description" AS "Restriction Description", --a."ComplianceRoadMarkingsFaded",
	   "RoadName" AS "Road Name",
	   "RestrictionRoadMarkingsFadedTypes"."Description" AS "Road Markings Faded Description",
	   --'' AS "LoadingMarkingsFaded_Description",
	   --a."ComplianceRestrictionSignIssue",
	   "Restriction_SignIssueTypes"."Description" AS "Restriction-Sign Issue Description",
	   "ComplianceNotes" AS "Compliance Notes", "Notes" AS "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
FROM
     ((((
         SELECT "GeometryID", "TurnRestrictionTypeID", "RoadName", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceNotes", "Notes", ST_StartPoint(mt_capture_geom) as geom
         FROM moving_traffic."TurnRestrictions" AS a
         WHERE "MHTC_CheckIssueTypeID" = 1
         ) AS a
     LEFT JOIN moving_traffic_lookups."TurnRestrictionValues" AS "TurnRestrictionValues" ON a."TurnRestrictionTypeID" is not distinct from "TurnRestrictionValues"."Code")
     LEFT JOIN "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" AS "RestrictionRoadMarkingsFadedTypes" ON a."ComplianceRoadMarkingsFaded" is not distinct from "RestrictionRoadMarkingsFadedTypes"."Code")
     LEFT JOIN "compliance_lookups"."Restriction_SignIssueTypes" AS "Restriction_SignIssueTypes" ON a."ComplianceRestrictionSignIssue" is not distinct from "Restriction_SignIssueTypes"."Code")

WHERE "ComplianceRoadMarkingsFaded" <> 1
OR "ComplianceRestrictionSignIssue" <> 1

ORDER BY "GeometryID"
;


-- ** HighwayAssets

DO
$$DECLARE
    relevant_table record;
    squery TEXT = '';
    len_squery INTEGER;
BEGIN

    FOR relevant_table IN (
          select table_schema, table_name::text, concat(table_schema, '.', quote_ident(table_name))::regclass AS full_table_name
          from information_schema.columns
          where column_name = 'GeometryID'
          AND table_schema IN ('highway_assets')
          AND table_name != 'HighwayAssets'
        ) LOOP

			--RAISE NOTICE 'table: % ', relevant_table.full_table_name;

            IF LENGTH(squery) > 0 THEN
                squery = squery || ' UNION ';
            END IF;

			--squery = squery || format('%s', relevant_table.full_table_name);

			--RAISE NOTICE 'squery: % ', squery;

            squery = squery || format('
            SELECT "GeometryID", ''%1$s'' AS "HighwayAssetType", "RoadName",
                "AssetConditionTypes"."Description" AS "AssetCondition_Description",
                "Notes", ST_X(geom) As "Easting", ST_Y(geom) AS "Northing"
            FROM
            ((
                SELECT "GeometryID", "RoadName", "AssetConditionTypeID", "Notes"
                FROM %2$s
                WHERE "AssetConditionTypeID" IN (3)
                ) AS a
                LEFT JOIN "highway_asset_lookups"."AssetConditionTypes" AS "AssetConditionTypes" ON a."AssetConditionTypeID" is not distinct from "AssetConditionTypes"."Code")
           ', relevant_table.table_name, relevant_table.full_table_name);

	END LOOP;

	RAISE NOTICE 'squery: % ', squery;

    EXECUTE FORMAT ('COPY %1$s TO STDOUT WITH CSV HEADER', squery);
    --EXECUTE squery;

END$$;
