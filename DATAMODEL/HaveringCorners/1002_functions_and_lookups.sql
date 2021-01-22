
--DROP FUNCTION IF EXISTS mhtc_operations."getParameter";

CREATE OR REPLACE FUNCTION mhtc_operations."getParameter"(param text) RETURNS text AS
'SELECT "Value"
FROM mhtc_operations."project_parameters"
WHERE "Field" = $1'
LANGUAGE SQL;

-- need mhtc_operations."get_road_casement_section" (it works the same)

CREATE OR REPLACE FUNCTION havering_operations."get_road_casement_section"(corner_id text,
                                                                       road_casement_geom geometry,
                                                                       corner_point_geom geometry,
                                                                       distance_from_corner_point float) RETURNS geometry AS /*"""*/ $$
    import plpy
    #from plpygis import Geometry
    """
    This function generates the section of road casement of interest
    """
    line_segment_geom = None
    #
    #plpy.info('get_road_casement_section 1: corner_point_geom:{})'.format(corner_point_geom))
    plpy.info('get_road_casement_section: cornerID: {})'.format(corner_id))
    # get the length of the line
    plan = plpy.prepare("SELECT ST_Length($1::geometry) as l", ['geometry'])
    restrictionLength = plpy.execute(plan, [road_casement_geom])[0]["l"]

    if restrictionLength < 20.0:
        return None  # can't deal with junction in this way ...

    #restrictionLength = plpy.execute("SELECT ST_Length({})".format(road_casement_geom))
    #plpy.info('get_road_casement_section 1a: restrictionLength:{})'.format(restrictionLength))
    #
    fraction = distance_from_corner_point / restrictionLength
    # obtain the location of the corner point
    plan = plpy.prepare("SELECT ST_LineLocatePoint($1,$2) as p", ['geometry', 'geometry'])
    corner_point_location = plpy.execute(plan, [road_casement_geom, corner_point_geom])[0]["p"]

    start_point_location = corner_point_location - fraction
    end_point_location = corner_point_location + fraction

    plpy.info('get_road_casement_section 2: restrictionLength: {}; start_point_location:{}; end_point_location: {})'.format(restrictionLength, start_point_location, end_point_location))
    # now check start/end points
    """
    if corner_point_location == 0.0:  # TODO: needs further work ...
        # line becomes end->1 + 0->start
        if start_point_location < 0.0:
            start_point_location = 1.0 + start_point_location
        if end_point_location > 1.0:
            end_point_location = end_point_location - 1.0
        plan = plpy.prepare("SELECT ST_MakeLine(ST_Collect(ST_LineSubstring($1::geometry, $2, 1.0), ST_LineSubstring($1::geometry, 0.0, $3)))  as x", ['geometry', 'float', 'float'])
        line_segment_geom = plpy.execute(plan, [road_casement_geom, end_point_location, start_point_location])[0]["x"]
    """
    #el
    if start_point_location < 0.0:
        # line becomes start->1 + 0->end
        start_point_location = 1.0 + start_point_location

        line_segment_pts = []

        plan = plpy.prepare("SELECT ST_LineSubstring($1, $2, 1.0) as x", ['geometry', 'float'])
        start_segment_geom = plpy.execute(plan, [road_casement_geom, start_point_location])[0]["x"]

        plan = plpy.prepare("SELECT ST_LineSubstring($1, 0.0, $2) as x", ['geometry', 'float'])
        end_segment_geom = plpy.execute(plan, [road_casement_geom, end_point_location])[0]["x"]

        plan = plpy.prepare("SELECT ST_SetSRID(ST_MakeLine($1, $2),27700)  as x", ['geometry', 'geometry'])
        line_segment_geom = plpy.execute(plan, [start_segment_geom, end_segment_geom])[0]["x"]

    elif end_point_location > 1.0:
        # line becomes start->1 + 0->end
        end_point_location = end_point_location - 1.0
        #
        plan = plpy.prepare("SELECT ST_LineSubstring($1::geometry, $2, 1.0)  as x", ['geometry', 'float'])
        start_segment_geom = plpy.execute(plan, [road_casement_geom, start_point_location])[0]["x"]
        #
        plan = plpy.prepare("SELECT ST_LineSubstring($1::geometry, 0.0, $2)  as x", ['geometry', 'float'])
        end_segment_geom = plpy.execute(plan, [road_casement_geom, end_point_location])[0]["x"]
        #
        plan = plpy.prepare("SELECT ST_SetSRID(ST_MakeLine($1::geometry, $2::geometry),27700)  as x", ['geometry', 'geometry'])
        line_segment_geom = plpy.execute(plan, [start_segment_geom, end_segment_geom])[0]["x"]
    else:
        plan = plpy.prepare("SELECT ST_SetSRID(ST_LineSubstring($1::geometry, $2, $3),27700) as x", ['geometry', 'float', 'float'])
        line_segment_geom = plpy.execute(plan, [road_casement_geom, start_point_location, end_point_location])[0]["x"]

    #plpy.info('get_road_casement_section 3  : start_point_location:{}; end_point_location: {})'.format(start_point_location, end_point_location))

    return line_segment_geom

