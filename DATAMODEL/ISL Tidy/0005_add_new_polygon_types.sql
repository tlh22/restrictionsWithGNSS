--

INSERT INTO "toms_lookups"."RestrictionPolygonTypes" ("Code", "Description") VALUES (31, 'Area with significant change since survey');

INSERT INTO toms_lookups."RestrictionPolygonTypesInUse" ("Code", "GeomShapeGroupType") VALUES(31, 'Polygon');

REFRESH MATERIALIZED VIEW "toms_lookups"."RestrictionPolygonTypesInUse_View";