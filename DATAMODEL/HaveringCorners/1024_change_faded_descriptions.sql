/**
Improve and organise faded types
**/

UPDATE "compliance_lookups"."RestrictionRoadMarkingsFadedTypes"
SET "Description" = 'Good condition'
WHERE "Code" = 1;

UPDATE "compliance_lookups"."RestrictionRoadMarkingsFadedTypes"
SET "Description" = 'Satisfactory - Slightly faded marking'
WHERE "Code" = 2;

UPDATE "compliance_lookups"."RestrictionRoadMarkingsFadedTypes"
SET "Description" = 'Faded markings'
WHERE "Code" = 3;

UPDATE "compliance_lookups"."RestrictionRoadMarkingsFadedTypes"
SET "Description" = 'Very faded and/or missing markings'
WHERE "Code" = 5;

INSERT INTO "compliance_lookups"."RestrictionRoadMarkingsFadedTypes" ("Code", "Description") VALUES (7, 'None - No existing markings');
