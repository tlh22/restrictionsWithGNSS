/**
 Include only required sign types
**/

DELETE FROM toms_lookups."SignTypesInUse";

INSERT INTO toms_lookups."SignTypesInUse"("Code")
    SELECT "Code"
	FROM toms_lookups."SignTypes"
	WHERE "Description" LIKE ('Parking%')
	OR "Description" LIKE ('Zone%')
	OR "Code" IN (0, 37, 9999)
	ORDER BY "Description";

REFRESH MATERIALIZED VIEW "toms_lookups"."SignTypesInUse_View";

/**
Ensure appropriate bay/line types
**/

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (126, 'Polygon');  -- Limited Waiting

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (225, 'LineString');  -- Unmarked kerbline

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (218, 'LineString');  -- DRL

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (226, 'LineString');  -- SRL

REFRESH MATERIALIZED VIEW "toms_lookups"."LineTypesInUse_View";
REFRESH MATERIALIZED VIEW "toms_lookups"."BayTypesInUse_View";