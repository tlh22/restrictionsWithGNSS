---
CREATE OR REPLACE FUNCTION mhtc_operations."get_road_casement_corner_points"(road_casement_geom geometry,
                                                                         corner_point_geom geometry,
                                                                         distance_from_corner_point float) RETURNS geometry[] AS /*"""*/ $$
    import plpy
    #from plpygis import Geometry
    """
    This function generates the section of road casement of interest
    """
    line_segment_geom = None
    #
    plpy.info('get_road_casement_section 1: corner_point_geom:{})'.format(corner_point_geom))
    # get the length of the line
    plan = plpy.prepare("SELECT ST_Length($1::geometry) as l", ['geometry'])
    restrictionLength = plpy.execute(plan, [road_casement_geom])[0]["l"]
    #restrictionLength = plpy.execute("SELECT ST_Length({})".format(road_casement_geom))
    plpy.info('get_road_casement_section 1a: restrictionLength:{})'.format(restrictionLength))
    #
    fraction = distance_from_corner_point / restrictionLength
    # obtain the location of the corner point
    plan = plpy.prepare("SELECT ST_LineLocatePoint($1,$2) as p", ['geometry', 'geometry'])
    corner_point_location = plpy.execute(plan, [road_casement_geom, corner_point_geom])[0]["p"]
    #corner_point_location = plpy.execute("SELECT ST_LineLocatePoint({}::geometry,{}::geometry)".format(road_casement_geom, corner_point_geom))
    #
    start_point_location = corner_point_location - fraction
    end_point_location = corner_point_location + fraction
    #
    plpy.info('get_road_casement_section 2: restrictionLength: {}; start_point_location:{}; end_point_location: {})'.format(restrictionLength, start_point_location, end_point_location))
    # now check start/end points
    if corner_point_location == 0.0:
        # line becomes end->1 + 0->start
        plan = plpy.prepare("SELECT ST_MakeLine(ST_Collect(ST_LineSubstring($1::geometry, $2, 1.0), ST_LineSubstring($1::geometry, 0.0, $3)))  as x", ['geometry', 'float', 'float'])
        line_segment_geom = plpy.execute(plan, [road_casement_geom, end_point_location, start_point_location])[0]["x"]
    elif start_point_location < 0.0:
        # line becomes start->1 + 0->end
        start_point_location = 1.0 + start_point_location

        line_segment_pts = []

        plan = plpy.prepare("SELECT ST_LineSubstring($1, $2, 1.0) as x", ['geometry', 'float'])
        start_segment_geom = plpy.execute(plan, [road_casement_geom, start_point_location])[0]["x"]
        #start_segment_pts = plpy.execute("SELECT (pts).geom FROM (SELECT ST_DumpPoints(ST_LineSubstring(ST_GeomFromText({}), {}, 1.0)) AS pts)".format(road_casement_geom_txt, start_point_location))
        #plan = plpy.prepare("SELECT (pts).geom FROM (SELECT ST_DumpPoints(ST_LineSubstring($1, $2, 1.0)) AS pts) as x", ['geometry', 'float'])
        plan = plpy.prepare("SELECT path, geom FROM (SELECT (ST_DumpPoints($1::geometry)).*) as x ", ['geometry'])
        start_segment_pts = plpy.execute(plan, [start_segment_geom])
        plpy.info('get_road_casement_section 2a: len start_segment_pts:{})'.format(len(start_segment_pts)))
        for i in range(0, len(start_segment_pts)-1, 1):
            #plpy.info('get_road_casement_section 2a: start_segment_pts:{})'.format(start_segment_pts[i]["geom"]))
            line_segment_pts.append(start_segment_pts[i]["geom"])

        #
        #end_segment_pts = plpy.execute("SELECT (pts).geom FROM (SELECT ST_DumpPoints(ST_LineSubstring(ST_GeomFromText({}), 0.0, {})) AS pts)".format(road_casement_geom_txt, end_point_location))
        #plan = plpy.prepare("SELECT (pts).geom FROM (SELECT ST_DumpPoints(ST_LineSubstring($1::geometry, 0.0, $2)) AS pts)  as x", ['geometry', 'float'])
        #end_segment_pts = plpy.execute(plan, [road_casement_geom, end_point_location])[]["x"]
        #
        #plpy.info('get_road_casement_section 2b: end_segment_pts:{})'.format(end_segment_pts))
        #line_segment_pts = start_segment_pts
        #for pt in range (1, len(end_segment_pts)-1, 1):  # skip the first point which is common
        #    #for pt in end_segment_pts:  # skip the first point which is common
        #    line_segment_pts.append(pt)
        #

        plan = plpy.prepare("SELECT ST_LineSubstring($1, 0.0, $2) as x", ['geometry', 'float'])
        end_segment_geom = plpy.execute(plan, [road_casement_geom, end_point_location])[0]["x"]

        #start_segment_pts = plpy.execute("SELECT (pts).geom FROM (SELECT ST_DumpPoints(ST_LineSubstring(ST_GeomFromText({}), {}, 1.0)) AS pts)".format(road_casement_geom_txt, start_point_location))
        #plan = plpy.prepare("SELECT (pts).geom FROM (SELECT ST_DumpPoints(ST_LineSubstring($1, $2, 1.0)) AS pts) as x", ['geometry', 'float'])

        plan = plpy.prepare("SELECT path, geom FROM (SELECT (ST_DumpPoints($1::geometry)).*) as x ", ['geometry'])
        end_segment_pts = plpy.execute(plan, [end_segment_geom])
        plpy.info('get_road_casement_section 2b: len end_segment_pts:{})'.format(len(end_segment_pts)))
        for i in range(1, len(end_segment_pts)-1, 1):
            #plpy.info('get_road_casement_section 2a: start_segment_pts:{})'.format(end_segment_pts[i]["geom"]))
            line_segment_pts.append(end_segment_pts[i]["geom"])

        plan = plpy.prepare("SELECT ST_SetSRID(ST_MakeLine($1),27700)  as x", ['geometry[]'])
        line_segment_geom = plpy.execute(plan, [line_segment_pts])[0]["x"]

    elif end_point_location > 1.0:
        # line becomes start->1 + 0->end
        end_point_location = end_point_location - 1.0
        #
        plan = plpy.prepare("SELECT ST_LineInterpolatePoint($1::geometry, $2) as x", ['geometry', 'float'])
        start_point_geom = plpy.execute(plan, [road_casement_geom, start_point_location])[0]["x"]
        #
        plan = plpy.prepare("SELECT ST_LineInterpolatePoint($1::geometry, $2)  as x", ['geometry', 'float'])
        end_point_geom = plpy.execute(plan, [road_casement_geom, end_point_location])[0]["x"]
        #
        #plan = plpy.prepare("SELECT ST_SetSRID(ST_MakeLine($1::geometry, $2::geometry),27700)  as x", ['geometry', 'geometry'])
        #line_segment_geom = plpy.execute(plan, [end_segment_geom, start_segment_geom])[0]["x"]
    else:
        plan = plpy.prepare("SELECT ST_SetSRID(ST_LineSubstring($1::geometry, $2, $3),27700) as x", ['geometry', 'float', 'float'])
        line_segment_geom = plpy.execute(plan, [road_casement_geom, start_point_location, end_point_location])[0]["x"]

    plan = plpy.prepare("SELECT ST_LineInterpolatePoint($1::geometry, $2) as x", ['geometry', 'float'])
    start_point_geom = plpy.execute(plan, [road_casement_geom, start_point_location])[0]["x"]
    #
    plan = plpy.prepare("SELECT ST_LineInterpolatePoint($1::geometry, $2)  as x", ['geometry', 'float'])
    end_point_geom = plpy.execute(plan, [road_casement_geom, end_point_location])[0]["x"]

    plpy.info('get_road_casement_section 3  : start_point_location:{}; end_point_location: {})'.format(start_point_location, end_point_location))
    return [start_point_geom, end_point_geom]
