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

--

--- identify extent of corner "protection" on kerbline using details from "CornerSegments"

---

DROP FUNCTION IF EXISTS mhtc_operations."AzToNearestRoadCentreLine";

CREATE OR REPLACE FUNCTION mhtc_operations."AzToNearestRoadCentreLine"(kerbPt_txt text,
                                                                       tolerance float)
    RETURNS float
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   azimuth_to_cl float = 0;
   kerbPt geometry;
BEGIN

	SELECT ST_GeomFromText(kerbPt_txt, 27700) INTO kerbPt;

	RAISE NOTICE 'kerbPt_txt(%)', kerbPt_txt;
    --RAISE NOTICE 'tolerance(%)', tolerance;

    SELECT ST_Azimuth(kerbPt, ST_ClosestPoint(r.geom, kerbPt))
    INTO azimuth_to_cl
    FROM highways_network.roadlink r
    WHERE ST_Intersects (r.geom, ST_Buffer(kerbPt, tolerance))
    ORDER BY ST_Distance(kerbPt, ST_ClosestPoint(r.geom, kerbPt)) ASC
	LIMIT 1;

    RAISE NOTICE 'azimuth_to_cl(%)', azimuth_to_cl;

    RETURN azimuth_to_cl;

END;
$BODY$;

--
DROP FUNCTION IF EXISTS mhtc_operations."getCornerApexPoint";

