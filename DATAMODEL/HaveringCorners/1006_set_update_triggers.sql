-- set up update triggers
DROP TRIGGER IF EXISTS "set_last_update_details_havering_corners" ON havering_operations."HaveringCorners";
CREATE TRIGGER "set_last_update_details_havering_corners" BEFORE INSERT OR UPDATE ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION "public"."set_last_update_details"();

DROP TRIGGER IF EXISTS "set_last_update_details_havering_junctions" ON havering_operations."HaveringJunctions";
CREATE TRIGGER "set_last_update_details_havering_junctions" BEFORE INSERT OR UPDATE ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION "public"."set_last_update_details"();

-- corner triggers

DROP TRIGGER IF EXISTS "update_corner_protection_line_1_from_corner_point" ON havering_operations."HaveringCorners";

CREATE TRIGGER "update_corner_protection_line_1_from_corner_point"
    AFTER INSERT OR UPDATE OF corner_point_geom ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_line_from_corner_point_geom"();

DROP TRIGGER IF EXISTS "update_corner_protection_line_2_from_apex_point" ON havering_operations."HaveringCorners";

CREATE TRIGGER "update_corner_protection_line_2_from_apex_point"
    AFTER INSERT OR UPDATE OF apex_point_geom ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_line_from_apex_point_geom"();

DROP TRIGGER IF EXISTS "update_corner_protection_line_3_from_apex_point" ON havering_operations."HaveringCorners";

CREATE TRIGGER "update_corner_protection_line_3_from_apex_point"
    AFTER UPDATE OF line_from_apex_point_geom ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_new_corner_protection_geom"();

DROP TRIGGER IF EXISTS "update_corner_protection_line_4_from_apex_point" ON havering_operations."HaveringCorners";

CREATE TRIGGER "update_corner_protection_line_4_from_apex_point"
    AFTER INSERT OR UPDATE OF new_corner_protection_geom ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_new_corner_protection_output_geom"();

DROP TRIGGER IF EXISTS "update_corner_protection_line_5_from_apex_point" ON havering_operations."HaveringCorners_Output";

CREATE TRIGGER "update_corner_protection_line_5_from_apex_point"
    AFTER INSERT ON havering_operations."HaveringCorners_Output" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_new_corner_dimension_lines_geom"();


DROP TRIGGER IF EXISTS "update_junction_status_from_corner_1" ON havering_operations."HaveringCorners";

--CREATE TRIGGER "update_junction_status_from_corner_1"
--    AFTER INSERT OR UPDATE OF "CornerProtectionCategoryTypeID" ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_junction_status_from_corner"();

DROP TRIGGER IF EXISTS "update_junction_status_from_corner_2" ON havering_operations."HaveringCorners";

--CREATE TRIGGER "update_junction_status_from_corner_2"
--    AFTER INSERT OR UPDATE OF "ComplianceRoadMarkingsFadedTypeID" ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_junction_status_from_corner"();

-- triggers for junctions

DROP TRIGGER IF EXISTS "update_corners_within_junctions" ON havering_operations."HaveringJunctions";

CREATE TRIGGER "update_corners_within_junctions"
    AFTER INSERT ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_corners_within_junctions"();

DROP TRIGGER IF EXISTS "update_junction_map_frame_geom" ON havering_operations."HaveringJunctions";

CREATE TRIGGER "update_junction_map_frame_geom"
    AFTER INSERT OR UPDATE OF "JunctionProtectionCategoryTypeID" ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_junction_map_frame_geom"();

DROP TRIGGER IF EXISTS "update_road_details_for_junctions" ON havering_operations."HaveringJunctions";

CREATE TRIGGER "update_road_details_for_junctions"
    AFTER INSERT OR UPDATE OF "junction_point_geom" ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_roads_for_junctions"();


-- Set permissions

REVOKE ALL ON ALL TABLES IN SCHEMA havering_operations FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA havering_operations TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA havering_operations TO toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA havering_operations TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA havering_operations TO toms_public, toms_operator, toms_admin;