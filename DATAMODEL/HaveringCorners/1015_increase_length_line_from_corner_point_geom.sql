--

UPDATE mhtc_operations.project_parameters
SET "Value" = 20.0
WHERE "Field" = 'CornerProtectionDistance';

ALTER TABLE havering_operations."HaveringCorners" DISABLE TRIGGER "update_corner_protection_line_4_from_apex_point";

UPDATE havering_operations."HaveringCorners"
SET corner_point_geom = corner_point_geom
--WHERE "GeometryID" = 'CO_23887'
;

ALTER TABLE havering_operations."HaveringCorners" ENABLE TRIGGER "update_corner_protection_line_4_from_apex_point";

-- reset corner protection distance. TODO: may need to think of another parameter

UPDATE mhtc_operations.project_parameters
SET "Value" = 10.0
WHERE "Field" = 'CornerProtectionDistance';