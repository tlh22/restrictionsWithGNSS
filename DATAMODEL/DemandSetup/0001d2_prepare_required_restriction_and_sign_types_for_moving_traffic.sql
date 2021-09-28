/**
 Include only required sign types
**/

-- Signs
DELETE FROM toms_lookups."SignTypesInUse";

INSERT INTO toms_lookups."SignTypesInUse"("Code")
    SELECT "Code"
	FROM toms_lookups."SignTypes"
	WHERE "Description" LIKE ('Access Restriction%')
	OR "Description" LIKE ('Banned Turn%')
	OR "Description" LIKE ('Compulsory Turn%')
	OR "Description" LIKE ('Cycling%')
	OR "Description" LIKE ('One Way%')
	OR "Description" LIKE ('Other moves%')
	OR "Description" LIKE ('Physical restriction%')
	OR "Description" LIKE ('Special Lane%')
	OR "Description" LIKE ('Speed%')
	OR "Code" IN (52, 53, 6183, 61842, 27, 61841, 6294, 618, 55, 56, 664)  -- Zones
	OR "Code" IN (0, 25, 37, 953, 9541, 9544, 620, 6202, 57211, 9601, 9602, 642, 670)  -- Misc
	ORDER BY "Description";

REFRESH MATERIALIZED VIEW "toms_lookups"."SignTypesInUse_View";

-- RestrictionPolygons

DELETE FROM toms_lookups."RestrictionPolygonTypesInUse";

INSERT INTO toms_lookups."RestrictionPolygonTypesInUse"("Code", "GeomShapeGroupType")
    SELECT "Code", 'Polygon'
	FROM toms_lookups."RestrictionPolygonTypes"
	WHERE "Code" IN (3, 6, 7, 9, 11, 31, 50)
	ORDER BY "Description";

REFRESH MATERIALIZED VIEW "toms_lookups"."RestrictionPolygonTypesInUse_View";


