/*
Allow dimensioning to be not shown
*/

ALTER TABLE havering_operations."HaveringCorners"
    ADD COLUMN "ShowDimensions" boolean;

UPDATE havering_operations."HaveringCorners"
SET "ShowDimensions" = True;

/*
Allow linework to be created without a corner.
Needs to be associated with a junction ?? (or a map frame??)
*/


/*
set up trigger to update new corner protection lines if HaveringCorners_Output is updated
*/

CREATE OR REPLACE FUNCTION havering_operations."update_havering_corners_output"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   corner_id text;
BEGIN

    corner_id = NEW."GeometryID";
    RAISE NOTICE '***** IN update_havering_corners_output: corner_id(%)', corner_id;

    --ALTER TABLE havering_operations."HaveringCorners_Output" DISABLE TRIGGER "update_havering_corners_output";

    IF EXISTS(
        SELECT 1
        FROM havering_operations."HaveringCorners"
        WHERE "GeometryID" = corner_id
    ) THEN

        RAISE NOTICE '***** IN update_havering_corners_output: setting new corner prot geom ...';

        UPDATE havering_operations."HaveringCorners"
        SET new_corner_protection_geom = ST_Multi(NEW."new_corner_protection_geom")
        /*SET new_corner_protection_geom = ST_Collect( ARRAY( SELECT new_corner_protection_geom FROM havering_operations."HaveringCorners_Output"
                                                            WHERE "GeometryID" = corner_id) )*/
        WHERE "GeometryID" = corner_id;

    ELSE

        -- Create a new corner ...
        INSERT INTO havering_operations."HaveringCorners"(
            "RestrictionID", --"RoadName", "MHTC_CheckIssueTypeID",
            corner_point_geom, apex_point_geom, line_from_corner_point_geom, line_from_apex_point_geom,
            new_corner_protection_geom, corner_dimension_lines_geom,-- "CornerProtectionCategoryTypeID",
            "ComplianceRoadMarkingsFadedTypeID", "ShowDimensions")
            VALUES (uuid_generate_v4(), --?, ?,
                    ST_LineInterpolatePoint(NEW.new_corner_protection_geom, 0.5), None, None,
                    None, None, --?,
                    --?,
                    False);

    END IF;

    --ALTER TABLE havering_operations."HaveringCorners_Output" ENABLE TRIGGER "update_havering_corners_output";

    RETURN NEW;

END;
$BODY$;

DROP TRIGGER IF EXISTS "update_havering_corners_output" ON havering_operations."HaveringCorners_Output";

CREATE TRIGGER "update_havering_corners_output"
    AFTER INSERT OR UPDATE ON havering_operations."HaveringCorners_Output" FOR EACH ROW EXECUTE FUNCTION havering_operations."update_havering_corners_output"();
--

CREATE OR REPLACE FUNCTION havering_operations."set_new_corner_protection_output_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   cnr_id text;
   nearestJunction text;
BEGIN

    cnr_id = NEW."GeometryID";
    RAISE NOTICE '***** IN set_new_corner_protection_output_geom: cnr_id(%)', cnr_id;

    DELETE FROM havering_operations."HaveringCorners_Output"
    WHERE "GeometryID" = cnr_id;

    INSERT INTO havering_operations."HaveringCorners_Output" ("GeometryID", new_corner_protection_geom)
    SELECT "GeometryID", (ST_Dump(new_corner_protection_geom)).geom
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    UPDATE havering_operations."HaveringCorners_Output"
    SET "AzimuthToRoadCentreLine" = degrees(mhtc_operations."AzToNearestRoadCentreLine"(ST_AsText(ST_LineInterpolatePoint(new_corner_protection_geom, 0.5)), 25.0))
    WHERE "GeometryID" = cnr_id;

    RETURN NEW;

END;
$BODY$;

DROP TRIGGER "update_corner_protection_line_5_from_apex_point" ON havering_operations."HaveringCorners_Output";

CREATE TRIGGER "update_corner_protection_line_5_from_apex_point"
    AFTER INSERT OR UPDATE ON havering_operations."HaveringCorners_Output" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_new_corner_dimension_lines_geom"();

DROP TRIGGER IF EXISTS "update_corner_protection_line_4_from_apex_point" ON havering_operations."HaveringCorners";

CREATE TRIGGER "update_corner_protection_line_4_from_apex_point"
    AFTER INSERT ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_new_corner_protection_output_geom"();

CREATE TRIGGER "update_corner_protection_line_6_from_apex_point"
    AFTER UPDATE OF new_corner_protection_geom ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_new_corner_protection_output_geom"();