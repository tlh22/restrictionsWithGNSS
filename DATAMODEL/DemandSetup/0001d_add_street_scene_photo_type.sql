/**
 Add street scene

**/

INSERT INTO toms_lookups."SignTypesInUse"(
	"Code")
	VALUES (9999);

REFRESH MATERIALIZED VIEW "toms_lookups"."SignTypesInUse_View";