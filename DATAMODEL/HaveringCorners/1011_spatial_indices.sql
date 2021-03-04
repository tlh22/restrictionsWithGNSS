-- add indices to the geom fields
CREATE INDEX "havering_corners_corner_point_geom_idx" ON havering_operations."HaveringCorners" USING "gist" ("corner_point_geom");
CREATE INDEX "havering_corners_apex_point_geom_idx" ON havering_operations."HaveringCorners" USING "gist" ("apex_point_geom");
CREATE INDEX "havering_corners_line_from_corner_point_geom_idx" ON havering_operations."HaveringCorners" USING "gist" ("line_from_corner_point_geom");
CREATE INDEX "havering_corners_line_from_apex_point_geom_idx" ON havering_operations."HaveringCorners" USING "gist" ("line_from_apex_point_geom");
CREATE INDEX "havering_corners_new_corner_protection_geom_idx" ON havering_operations."HaveringCorners" USING "gist" ("new_corner_protection_geom");
CREATE INDEX "havering_corners_corner_dimension_lines_geom_idx" ON havering_operations."HaveringCorners" USING "gist" ("corner_dimension_lines_geom");

CREATE INDEX "havering_junctions_junction_point_geom_idx" ON havering_operations."HaveringJunctions" USING "gist" ("junction_point_geom");
CREATE INDEX "havering_junctions_map_frame_geom_idx" ON havering_operations."HaveringJunctions" USING "gist" ("map_frame_geom");


CREATE INDEX "wards_geom_idx" ON local_authority."Wards" USING "gist" ("geom");