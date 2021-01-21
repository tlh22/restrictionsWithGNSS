--
-- set up corner protection parameter

INSERT INTO mhtc_operations.project_parameters(
	"Field", "Value")
	VALUES ('CornerProtectionDistance', 10.0);

-- lookups

INSERT INTO "havering_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (1, 'No action required - current markings in compliance');
INSERT INTO "havering_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (2, 'Action required - Current markings not in compliance');
INSERT INTO "havering_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (3, 'Action required - No current markings');
INSERT INTO "havering_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (4, 'Action required - Current markings correct - condition issues');

INSERT INTO "havering_operations"."JunctionProtectionCategoryTypes" ("Code", "Description") VALUES (1, 'No plan required');
INSERT INTO "havering_operations"."JunctionProtectionCategoryTypes" ("Code", "Description") VALUES (2, 'Plan required - additional markings required');
INSERT INTO "havering_operations"."JunctionProtectionCategoryTypes" ("Code", "Description") VALUES (3, 'Plan required - re-conditioning needed');