CREATE OR REPLACE FUNCTION mhtc_operations."getCornerApexPoint"(cnr_id integer,
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
           ST_Azimuth(c."StartPt", cn.geom), ST_Azimuth(c."EndPt", cn.geom)
    INTO start_pt, end_pt, start_pt_azimuth_to_apex, end_pt_azimuth_to_apex, start_pt_azimuth_to_cnr, end_pt_azimuth_to_cnr
    FROM mhtc_operations."CornerSegmentEndPts" c, mhtc_operations."Corners" cn
    WHERE c.id = cnr_id
    AND c.id = cn.id;

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

DROP TABLE IF EXISTS mhtc_operations."CornerApexPts";

CREATE TABLE mhtc_operations."CornerApexPts"
(
	"id" integer,
	"ApexPt" geometry(Point)
);

INSERT INTO mhtc_operations."CornerApexPts" (id, "ApexPt")
SELECT c.id, mhtc_operations."getCornerApexPoint"(c.id, 10.0)
FROM mhtc_operations."Corners" c;

DELETE FROM mhtc_operations."CornerApexPts"
WHERE "ApexPt" IS NULL;

ALTER TABLE ONLY mhtc_operations."CornerApexPts"
    ADD CONSTRAINT "CornerApexPts_pkey" PRIMARY KEY ("id");

GRANT ALL ON TABLE mhtc_operations."CornerApexPts" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerApexPts" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerApexPts" TO toms_public;

--

--SELECT c.id, St_AsText(mhtc_operations."getCornerApexPoint"(c.id, 10.0))
--FROM mhtc_operations."Corners" c

DROP FUNCTION IF EXISTS mhtc_operations."getCornerExtents";

CREATE OR REPLACE FUNCTION mhtc_operations."getCornerExtents"(cnr_id integer)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
BEGIN

    -- get the corner protection distance from "project_parameters"

    -- get intersection points between apex point buffer and corner segment
    SELECT ST_Intersection(c.geom, ST_Buffer(a."ApexPt", mhtc_operations."getParameter"('CornerProtectionDistance')::float))
    INTO cornerProtectionLineString
    FROM mhtc_operations."CornerSegments" c, mhtc_operations."CornerApexPts" a
    WHERE c.id = cnr_id
    AND c.id = a.id;

    RETURN cornerProtectionLineString;

END;
$BODY$;

DROP TABLE IF EXISTS mhtc_operations."CornerProtectionSections";

CREATE TABLE mhtc_operations."CornerProtectionSections"
(
	"id" integer,
	"geom" geometry
);

INSERT INTO mhtc_operations."CornerProtectionSections" (id, geom)
SELECT c.id, mhtc_operations."getCornerExtents"(c.id)
FROM mhtc_operations."Corners" c;

ALTER TABLE ONLY mhtc_operations."CornerProtectionSections"
    ADD CONSTRAINT "CornerProtectionSections_pkey" PRIMARY KEY ("id");

GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerProtectionSections" TO toms_public;

--

DROP TABLE IF EXISTS  mhtc_operations."CornerProtectionSections_Single" CASCADE;

CREATE TABLE mhtc_operations."CornerProtectionSections_Single"
(
  id SERIAL,
  geom geometry(LineString,27700),
  CONSTRAINT "CornerProtectionSections_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CornerProtectionSections_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO postgres;

-- Index: public."sidx_Corners_Single_geom"

-- DROP INDEX public."sidx_Corners_Single_geom";

CREATE INDEX "sidx_CornerProtectionSections_Single_geom"
  ON mhtc_operations."CornerProtectionSections_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."CornerProtectionSections_Single" (geom)
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."CornerProtectionSections";

GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerProtectionSections_Single" TO toms_public;

--

--- measure distance from corner ...

DROP TABLE IF EXISTS mhtc_operations."CornerProtectionSections";

CREATE TABLE mhtc_operations."CornerProtectionSections"
(
	"id" integer,
	"geom" geometry
);

WITH cornerDetails AS (
SELECT c.id, c.geom As corner_geom, r.geom as road_casement_geom
FROM mhtc_operations."Corners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.geom, 0.1))
 )
 INSERT INTO mhtc_operations."CornerProtectionSections" (id, geom)
 SELECT d.id, mhtc_operations."get_road_casement_section"(d.id, d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)
 FROM cornerDetails d;

-- print out duplicate entries
SELECT id, count(*)
FROM mhtc_operations."CornerProtectionSections"
GROUP BY id
HAVING count(*) > 1;

DELETE FROM mhtc_operations."CornerProtectionSections" c1
WHERE id IN (
    SELECT id
    FROM (
        SELECT id, count(*)
        FROM mhtc_operations."CornerProtectionSections"
        GROUP BY id
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY mhtc_operations."CornerProtectionSections"
    ADD CONSTRAINT "CornerProtectionSections_pkey" PRIMARY KEY ("id");

GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerProtectionSections" TO toms_public;

--

DROP TABLE IF EXISTS  mhtc_operations."CornerProtectionSections_Single" CASCADE;

CREATE TABLE mhtc_operations."CornerProtectionSections_Single"
(
  id SERIAL,
  geom geometry(LineString,27700),
  CONSTRAINT "CornerProtectionSections_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CornerProtectionSections_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO postgres;

-- Index: public."sidx_Corners_Single_geom"

-- DROP INDEX public."sidx_Corners_Single_geom";

CREATE INDEX "sidx_CornerProtectionSections_Single_geom"
  ON mhtc_operations."CornerProtectionSections_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."CornerProtectionSections_Single" (geom)
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."CornerProtectionSections";

GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerProtectionSections_Single" TO toms_public;

--

-- deal with unacceptability

DROP TABLE IF EXISTS mhtc_operations."Supply_orig2" CASCADE;

CREATE TABLE mhtc_operations."Supply_orig2"
(
    --"RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700) NOT NULL,
    "RestrictionLength" double precision NOT NULL,
    "RestrictionTypeID" integer NOT NULL,
    "GeomShapeID" integer NOT NULL,
    "AzimuthToRoadCentreLine" double precision,
    "Notes" character varying(254) COLLATE pg_catalog."default",
    "Photos_01" character varying(255) COLLATE pg_catalog."default",
    "Photos_02" character varying(255) COLLATE pg_catalog."default",
    "Photos_03" character varying(255) COLLATE pg_catalog."default",
    "RoadName" character varying(254) COLLATE pg_catalog."default",
    "USRN" character varying(254) COLLATE pg_catalog."default",
    --"label_X" double precision,
    --"label_Y" double precision,
    --"label_Rotation" double precision,
    --"labelLoading_X" double precision,
    --"labelLoading_Y" double precision,
    --"labelLoading_Rotation" double precision,
    --"label_TextChanged" character varying(254) COLLATE pg_catalog."default",
	label_pos geometry(MultiPoint,27700),
    label_ldr geometry(MultiLineString,27700),
	label_loading_pos geometry(MultiPoint,27700),
    label_loading_ldr geometry(MultiLineString,27700),
    "OpenDate" date,
    "CloseDate" date,
    "CPZ" character varying(40) COLLATE pg_catalog."default",
    "LastUpdateDateTime" timestamp without time zone,
    "LastUpdatePerson" character varying(255) COLLATE pg_catalog."default",
    "BayOrientation" double precision,
    "NrBays" integer NOT NULL DEFAULT '-1'::integer,
    "TimePeriodID" integer,
    "PayTypeID" integer,
    "MaxStayID" integer,
    "NoReturnID" integer,
    "NoWaitingTimeID" integer,
    "NoLoadingTimeID" integer,
    "UnacceptableTypeID" integer,
    "ParkingTariffArea" character varying(10) COLLATE pg_catalog."default",
    "AdditionalConditionID" integer,
    "ComplianceRoadMarkingsFaded" integer,
    "ComplianceRestrictionSignIssue" integer,
    "ComplianceLoadingMarkingsFaded" integer,
    "ComplianceNotes" character varying(254) COLLATE pg_catalog."default",
    "MHTC_CheckIssueTypeID" integer,
    "MHTC_CheckNotes" character varying(254) COLLATE pg_catalog."default",
    "PayParkingAreaID" character varying(255) COLLATE pg_catalog."default",
    "PermitCode" character varying(255) COLLATE pg_catalog."default",
    "MatchDayTimePeriodID" integer,
    "MatchDayEventDayZone" character varying(40),
    "Capacity" integer,
    "BayWidth" double precision,
    "SectionID" integer,
	"StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    --CONSTRAINT "Supply_orig2_pkey" PRIMARY KEY ("RestrictionID"),
    --CONSTRAINT "Supply_orig2_GeometryID_key" UNIQUE ("GeometryID")
    CONSTRAINT "Supply_orig2_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Supply_orig2"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr","OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr","OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply";

--
CREATE OR REPLACE FUNCTION mhtc_operations."cnrBufferExtent"(geometry, real) RETURNS geometry AS
'SELECT ST_Collect(ST_ExteriorRing(ST_Buffer(c.geom, $2, ''endcap=flat''))) AS geom
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Intersects($1, ST_Buffer(c.geom, $2, ''endcap=flat''))'
LANGUAGE SQL;

DELETE FROM mhtc_operations."Supply";

INSERT INTO "mhtc_operations"."Supply" (
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
       geom)
SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    (ST_Dump(ST_Split(lg1.geom, mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25)))).geom
    FROM "mhtc_operations"."Supply_orig2" lg1 LEFT JOIN LATERAL mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25) pt ON TRUE
	WHERE lg1."RestrictionTypeID" in (201, 216, 217, 224, 225, 226, 227, 229)

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr","OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",  "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom
	FROM "mhtc_operations"."Supply_orig2" lg1
    WHERE mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25) IS NULL
    AND lg1."RestrictionTypeID" in (201, 216, 217, 224, 225, 226, 227, 229)

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    geom
	FROM "mhtc_operations"."Supply_orig2" lg1
    WHERE lg1."RestrictionTypeID" NOT IN (201, 216, 217, 224, 225, 226, 227, 229);

-- deal with acceptablity around corners

-- Unmarked
UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (216, 225);

-- SYLs 
UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (201, 224);

-- SRLs
UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 222, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (217, 226);

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (227, 229);

--


CREATE OR REPLACE FUNCTION line_length_at_corner(IN cornerID int) RETURNS float AS
$BODY$
DECLARE
    len_DYL float;
    len_Bays float;
    len_relevant_line float;
BEGIN

        len_DYL = 0;
        len_Bays = 0;
        len_relevant_line = 0;

        RAISE NOTICE '**** CornerID: %', cornerID;

        SELECT COALESCE(SUM(ST_Length(ST_Intersection(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1)))), 0) INTO len_DYL
        FROM mhtc_operations."CornerSegments" c, "toms"."Lines" l
        WHERE c."id" = cornerID
        AND ST_Intersects(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1))
        AND l."RestrictionTypeID" NOT IN (201, 221, 224, 216, 220);

        --RAISE NOTICE 'DYL: %', len_DYL;

        SELECT COALESCE(SUM(ST_Length(ST_Intersection(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1)))), 0) INTO len_Bays
        FROM mhtc_operations."CornerSegments" c, "toms"."Bays" l
		WHERE c."id" = cornerID
        AND ST_Intersects(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1));

        --RAISE NOTICE 'Bays: %', len_Bays;

        len_relevant_line = len_DYL + len_Bays;

        RAISE NOTICE 'len_relevant_line: %', len_relevant_line;

        RETURN len_relevant_line;

