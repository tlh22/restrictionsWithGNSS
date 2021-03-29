--

ALTER TABLE havering_operations."HaveringMapFrames" DISABLE TRIGGER all;

DO
$do$
DECLARE
   row RECORD;
   junctions_within_map_frames RECORD;
   map_frame_id text;
   this_junction_id text;
   junction_id text;
   jn_protection_category_type integer;
   mf_category_type integer;
   --road_markings_status integer;
BEGIN
    FOR row IN SELECT "GeometryID"
               FROM havering_operations."HaveringJunctions"
               WHERE "MHTC_CheckIssueTypeID" = 1  -- only look at the items available for release
    LOOP
    
        junction_id = row."GeometryID";

        SELECT "MapFrameID" INTO map_frame_id
        FROM havering_operations."JunctionsWithinMapFrames"
        WHERE "JunctionID" = junction_id;

        RAISE NOTICE '***** IN set_map_frame_status_from_junction: junction_id(%); map_frame_id (%)', junction_id, map_frame_id;

        mf_category_type = 1;

        FOR junctions_within_map_frames IN
            SELECT "JunctionID"
            FROM havering_operations."JunctionsWithinMapFrames" jmf
            WHERE jmf."MapFrameID" = map_frame_id
        LOOP

            SELECT "JunctionProtectionCategoryTypeID"
            INTO jn_protection_category_type
            FROM havering_operations."HaveringJunctions"
            WHERE "GeometryID" = junctions_within_map_frames."JunctionID";

            RAISE NOTICE '***** IN set_map_frame_status_from_junction: junction_id (%); jn_protection_category_type(%)', junctions_within_map_frames."JunctionID", jn_protection_category_type;

            IF jn_protection_category_type = 2 OR
               jn_protection_category_type = 3 THEN
                mf_category_type = 2;
			END IF;

        END LOOP;

        RAISE NOTICE '***** IN set_map_frame_status_from_junction: mf_category_type(%)', mf_category_type;

        UPDATE havering_operations."HaveringMapFrames" AS j
            SET "HaveringMapFramesCategoryTypeID" = mf_category_type
            WHERE "GeometryID" = map_frame_id;

    END LOOP;
END
$do$;

ALTER TABLE havering_operations."HaveringMapFrames" ENABLE TRIGGER all;