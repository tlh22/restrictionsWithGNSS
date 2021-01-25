
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

	RAISE NOTICE '***** In getCornerApexPoint cnr_id(%)', cnr_id;
    RAISE NOTICE ' -    tolerance(%)', tolerance;

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
    line_from_corner_pt_geom geometry;
    line_start_apex geometry;
    line_apex_end geometry;
    new_cnr_protection_geom geometry;
    cnr_pt_location float;
    i integer;
    startPt geometry;
    endPt geometry;
    tmpPt geometry;
    start_pt_location float;
    end_pt_location float;
    tmp_pt_location float;
    dimensionLine geometry;
    dimLine1 geometry;
    dimLine2 geometry;
    corner_dimension_lines_geom geometry;
    nr_geometries integer;
BEGIN

    /* objective is to create lines to show dimensions of new junction protection areas
    Need to:
    Using line_from_apex_point_geom, create lines start/apex_point_geom and end/apex_point_geom
    For each geometry in new_corner_protection_geom
        get start and end points
        find where there sit in relation corner_point_geom along line_from_apex_point_geom
        if start/end are on same side, create line with start/end
        if not on same side, create two lines with start/apex and apex/end

        ** create lines using nearest point on lines created to apex

        add to geometry

    */

	RAISE NOTICE '***** IN get_all_new_corner_dimension_lines: cnr_id(%)', cnr_id;

    -- get the required geometries
    SELECT corner_point_geom, apex_point_geom, line_from_corner_point_geom, new_corner_protection_geom
    INTO corner_pt_geom, apex_pt_geom, line_from_corner_pt_geom, new_cnr_protection_geom
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    SELECT ST_MakeLine(ST_StartPoint(line_from_corner_pt_geom), apex_pt_geom)
    INTO line_start_apex
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    SELECT ST_MakeLine(apex_pt_geom, ST_EndPoint(line_from_corner_pt_geom))
    INTO line_apex_end
    FROM havering_operations."HaveringCorners"
    WHERE "GeometryID" = cnr_id;

    SELECT ST_LineLocatePoint(line_from_corner_pt_geom, ST_Snap(corner_pt_geom, line_from_corner_pt_geom, 0.1))
    INTO cnr_pt_location;

    corner_dimension_lines_geom = NULL;

    SELECT ST_NumGeometries(new_cnr_protection_geom) INTO nr_geometries;

    IF nr_geometries IS NULL THEN
        nr_geometries = 0;
    END IF;

    RAISE NOTICE ' - cnr_pt_location: %; nr geoms: %', cnr_pt_location, nr_geometries;

    FOR i IN 1..nr_geometries LOOP

        -- get start/end points and their relative locations ** may need to deal with alignment issues ??
        SELECT ST_StartPoint(ST_GeometryN(new_cnr_protection_geom, i))
        INTO startPt;
        SELECT ST_EndPoint(ST_GeometryN(new_cnr_protection_geom, i))
        INTO endPt;

        SELECT ST_LineLocatePoint(line_from_corner_pt_geom, startPt)
        INTO start_pt_location;
        SELECT ST_LineLocatePoint(line_from_corner_pt_geom, endPt)
        INTO end_pt_location;

	    RAISE NOTICE ' - loop: %; start_pt_location: %: end_point_location: %', i, start_pt_location, end_pt_location;

        IF start_pt_location > end_pt_location THEN
            tmp_pt_location = start_pt_location;
            tmpPt = startPt;
            start_pt_location = end_pt_location;
            startPt = endPt;
            end_pt_location = tmp_pt_location;
            endPt = tmpPt;
        END IF;

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
        SELECT ST_CollectionHomogenize(ST_Collect(corner_dimension_lines_geom, dimensionLine))
        INTO corner_dimension_lines_geom;

    END LOOP;

    RETURN corner_dimension_lines_geom;

	EXCEPTION WHEN OTHERS THEN

		-- Add note to indicate an issue with this function
		raise notice '!!! issue: % %', SQLERRM, SQLSTATE;
		UPDATE havering_operations."HaveringCorners"
		SET "Notes" = CONCAT("Notes", '; Issue generating dimension lines - possible double back');
		RETURN corner_dimension_lines_geom;