END
$BODY$
LANGUAGE plpgsql;

DROP TABLE IF EXISTS mhtc_operations."LineLengthAtCorner";

CREATE TABLE mhtc_operations."LineLengthAtCorner"
(
	"id" integer,
	"LineLength" double precision
);

WITH corners AS (
SELECT "id" FROM mhtc_operations."Corners" c)
    INSERT INTO mhtc_operations."LineLengthAtCorner" (id, "LineLength")
    SELECT corners.id, line_length_at_corner(corners.id)
	FROM corners;

 ALTER TABLE ONLY mhtc_operations."LineLengthAtCorner"
    ADD CONSTRAINT "LineLengthAtCorner_pkey" PRIMARY KEY ("id");

SELECT id, "LineLength"
	FROM mhtc_operations."LineLengthAtCorner"
	WHERE "LineLength" < 19.0;

SELECT "LineLength"::int AS grouping, COUNT(id) AS nrCorners
FROM  mhtc_operations."LineLengthAtCorner"
GROUP BY  grouping
ORDER  BY grouping DESC;

GRANT ALL ON TABLE mhtc_operations."LineLengthAtCorner" TO postgres;
GRANT ALL ON TABLE mhtc_operations."LineLengthAtCorner" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."LineLengthAtCorner" TO toms_public;


