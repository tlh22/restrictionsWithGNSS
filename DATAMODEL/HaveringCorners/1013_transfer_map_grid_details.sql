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

-- set up function to deal with map frame scale

CREATE OR REPLACE FUNCTION havering_operations."set_map_frame_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   junction_id text;
   map_frame_id text;
   map_frame_scale double precision;
   map_frame_category_type integer;
   map_frame_geom_not_changed boolean;
   map_frame_geom geometry;
   dX double precision = 0.1;
   dY double precision = 0.125;
BEGIN

    map_frame_id = NEW."GeometryID";
    map_frame_category_type = NEW."HaveringMapFramesCategoryTypeID";
    RAISE NOTICE '***** IN set_map_frame_geom: map_frame_id(%); map_frame_category_type (%)', map_frame_id, map_frame_category_type;

    IF NEW."HaveringMapFramesCategoryTypeID" = 1 THEN

        UPDATE havering_operations."HaveringMapFrames"
        SET map_frame_geom = NULL
        WHERE "GeometryID" = map_frame_id;

    ELSE

        SELECT "Description" INTO map_frame_scale
        FROM "havering_operations"."HaveringMapFramesAllowableScales"
        WHERE "Code" = NEW."HaveringMapFramesScaleID";

        SELECT ST_Equals(NEW.map_frame_centre_point_geom, OLD.map_frame_centre_point_geom) INTO map_frame_geom_not_changed;

        RAISE NOTICE '***** IN set_map_frame_geom: map_frame_scale(%); map_frame_geom_change (%)', map_frame_scale, map_frame_geom_not_changed;

        IF (NEW."HaveringMapFramesScaleID" != OLD."HaveringMapFramesScaleID") OR NOT map_frame_geom_not_changed THEN

            RAISE NOTICE '***** IN set_map_frame_geom: map_frame_scale(%); dX (%); x (%)', map_frame_scale, dX, ST_X(NEW.map_frame_centre_point_geom);

            SELECT ST_MakeEnvelope(ST_X(NEW.map_frame_centre_point_geom)::float-(map_frame_scale::float*dX), ST_Y(NEW.map_frame_centre_point_geom)::float-(map_frame_scale::float*dY),
                                   ST_X(NEW.map_frame_centre_point_geom)::float+(map_frame_scale::float*dX), ST_Y(NEW.map_frame_centre_point_geom)::float+(map_frame_scale::float*dY), 27700)
            INTO map_frame_geom;

            NEW."map_frame_geom" := map_frame_geom;

        END IF;

    END IF;

    --NEW."line_from_apex_point_geom" := cornerProtectionLineString;
    RETURN NEW;

END;
$BODY$;

CREATE OR REPLACE FUNCTION havering_operations."set_junctions_within_map_frame"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   map_frame_id text;
BEGIN

    map_frame_id = NEW."GeometryID";
    RAISE NOTICE '***** IN set_junctions_within_map_frame: map_frame_id(%)', map_frame_id;

    -- get possible corners in local area
    INSERT INTO havering_operations."JunctionsWithinMapFrames" ("JunctionID", "MapFrameID")
    SELECT j."GeometryID" AS "JunctionID", map_frame_id AS "MapFrameID"
    FROM havering_operations."HaveringJunctions" j
    WHERE ST_Within(j.junction_point_geom, NEW.map_frame_geom)
    -- check that not already present
    AND j."GeometryID" NOT IN (
        SELECT "JunctionID"
        FROM havering_operations."JunctionsWithinMapFrames"
        WHERE "MapFrameID" = map_frame_id);
    --NEW."line_from_apex_point_geom" := cornerProtectionLineString;

    RETURN NEW;

END;
$BODY$;

DROP TRIGGER IF EXISTS "set_junctions_within_map_frame" ON havering_operations."HaveringMapFrames";

CREATE TRIGGER "set_junctions_within_map_frame"
    AFTER INSERT OR UPDATE ON havering_operations."HaveringMapFrames" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_junctions_within_map_frame"();

-- Now transfer grids
INSERT INTO havering_operations."HaveringMapFrames"(
	"RestrictionID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "CreateDateTime", "CreatePerson",
	map_frame_centre_point_geom, map_frame_geom, "HaveringMapFramesScaleID", "HaveringMapFramesCategoryTypeID", "RoadsAtJunction", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson"
)
SELECT uuid_generate_v4(), "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "CreateDateTime", "CreatePerson",
junction_point_geom, map_frame_geom, 1, "JunctionProtectionCategoryTypeID", "RoadsAtJunction", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson"
	FROM havering_operations."HaveringJunctions";

-- JunctionsWithinMapFrames should be dealt with by the trigger ...

DROP TRIGGER IF EXISTS "set_map_frame_geom" ON havering_operations."HaveringMapFrames";

CREATE TRIGGER "set_map_frame_geom"
    BEFORE INSERT OR UPDATE ON havering_operations."HaveringMapFrames" FOR EACH ROW EXECUTE FUNCTION havering_operations."set_map_frame_geom"();

CREATE TRIGGER set_last_update_details_havering_map_frames
    BEFORE INSERT OR UPDATE
    ON havering_operations."HaveringMapFrames"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_last_update_details();