END;
$BODY$;


-- create functions for update triggers


CREATE OR REPLACE FUNCTION havering_operations."set_line_from_corner_point_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   apex_pt_geom geometry;
   cnr_id text;
   nearestJunction text;
BEGIN

    cnr_id = NEW."GeometryID";
    RAISE NOTICE '***** IN update_line_from_corner_point_geom: cnr_id(%)', cnr_id;

    -- clear the relevant record  ** may need to check record exists
    DELETE FROM havering_operations."HaveringCornerSegments"
    WHERE "GeometryID" = cnr_id;

    -- add in new details

    ALTER TABLE havering_operations."HaveringCornerSegments" DROP CONSTRAINT "HaveringCornerSegments_pkey";

    WITH cornerDetails AS (
    SELECT c."GeometryID" as "GeometryID", c.corner_point_geom As corner_geom, r.geom as road_casement_geom
    FROM havering_operations."HaveringCorners" c, topography."road_casement" r
    WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.corner_point_geom, 0.1))
    AND "GeometryID" = cnr_id
    )
        INSERT INTO havering_operations."HaveringCornerSegments" ("GeometryID", "SegmentLength", geom)
        SELECT d."GeometryID", ST_Length(havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)),
                        havering_operations."get_road_casement_section"(d."GeometryID", d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)
        FROM cornerDetails d;

    DELETE FROM havering_operations."HaveringCornerSegments" c1
    WHERE "GeometryID" = cnr_id
    AND "GeometryID" IN (
        SELECT "GeometryID"
        FROM (
            SELECT "GeometryID", count(*)
            FROM havering_operations."HaveringCornerSegments"
            GROUP BY "GeometryID"
            HAVING count(*) > 1) a
            );

    ALTER TABLE ONLY havering_operations."HaveringCornerSegments"
        ADD CONSTRAINT "HaveringCornerSegments_pkey" PRIMARY KEY ("GeometryID");

    -- clear the relevant record  ** may need to check record exists
    DELETE FROM havering_operations."HaveringCornerSegmentEndPts"
    WHERE "GeometryID" = cnr_id;

    INSERT INTO havering_operations."HaveringCornerSegmentEndPts" ("GeometryID", "StartPt", "EndPt")
    SELECT d."GeometryID", ST_StartPoint(d.geom), ST_EndPoint(d.geom)
    FROM havering_operations."HaveringCornerSegments" d
    WHERE d."GeometryID" = cnr_id;

    -- now look at corners ...

    UPDATE havering_operations."HaveringCorners" AS c
    SET line_from_corner_point_geom = s.geom
    FROM havering_operations."HaveringCornerSegments" s
    WHERE s."GeometryID" = c."GeometryID"
    AND c."GeometryID" = cnr_id;

    NEW."line_from_corner_point_geom" := cornerProtectionLineString;

    -- would be worth checking to see whether or not apex_pt_geom exists and creating if not ...

    IF OLD."apex_point_geom" IS NULL THEN
        RAISE NOTICE '-- creating apex point for cnr_id(%)', cnr_id;
        UPDATE havering_operations."HaveringCorners" AS c
        SET apex_point_geom = havering_operations."getCornerApexPoint"(cnr_id, 25.0)
        WHERE c."GeometryID" = cnr_id;
        --NEW."apex_point_geom" := apex_pt_geom;
    END IF;

    -- also check to see if part of a junction ...
    IF OLD."corner_point_geom" IS NULL THEN

        RAISE NOTICE '-- adding cnr_id(%) to junctions', cnr_id;

        SELECT havering_operations."get_nearest_junction_to_corner"(cnr_id) INTO nearestJunction;

        IF nearestJunction IS NOT NULL THEN
            INSERT INTO havering_operations."CornersWithinJunctions" ("CornerID", "JunctionID")
            VALUES (cnr_id, nearestJunction);

            -- also reset check status for junction ...

            UPDATE havering_operations."HaveringJunctions"
            SET "MHTC_CheckIssueTypeID" = NULL;

        END IF;

    END IF;

    RETURN NEW;

