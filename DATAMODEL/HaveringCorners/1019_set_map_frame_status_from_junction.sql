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


--- To update the Release status

ALTER TABLE havering_operations."HaveringMapFrames" DISABLE TRIGGER all;

DO
$do$
DECLARE
   row RECORD;
   junctions_within_map_frames RECORD;
   map_frame_id text;
   this_junction_id text;
   junction_id text;
   mf_mhtc_check_issue_type integer;
   jn_mhtc_check_issue_type integer;
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

        mf_mhtc_check_issue_type = 1;

        FOR junctions_within_map_frames IN
            SELECT "JunctionID"
            FROM havering_operations."JunctionsWithinMapFrames" jmf
            WHERE jmf."MapFrameID" = map_frame_id
        LOOP

            SELECT "MHTC_CheckIssueTypeID"
            INTO jn_mhtc_check_issue_type
            FROM havering_operations."HaveringJunctions"
            WHERE "GeometryID" = junctions_within_map_frames."JunctionID"
            AND "JunctionProtectionCategoryTypeID" IN (2,3);

            RAISE NOTICE '***** IN set_map_frame_status_from_junction: junction_id (%); jn_mhtc_check_issue_type(%)', junctions_within_map_frames."JunctionID", jn_mhtc_check_issue_type;

            IF jn_mhtc_check_issue_type = 2 OR
               jn_mhtc_check_issue_type = 3 THEN
                mf_mhtc_check_issue_type = 2;
			END IF;

        END LOOP;

        RAISE NOTICE '***** IN set_map_frame_status_from_junction: mf_category_type(%)', mf_mhtc_check_issue_type;

        UPDATE havering_operations."HaveringMapFrames" AS j
            SET "MHTC_CheckIssueTypeID" = mf_mhtc_check_issue_type
            WHERE "GeometryID" = map_frame_id;

    END LOOP;
END
$do$;

ALTER TABLE havering_operations."HaveringMapFrames" ENABLE TRIGGER all;


ALTER TABLE havering_operations."HaveringMapFrames" DISABLE TRIGGER all;

DO
$do$
DECLARE
   row RECORD;
   map_frame_id text;
   map_frame_scale double precision;
   map_frame_category_type integer;
   --map_frame_geom geometry;
   new_map_frame_geom geometry;
   dX double precision = 0.1;
   dY double precision = 0.125;
BEGIN

    FOR row IN SELECT "GeometryID", "HaveringMapFramesCategoryTypeID", "map_frame_geom", "map_frame_centre_point_geom", "HaveringMapFramesScaleID"
               FROM havering_operations."HaveringMapFrames"
               WHERE "MHTC_CheckIssueTypeID" = 1  -- only look at the items available for release
    LOOP

        map_frame_id = row."GeometryID";
        map_frame_category_type = row."HaveringMapFramesCategoryTypeID";
        RAISE NOTICE '***** IN set_map_frame_geom: map_frame_id(%); map_frame_category_type (%)', map_frame_id, map_frame_category_type;

        IF map_frame_category_type = 1 THEN

            new_map_frame_geom := NULL;

        ELSE

            SELECT "Description" INTO map_frame_scale
            FROM "havering_operations"."HaveringMapFramesAllowableScales"
            WHERE "Code" = row."HaveringMapFramesScaleID";

            SELECT ST_MakeEnvelope(ST_X(row.map_frame_centre_point_geom)::float-(map_frame_scale::float*dX), ST_Y(row.map_frame_centre_point_geom)::float-(map_frame_scale::float*dY),
                                   ST_X(row.map_frame_centre_point_geom)::float+(map_frame_scale::float*dX), ST_Y(row.map_frame_centre_point_geom)::float+(map_frame_scale::float*dY), 27700)
            INTO new_map_frame_geom;

            RAISE NOTICE '***** IN set_map_frame_geom: new_map_frame_geom (%)', ST_AsText(new_map_frame_geom);
            RAISE NOTICE '***** IN set_map_frame_geom: orig_map_frame_geom (%)', ST_AsText(row."map_frame_geom");

            IF NOT ST_Equals(new_map_frame_geom, row."map_frame_geom")
			   OR row."map_frame_geom" IS NULL THEN
                --IF ST_AsText(new_map_frame_geom) = ST_AsText(row."map_frame_geom") THEN
                RAISE NOTICE '*****--- IN set_map_frame_geom: Updating map frame for (%)', map_frame_id;
                UPDATE havering_operations."HaveringMapFrames"
                SET map_frame_geom = new_map_frame_geom
                WHERE "GeometryID" = map_frame_id;
			END IF;

        END IF;
    END LOOP;
END;
$do$;

ALTER TABLE havering_operations."HaveringMapFrames" ENABLE TRIGGER all;