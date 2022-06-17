
/**
Include section
**/

INSERT INTO toms_lookups."LineTypesInUse"(
	"Code", "GeomShapeGroupType")
	VALUES (1000, 'LineString');

REFRESH MATERIALIZED VIEW "toms_lookups"."LineTypesInUse_View";


/**
add any time periods required
**/

/*
INSERT INTO toms_lookups."TimePeriodsInUse"("Code")
SELECT "Code"
FROM toms_lookups."TimePeriods"
WHERE "Code" IN (8, 253, 370, 496, 618, 619);

INSERT INTO toms_lookups."TimePeriodsInUse"("Code")
SELECT "Code"
FROM toms_lookups."TimePeriods"
WHERE "Code" IN (8, 253, 618, 619);

REFRESH MATERIALIZED VIEW "toms_lookups"."TimePeriodsInUse_View";
*/