END;
$BODY$;

--
CREATE OR REPLACE FUNCTION havering_operations."set_line_from_apex_point_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   cnr_id text;
BEGIN

    cnr_id = NEW."GeometryID";
    RAISE NOTICE '***** IN update_line_from_apex_point_geom: cnr_id(%)', cnr_id;

    UPDATE havering_operations."HaveringCorners" AS c
    SET line_from_apex_point_geom = ST_GeometryN(havering_operations."getCornerExtentsFromApex"(cnr_id), 1)
    WHERE c."GeometryID" = cnr_id;

    --NEW."line_from_apex_point_geom" := cornerProtectionLineString;
    RETURN NEW;

END;
$BODY$;

--

CREATE OR REPLACE FUNCTION havering_operations."set_new_corner_protection_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   cnr_id text;
   nearestJunction text;
BEGIN

    cnr_id = NEW."GeometryID";
    RAISE NOTICE '***** IN set_new_corner_protection_geom: cnr_id(%)', cnr_id;

    DELETE FROM havering_operations."HaveringCornerConformingSegments"
    WHERE "GeometryID" = cnr_id;

    INSERT INTO havering_operations."HaveringCornerConformingSegments" ("GeometryID", geom)
    SELECT u."GeometryID", ST_Multi(ST_Union(u.geom))
    FROM
    (SELECT c."GeometryID" as "GeometryID", r.geom as geom
    FROM havering_operations."HaveringCorners" c, "toms"."Lines" r
    WHERE ST_Intersects(r.geom, ST_Buffer(ST_SetSRID(c.line_from_apex_point_geom, 27700), 0.1))
    AND r."RestrictionTypeID" NOT IN (201, 221, 224, 216, 220)
    AND c."GeometryID" = cnr_id
    UNION
    SELECT c."GeometryID" as id, ST_Multi(r.geom)
    FROM havering_operations."HaveringCorners" c, "toms"."Bays" r
    WHERE ST_Intersects(r.geom, ST_Buffer(ST_SetSRID(c.line_from_apex_point_geom, 27700), 0.1))
    AND c."GeometryID" = cnr_id
     ) AS u
     GROUP BY u."GeometryID";

    UPDATE havering_operations."HaveringCorners" AS c
    SET new_corner_protection_geom = ST_Multi(ST_CollectionExtract(ST_Difference(ST_Multi(c.line_from_apex_point_geom), ST_Buffer(d.geom, 0.1)), 2))
    FROM havering_operations."HaveringCornerConformingSegments" d
    WHERE d."GeometryID" = c."GeometryID"
    AND c."GeometryID" = cnr_id;

    UPDATE havering_operations."HaveringCorners" AS c
    SET new_corner_protection_geom = ST_Multi(c.line_from_apex_point_geom)
    WHERE c."GeometryID" = cnr_id
    AND c."GeometryID" NOT IN (
        SELECT d."GeometryID"
        FROM havering_operations."HaveringCornerConformingSegments" d);

    -- regenerate dimension lines
    UPDATE havering_operations."HaveringCorners" AS c
    SET corner_dimension_lines_geom = ST_Multi(havering_operations."get_all_new_corner_dimension_lines"(cnr_id))
    WHERE havering_operations."get_all_new_corner_dimension_lines"(cnr_id) IS NOT NULL
    AND c."GeometryID" = cnr_id;

    -- classify corners

    UPDATE havering_operations."HaveringCorners"
        SET "CornerProtectionCategoryTypeID" = 1
        WHERE ST_Length(new_corner_protection_geom) = 0.0
        OR ST_Length(new_corner_protection_geom) IS NULL
        AND "GeometryID" = cnr_id;

    UPDATE havering_operations."HaveringCorners"
        SET "CornerProtectionCategoryTypeID" = 2
        WHERE ST_Length(new_corner_protection_geom) > 0.0 and ST_Length(new_corner_protection_geom) < 16.0
        AND "GeometryID" = cnr_id;

    UPDATE havering_operations."HaveringCorners"
        SET "CornerProtectionCategoryTypeID" = 3
        WHERE ST_Length(new_corner_protection_geom) >= 16.0
        AND "GeometryID" = cnr_id;

    -- change corner check status
    --SELECT havering_operations."get_nearest_junction_to_corner"(cnr_id) INTO nearestJunction;
    SELECT "JunctionID" INTO nearestJunction
    FROM havering_operations."CornersWithinJunctions"
    WHERE "CornerID" = cnr_id;

    UPDATE havering_operations."HaveringJunctions"
    SET "MHTC_CheckIssueTypeID" = NULL
    WHERE "GeometryID" = nearestJunction;

    UPDATE havering_operations."HaveringCorners"
    SET "MHTC_CheckIssueTypeID" = NULL
    WHERE "GeometryID" = cnr_id;

    --NEW."new_corner_protection_geom" := cornerProtectionLineString;
    RETURN NEW;