--

-- classify corners according to the amount of line


ALTER TABLE mhtc_operations."LineLengthAtCorner"
    ADD COLUMN "CornerProtectionCategoryTypeID" integer;

DROP TABLE IF EXISTS "mhtc_operations"."CornerProtectionCategoryTypes";

CREATE TABLE "mhtc_operations"."CornerProtectionCategoryTypes" (
    "Code" integer NOT NULL,
    "Description" character varying
);

CREATE SEQUENCE "mhtc_operations"."CornerProtectionCategoryType_Code_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "mhtc_operations"."CornerProtectionCategoryType_Code_seq" OWNER TO "postgres";

ALTER SEQUENCE "mhtc_operations"."CornerProtectionCategoryType_Code_seq" OWNED BY "mhtc_operations"."CornerProtectionCategoryTypes"."Code";

ALTER TABLE ONLY "mhtc_operations"."CornerProtectionCategoryTypes" ALTER COLUMN "Code" SET DEFAULT "nextval"('"mhtc_operations"."CornerProtectionCategoryType_Code_seq"'::"regclass");

ALTER TABLE ONLY "mhtc_operations"."CornerProtectionCategoryTypes"
    ADD CONSTRAINT "CornerProtectionCategoryType_pkey" PRIMARY KEY ("Code");

ALTER TABLE ONLY mhtc_operations."LineLengthAtCorner"
    ADD CONSTRAINT "LineLengthAtCorner_CornerProtectionCategoryTypeID_fkey" FOREIGN KEY ("CornerProtectionCategoryTypeID") REFERENCES "mhtc_operations"."CornerProtectionCategoryTypes"("Code");

-- add values

INSERT INTO "mhtc_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (1, 'No suitable markings');
INSERT INTO "mhtc_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (2, 'Some suitable markings');
INSERT INTO "mhtc_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (3, 'In compliance');

-- update

UPDATE mhtc_operations."LineLengthAtCorner"
    SET "CornerProtectionCategoryTypeID" = 1
    WHERE "LineLength" = 0.0;

UPDATE mhtc_operations."LineLengthAtCorner"
    SET "CornerProtectionCategoryTypeID" = 2
    WHERE "LineLength" > 0.0 and "LineLength" < 16.0;

UPDATE mhtc_operations."LineLengthAtCorner"
    SET "CornerProtectionCategoryTypeID" = 3
    WHERE "LineLength" >= 16.0;

-- group by ward

/*
select w."NAME", p."CornerProtectionCategoryTypeID",  count(*) as Totals
   from
      (SELECT c.geom, l."CornerProtectionCategoryTypeID"
	   FROM mhtc_operations."Corners" c, mhtc_operations."LineLengthAtCorner" l
	   WHERE c.id = l.id) p, local_authority."Wards" w
   WHERE ST_Within (p.geom, w.geom)
   group by w."NAME", p."CornerProtectionCategoryTypeID"
*/