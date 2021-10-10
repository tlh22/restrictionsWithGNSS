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
	OR "Code" IN (52, 53, 6183, 61842, 27, 61841, 6294, 618, 55, 56, 664, 102)  -- Zones
	OR "Code" IN (94, 9541, 57211, 9544, 620, 6202)  -- supplementary plates
	OR "Code" IN (0, 25, 37, 953, 9601, 9602, 642, 670, 64021)  -- Misc
	OR "Code" IN (5301, 779, 510, 521, 522, 5311)  -- Warning signs
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

-- Add field to roadlink to allow viewing of completed areas

ALTER TABLE highways_network.roadlink
    ADD COLUMN "Completed" boolean DEFAULT false NOT NULL;

ALTER TABLE highways_network.roadlink
    ADD COLUMN "LastUpdateDateTime" timestamp without time zone;

ALTER TABLE highways_network.roadlink
    ADD COLUMN "LastUpdatePerson" character varying(255);

GRANT SELECT, UPDATE ON TABLE highways_network.roadlink TO toms_operator, toms_admin;

-- Trigger trigger ... to populate update details
UPDATE highways_network.roadlink
SET "Completed" = true
WHERE "Completed" = true;

--
REVOKE ALL ON TABLE highways_network."MHTC_RoadLinks" FROM toms_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE highways_network."MHTC_RoadLinks" TO toms_admin;

REVOKE ALL ON TABLE highways_network."MHTC_RoadLinks" FROM toms_operator;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE highways_network."MHTC_RoadLinks" TO toms_operator;

REVOKE ALL ON TABLE mhtc_operations."SurveyAreas" FROM toms_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE mhtc_operations."SurveyAreas" TO toms_admin;

REVOKE ALL ON TABLE mhtc_operations."SurveyAreas" FROM toms_operator;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE mhtc_operations."SurveyAreas" TO toms_operator;