END;
$BODY$;

--
CREATE OR REPLACE FUNCTION havering_operations."set_junction_map_frame_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   junction_id text;
   jn_protection_category_type integer;
BEGIN

    junction_id = NEW."GeometryID";
    jn_protection_category_type = NEW."JunctionProtectionCategoryTypeID";
    RAISE NOTICE '***** IN set_junction_map_frame_geom: junction_id(%); jn_protection_category_type (%)', junction_id, jn_protection_category_type;

    IF NEW."JunctionProtectionCategoryTypeID" = 1 THEN

        UPDATE havering_operations."HaveringJunctions"
        SET map_frame_geom = NULL
        WHERE "GeometryID" = junction_id;

    ELSE

        UPDATE havering_operations."HaveringJunctions"
        SET map_frame_geom = ST_MakeEnvelope(ST_X(junction_point_geom)-20.0, ST_Y(junction_point_geom)-25.0,
                                     ST_X(junction_point_geom)+20.0, ST_Y(junction_point_geom)+25.0, 27700)
        WHERE "GeometryID" = junction_id;

    END IF;

    --NEW."line_from_apex_point_geom" := cornerProtectionLineString;
    RETURN NEW;

END;
$BODY$;

--
CREATE OR REPLACE FUNCTION havering_operations."set_corners_within_junctions"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   junction_id text;
BEGIN

    junction_id = NEW."GeometryID";
    RAISE NOTICE '***** IN set_corners_within_junctions: junction_id(%)', junction_id;

    -- get possible corners in local area
    INSERT INTO havering_operations."CornersWithinJunctions" ("CornerID", "JunctionID")
    SELECT c."GeometryID" AS "CornerID", havering_operations."get_nearest_junction_to_corner"(c."GeometryID") AS "JunctionID"
    FROM havering_operations."HaveringCorners" c
    WHERE havering_operations."get_nearest_junction_to_corner"(c."GeometryID") = junction_id
    AND ST_DWithin(c.corner_point_geom, NEW.junction_point_geom, 25.0);
    --NEW."line_from_apex_point_geom" := cornerProtectionLineString;

    RETURN NEW;

END;
$BODY$;

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

--
CREATE OR REPLACE FUNCTION havering_operations."set_roads_for_junctions"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   junction_id text;
   road_names RECORD;
BEGIN

    junction_id = NEW."GeometryID";
    RAISE NOTICE '***** IN set_roads_for_junctions: junction_id(%)', junction_id;

    -- reset field
	UPDATE havering_operations."HaveringJunctions" AS j
    SET "RoadsAtJunction" = havering_operations."update_roads_for_junctions"(junction_id)
    WHERE "GeometryID" = junction_id;

    RETURN NEW;

END;
$BODY$;

--
CREATE OR REPLACE FUNCTION havering_operations."update_roads_for_junctions"(junction_id text)
RETURNS text
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   road_names RECORD;
   junction_pt_geom geometry;
   roads_at_junction text = '';
   len_road_details float;
