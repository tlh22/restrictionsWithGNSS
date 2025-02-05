---
CREATE OR REPLACE FUNCTION mhtc_operations."get_road_casement_section"(corner_id int,
                                                                       road_casement_geom geometry,
                                                                       corner_point_geom geometry,
                                                                       distance_from_corner_point float) RETURNS geometry AS /*"""*/ $$
    import plpy
    #from plpygis import Geometry
    """
    This function generates the section of road casement of interest
    """
    line_segment_geom = None
	
    if distance_from_corner_point is None:
        return None
    #
    #plpy.info('get_road_casement_section 1: corner_point_geom:{})'.format(corner_point_geom))
    #plpy.info('get_road_casement_section: cornerID: {})'.format(corner_id))
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

    #plpy.info('get_road_casement_section 2: restrictionLength: {}; start_point_location:{}; end_point_location: {})'.format(restrictionLength, start_point_location, end_point_location))
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


/***
    WITH cornerDetails AS (
    SELECT c.id, c.geom As corner_geom, r.geom as road_casement_geom
    FROM mhtc_operations."Corners_Test" c, topography."road_casement" r
    WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.geom, 0.1))
     )
 SELECT d.id, ST_Length(mhtc_operations."get_road_casement_section_3"(d.road_casement_geom, d.corner_geom, 10.0)),
                ST_AsText(mhtc_operations."get_road_casement_section_3"(d.road_casement_geom, d.corner_geom, 10.0))
 FROM cornerDetails d;
***/

DROP TABLE IF EXISTS mhtc_operations."CornerSegments";

CREATE TABLE mhtc_operations."CornerSegments"
(
	"id" integer,
	"SegmentLength" double precision,
    geom geometry(LineString)
);

WITH cornerDetails AS (
SELECT c.id, c.geom As corner_geom, r.geom as road_casement_geom
FROM mhtc_operations."Corners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.geom, 0.1))
 )
 INSERT INTO mhtc_operations."CornerSegments" (id, "SegmentLength", geom)
 SELECT d.id, ST_Length(mhtc_operations."get_road_casement_section"(d.id, d.road_casement_geom, d.corner_geom, 10.0)),
                mhtc_operations."get_road_casement_section"(d.id, d.road_casement_geom, d.corner_geom, 10.0)
 FROM cornerDetails d;

DELETE FROM mhtc_operations."CornerSegments" c1
WHERE id IN (
    SELECT id
    FROM (
        SELECT id, count(*)
        FROM mhtc_operations."CornerSegments"
        GROUP BY id
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY mhtc_operations."CornerSegments"
    ADD CONSTRAINT "CornerSegments_pkey" PRIMARY KEY ("id");


GRANT ALL ON TABLE mhtc_operations."CornerSegments" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerSegments" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerSegments" TO toms_public;



--

DROP TABLE IF EXISTS mhtc_operations."CornerSegmentEndPts";

CREATE TABLE mhtc_operations."CornerSegmentEndPts"
(
	"id" integer,
	"StartPt" geometry(Point),
	"EndPt" geometry(Point)
);

INSERT INTO mhtc_operations."CornerSegmentEndPts" (id, "StartPt", "EndPt")
SELECT d.id, ST_StartPoint(d.geom), ST_EndPoint(d.geom)
FROM mhtc_operations."CornerSegments" d;

ALTER TABLE ONLY mhtc_operations."CornerSegmentEndPts"
    ADD CONSTRAINT "CornerSegmentEndPts_pkey" PRIMARY KEY ("id");

GRANT ALL ON TABLE mhtc_operations."CornerSegmentEndPts" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerSegmentEndPts" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerSegmentEndPts" TO toms_public;