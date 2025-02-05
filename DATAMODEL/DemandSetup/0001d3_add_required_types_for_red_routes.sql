/**
 Include only required sign types
**/

INSERT INTO toms_lookups."SignTypesInUse"("Code")
    SELECT "Code"
	FROM toms_lookups."SignTypes"
	WHERE "Description" LIKE ('Parking - Red Route/Greenway%')
	AND "Code" NOT IN (SELECT "Code"
	                   FROM toms_lookups."SignTypesInUse")
	ORDER BY "Description";

REFRESH MATERIALIZED VIEW "toms_lookups"."SignTypesInUse_View";

/**
Ensure appropriate bay/line types for red routes
**/

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (128, 'LineString');  -- Red Route/Greenway - Loading Bay

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (141, 'LineString');  -- Red Route/Greenway - Loading Bay/Disabled Bay/Parking Bay

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (142, 'LineString');  -- Red Route/Greenway - Parking Bay

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (143, 'LineString');  -- Red Route/Greenway - Loading Bay/Parking Bay

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (160, 'LineString');  -- Red Route/Greenway - Disabled Bay

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (161, 'LineString');  -- Red Route/Greenway - Bus Stop

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (162, 'LineString');  -- Red Route Bus Stand

INSERT INTO toms_lookups."BayTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (164, 'LineString');  -- Red Route/Greenway - Taxi Rank

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (218, 'LineString');  -- DRL

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (226, 'LineString');  -- SRL

REFRESH MATERIALIZED VIEW "toms_lookups"."LineTypesInUse_View";
REFRESH MATERIALIZED VIEW "toms_lookups"."BayTypesInUse_View";

/**
add any time periods required
**/

/*
INSERT INTO toms_lookups."TimePeriodsInUse"("Code")
SELECT "Code"
FROM toms_lookups."TimePeriods"
WHERE "Code" IN (8, 253, 370, 385, 496, 618, 619);

INSERT INTO toms_lookups."TimePeriodsInUse"("Code")
SELECT "Code"
FROM toms_lookups."TimePeriods"
WHERE "Code" IN (8, 253, 618, 619);

REFRESH MATERIALIZED VIEW "toms_lookups"."TimePeriodsInUse_View";
*/