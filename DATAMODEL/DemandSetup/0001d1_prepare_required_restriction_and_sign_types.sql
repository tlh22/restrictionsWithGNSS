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

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (225, 'LineString');  -- Unmarked kerbline

REFRESH MATERIALIZED VIEW "toms_lookups"."LineTypesInUse_View";

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (126, 'Polygon');  -- Limited Waiting

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (127, 'Polygon');  -- Free bays

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (131, 'Polygon');  -- Permit holder

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (152, 'LineString');  -- Unmarked parking area

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (122, 'LineString');  -- Bus Stand
	
INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (147, 'LineString');  -- Cycle hangar

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (168, 'LineString');  -- Dockless cycle and e-scooter bay
	
DELETE FROM toms_lookups."BayTypesInUse"
WHERE "Code" = 154;  -- Unmarked parking area (within controlled area)

REFRESH MATERIALIZED VIEW "toms_lookups"."BayTypesInUse_View";

/***
Add 0 into time periods
***/
INSERT INTO toms_lookups."TimePeriodsInUse"("Code")
VALUES (0);

REFRESH MATERIALIZED VIEW "toms_lookups"."TimePeriodsInUse_View";