$$ LANGUAGE plpython3u;


--
DROP FUNCTION IF EXISTS havering_operations."getCornerApexPoint";

CREATE OR REPLACE FUNCTION havering_operations."getCornerApexPoint"(cnr_id text,
                                                                tolerance float)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    apexPt geometry;
    start_pt geometry;
    end_pt geometry;
    start_pt_azimuth_to_apex float;
    end_pt_azimuth_to_apex float;
    start_pt_azimuth_to_cnr float;
    end_pt_azimuth_to_cnr float;
    distance float = 25.0;
    line_from_start_pt geometry;
    line_from_end_pt geometry;
    apexPt_GeometryType text;
BEGIN

	RAISE NOTICE '***** cnr_id(%)', cnr_id;
    RAISE NOTICE 'tolerance(%)', tolerance;

    -- get an approximate line of the kerb
    SELECT c."StartPt", c."EndPt",
           mhtc_operations."AzToNearestRoadCentreLine"(ST_AsText(c."StartPt"), tolerance) + PI()/2.0,
           mhtc_operations."AzToNearestRoadCentreLine"(ST_AsText(c."EndPt"), tolerance) + PI()/2.0,
           ST_Azimuth(c."StartPt", cn.corner_point_geom), ST_Azimuth(c."EndPt", cn.corner_point_geom)
    INTO start_pt, end_pt, start_pt_azimuth_to_apex, end_pt_azimuth_to_apex, start_pt_azimuth_to_cnr, end_pt_azimuth_to_cnr
    FROM havering_operations."HaveringCornerSegmentEndPts" c, havering_operations."HaveringCorners" cn
    WHERE c."GeometryID" = cnr_id
    AND c."GeometryID" = cn."GeometryID";

    RAISE NOTICE 'test(%)', ABS(start_pt_azimuth_to_apex - start_pt_azimuth_to_cnr);

    IF ABS(start_pt_azimuth_to_apex - start_pt_azimuth_to_cnr) > pi()/2.0 AND
       ABS(start_pt_azimuth_to_apex - start_pt_azimuth_to_cnr) < 3.0*pi()/2.0 THEN
        start_pt_azimuth_to_apex = start_pt_azimuth_to_apex + pi();
    END IF;

    IF ABS(end_pt_azimuth_to_apex - end_pt_azimuth_to_cnr) > pi()/2.0 AND
       ABS(end_pt_azimuth_to_apex - end_pt_azimuth_to_cnr) < 3.0*pi()/2.0 THEN
        end_pt_azimuth_to_apex = end_pt_azimuth_to_apex + pi();
    END IF;

    -- generate lines and get intersection
    /* x = x + dist * sin a
       y = y + dist * cos a */

    SELECT ST_MakeLine(start_pt, ST_SetSRID(ST_MakePoint(ST_X(start_pt) + distance * sin(start_pt_azimuth_to_apex), ST_Y(start_pt) + distance * cos(start_pt_azimuth_to_apex)), 27700))
    INTO line_from_start_pt;

    SELECT ST_MakeLine(end_pt, ST_SetSRID(ST_MakePoint(ST_X(end_pt) + distance * sin(end_pt_azimuth_to_apex), ST_Y(end_pt) + distance * cos(end_pt_azimuth_to_apex)), 27700))
    INTO line_from_end_pt;

    --RAISE NOTICE 'line_from_start_pt', ST_AsText(line_from_start_pt);

    SELECT ST_Intersection (line_from_start_pt, line_from_end_pt)
    INTO apexPt;

    SELECT ST_GeometryType(apexPt)
    INTO apexPt_GeometryType;

    --RAISE NOTICE 'apexPt_GeometryType(%)', apexPt_GeometryType;

    IF apexPt_GeometryType != 'ST_Point' THEN
        apexPt = NULL;
    END IF;

    RETURN apexPt;

