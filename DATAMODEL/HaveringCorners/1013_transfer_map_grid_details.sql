/*
Need to move map grid details from Junctions to MapFrame
*/

-- Populate HaveringMapFramesAllowableScales

INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (1, '200');
INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (2, '250');
INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (3, '300');
INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (4, '350');
INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (5, '400');
INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (6, '450');
INSERT INTO "havering_operations"."HaveringMapFramesAllowableScales" ("Code", "Description") VALUES (7, '500');

-- Now transfer grids
INSERT INTO havering_operations."HaveringMapFrames" (

)
SELECT "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "CreateDateTime", "CreatePerson",
junction_point_geom, map_frame_geom, map_frame_orientation, map_scale, "JunctionProtectionCategoryTypeID", "RoadsAtJunction", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson"
	FROM havering_operations."HaveringJunctions";

-- Now deal with JunctionsWithinMapFrames

INSERT INTO havering_operations."JunctionsWithinMapFrames"(

)
SELECT ...null