$$ LANGUAGE plpython3u;


WITH cornerDetails AS (
SELECT c.id, c.geom As corner_geom, r.geom as road_casement_geom
FROM mhtc_operations."Corners_Test" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.geom, 0.1))
 )
 SELECT d.id, mhtc_operations."get_road_casement_section_2"(d.road_casement_geom, d.corner_geom, 10.0)
 FROM cornerDetails d;

--

DROP TABLE IF EXISTS mhtc_operations."TestCornerPoints";

CREATE TABLE mhtc_operations."TestCornerPoints"
(
	"id" integer,
    pts geometry(Point)[],
	start_pt geometry(Point),
	end_pt geometry(Point)
);

WITH cornerDetails AS (
SELECT c.id, c.geom As corner_geom, r.geom as road_casement_geom
FROM mhtc_operations."Corners_Test" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.geom, 0.1))
 )
 INSERT INTO mhtc_operations."TestCornerPoints" (id, pts)
 SELECT id, mhtc_operations."get_road_casement_section_2"(d.road_casement_geom, d.corner_geom, 10.0)
 FROM cornerDetails d;

 ALTER TABLE ONLY mhtc_operations."TestCornerPoints"
    ADD CONSTRAINT "TestCornerPoints_pkey" PRIMARY KEY ("id");

UPDATE mhtc_operations."TestCornerPoints"
SET start_pt = pts[1];

UPDATE mhtc_operations."TestCornerPoints"
SET end_pt = pts[2];