END;
$BODY$;

--

CREATE OR REPLACE FUNCTION havering_operations."getCornerExtentsFromApex"(cnr_id text)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
BEGIN

    -- get the corner protection distance from "project_parameters"

    -- get intersection points between apex point buffer and corner segment
    SELECT ST_Intersection(c.geom, ST_Buffer(a.apex_point_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float))
    INTO cornerProtectionLineString
    FROM havering_operations."HaveringCornerSegments" c, havering_operations."HaveringCorners" a
    WHERE c."GeometryID" = cnr_id
    AND c."GeometryID" = a."GeometryID";

    RETURN cornerProtectionLineString;

END;
$BODY$;

--

CREATE OR REPLACE FUNCTION havering_operations.create_geometryid_havering()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 nextSeqVal varchar := '';
BEGIN

	CASE TG_TABLE_NAME
	WHEN 'HaveringCorners' THEN
			SELECT concat('CO_', to_char(nextval('havering_operations."HaveringCorners_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'HaveringJunctions' THEN
			SELECT concat('JU_', to_char(nextval('havering_operations."HaveringJunctions_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	ELSE
	    nextSeqVal = 'U';
	END CASE;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION havering_operations.create_geometryid_havering()
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION havering_operations."get_nearest_junction_to_corner"(cnr_id text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	 junction_id text := '';
BEGIN

    -- find nearest junction

    SELECT j."GeometryID" INTO junction_id
    FROM havering_operations."HaveringJunctions" j, havering_operations."HaveringCorners" c
    WHERE c."GeometryID" = cnr_id
    AND ST_DWithin(j.junction_point_geom, c.corner_point_geom, 30.0)
    ORDER BY
      ST_Distance(c.corner_point_geom, j.junction_point_geom)
    LIMIT 1;

    RETURN junction_id;

END;
$BODY$;

--

CREATE OR REPLACE FUNCTION havering_operations."get_all_new_corner_dimension_lines"(cnr_id text)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    corner_pt_geom geometry;
    apex_pt_geom geometry;
    line_from_apex_pt_geom geometry;
    line_start_apex geometry;
    line_apex_end geometry;
    new_jn_protection_geom geometry;
    cnr_pt_location float;
    i integer;
    startPt geometry;
    endPt geometry;
    start_pt_location float;
    end_pt_location float;
    dimensionLine geometry;
    dimLine1 geometry;
    dimLine2 geometry;
    corner_dimension_lines_geom geometry;
BEGIN

    /* objective is to create lines to show dimensions of new junction protection areas
    Need to:
    Using line_from_apex_point_geom, create lines start/apex_point_geom and end/apex_point_geom
    For each geometry in new_junction_protection_geom
        get start and end points
        find where there sit in relation corner_point_geom along line_from_apex_point_geom
        if start/end are on same side, create line with start/end
        if not on same side, create two lines with start/apex and apex/end

        ** create lines using nearest point on lines created to apex

        add to geometry

    */

	RAISE NOTICE '***** cnr_id(%)', cnr_id;

    -- get the required geometries
    SELECT corner_point_geom, apex_point_geom, line_from_apex_point_geom, new_junction_protection_geom
    INTO corner_pt_geom, apex_pt_geom, line_from_apex_pt_geom, new_jn_protection_geom
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    SELECT ST_MakeLine(ST_StartPoint(line_from_apex_pt_geom), apex_pt_geom)
    INTO line_start_apex
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    SELECT ST_MakeLine(apex_pt_geom, ST_EndPoint(line_from_apex_pt_geom))
    INTO line_apex_end
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    SELECT ST_LineLocatePoint(line_from_apex_pt_geom, ST_Snap(corner_pt_geom, line_from_apex_pt_geom, 0.1))
    INTO cnr_pt_location;

    corner_dimension_lines_geom = NULL;

    FOR i IN SELECT ST_NumGeometries(new_jn_protection_geom) LOOP

        -- get start/end points and their relative locations ** may need to deal with alignment issues ??
        SELECT ST_StartPoint(ST_GeometryN(new_jn_protection_geom, i))
        INTO startPt;
        SELECT ST_EndPoint(ST_GeometryN(new_jn_protection_geom, i))
        INTO endPt;

        SELECT ST_LineLocatePoint(line_from_apex_pt_geom, startPt)
        INTO start_pt_location;
        SELECT ST_LineLocatePoint(line_from_apex_pt_geom, endPt)
        INTO end_pt_location;

        IF (start_pt_location < cnr_pt_location and end_pt_location < cnr_pt_location) THEN
            -- project points onto line_start_apex
            SELECT ST_MakeLine(ST_ClosestPoint(line_start_apex, startPt), ST_ClosestPoint(line_start_apex, endPt))
            INTO dimensionLine;

        ELSIF (start_pt_location > cnr_pt_location and end_pt_location > cnr_pt_location) THEN
            -- project points onto line_apex_end
            SELECT ST_MakeLine(ST_ClosestPoint(line_apex_end, startPt), ST_ClosestPoint(line_apex_end, endPt))
            INTO dimensionLine;

        ELSIF start_pt_location < cnr_pt_location THEN
            -- project start point onto line_start_apex and end point on line_end_apex
            SELECT ST_MakeLine(ST_ClosestPoint(line_start_apex, startPt), apex_pt_geom)
            INTO dimLine1;
            SELECT ST_MakeLine(apex_pt_geom, ST_ClosestPoint(line_apex_end, endPt))
            INTO dimLine2;
            SELECT ST_Collect(dimLine1, dimLine2)
            INTO dimensionLine;

        ELSE
            -- project end point onto line_start_apex and start point on line_end_apex
            SELECT ST_MakeLine(ST_ClosestPoint(line_start_apex, endPt), apex_pt_geom)
            INTO dimLine1;
            SELECT ST_MakeLine(apex_pt_geom, ST_ClosestPoint(line_apex_end, startPt))
            INTO dimLine2;
            SELECT ST_Collect(dimLine1, dimLine2)
            INTO dimensionLine;

        END IF;

        -- Now add to multiline
        SELECT ST_Collect(corner_dimension_lines_geom, dimensionLine)
        INTO corner_dimension_lines_geom;

    END LOOP;

    RETURN corner_dimension_lines_geom;

END;
$BODY$;



-- set up triggers

CREATE TRIGGER "create_geometryid_havering_corners" BEFORE INSERT ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."create_geometryid_havering"();
CREATE TRIGGER "set_last_update_details_HaveringCorners" BEFORE INSERT OR UPDATE ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION "public"."set_last_update_details"();

CREATE TRIGGER "create_geometryid_havering_junctions" BEFORE INSERT ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."create_geometryid_havering"();
CREATE TRIGGER "set_last_update_details_HaveringJunctions" BEFORE INSERT OR UPDATE ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION "public"."set_last_update_details"();