BEGIN

    --junction_id = NEW."GeometryID";
    RAISE NOTICE '***** IN update_roads_for_junctions: junction_id(%)', junction_id;

    SELECT junction_point_geom
    INTO junction_pt_geom
    FROM havering_operations."HaveringJunctions"
    WHERE "GeometryID" = junction_id;

    -- now update
    FOR road_names IN
        SELECT DISTINCT(name1) as road_name
        FROM highways_network.roadlink r
        WHERE ST_DWithin (junction_pt_geom, r.geom, 0.1)
    LOOP
        SELECT LENGTH(roads_at_junction)
        INTO len_road_details;

        IF len_road_details = 0 THEN
            roads_at_junction = road_names.road_name;
        ELSE
            SELECT CONCAT(roads_at_junction, ' / ', road_names.road_name)
            INTO roads_at_junction;
        END IF;
    END LOOP;

    RETURN roads_at_junction;

END;
$BODY$;

-- trigger for when corner status is changed
--
CREATE OR REPLACE FUNCTION havering_operations."set_junction_status_from_corner"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cnrs_within_junction RECORD;
   cnr_id text;
   this_cnr_id text;
   junction_id text;
   jn_protection_category_type integer;
   cnr_protection_category_type integer;
   road_markings_status integer;
BEGIN

    cnr_id = NEW."GeometryID";

    SELECT "JunctionID" INTO junction_id
    FROM havering_operations."CornersWithinJunctions"
    WHERE "CornerID" = cnr_id;

    RAISE NOTICE '***** IN set_junction_status_from_corner: cnr_id(%); junction_id (%)', cnr_id, junction_id;

    jn_protection_category_type = 1;

    FOR cnrs_within_junction IN
        SELECT "CornerID"
        FROM havering_operations."CornersWithinJunctions" cj
        WHERE cj."JunctionID" = junction_id
    LOOP

        SELECT "CornerProtectionCategoryTypeID","ComplianceRoadMarkingsFadedTypeID"
        INTO cnr_protection_category_type, road_markings_status
        FROM havering_operations."HaveringCorners"
        WHERE "GeometryID" = cnrs_within_junction."CornerID";

        RAISE NOTICE '***** IN set_junction_status_from_corner: cnr_id (%); cnr_protection_category_type(%)', cnrs_within_junction."CornerID", cnr_protection_category_type;

        IF cnr_protection_category_type = 2 OR
           cnr_protection_category_type = 3 THEN
            jn_protection_category_type = 2;

        ELSIF road_markings_status != 1 THEN
            jn_protection_category_type = 3;
        END IF;

    END LOOP;

    RAISE NOTICE '***** IN set_junction_status_from_corner: jn_protection_category_type(%)', jn_protection_category_type;

    UPDATE havering_operations."HaveringJunctions" AS j
        SET "JunctionProtectionCategoryTypeID" = jn_protection_category_type
        WHERE "GeometryID" = junction_id;

    RETURN NEW;

END;
$BODY$;


-- set up triggers
DROP TRIGGER IF EXISTS "create_geometryid_havering_corners" ON havering_operations."HaveringCorners";
DROP TRIGGER IF EXISTS "set_create_details_havering_corners" ON havering_operations."HaveringCorners";
CREATE TRIGGER "create_geometryid_havering_corners" BEFORE INSERT ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION havering_operations."create_geometryid_havering"();
CREATE TRIGGER "set_create_details_havering_corners" BEFORE INSERT ON havering_operations."HaveringCorners" FOR EACH ROW EXECUTE FUNCTION "public"."set_create_details"();

DROP TRIGGER IF EXISTS "create_geometryid_havering_junctions" ON havering_operations."HaveringJunctions";
DROP TRIGGER IF EXISTS "set_create_details_havering_junctions" ON havering_operations."HaveringJunctions";
CREATE TRIGGER "create_geometryid_havering_junctions" BEFORE INSERT ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION havering_operations."create_geometryid_havering"();
CREATE TRIGGER "set_create_details_havering_junctions" BEFORE INSERT ON havering_operations."HaveringJunctions" FOR EACH ROW EXECUTE FUNCTION "public"."set_create_details"();
