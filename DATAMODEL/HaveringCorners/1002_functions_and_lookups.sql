--
-- set up corner protection parameter

INSERT INTO mhtc_operations.project_parameters(
	"Field", "Value")
	VALUES ('CornerProtectionDistance', 10.0);

--DROP FUNCTION IF EXISTS mhtc_operations."getParameter";

CREATE OR REPLACE FUNCTION mhtc_operations."getParameter"(param text) RETURNS text AS
'SELECT "Value"
FROM mhtc_operations."project_parameters"
WHERE "Field" = $1'
LANGUAGE SQL;

-- need mhtc_operations."get_road_casement_section" (it works the same)

--
DROP FUNCTION IF EXISTS havering_operations."getCornerApexPoint";

CREATE OR REPLACE FUNCTION havering_operations."getCornerApexPoint"(cnr_id integer,
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
    WHERE c."CornerID" = cnr_id
    AND c."CornerID" = cn."CornerID";

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

CREATE OR REPLACE FUNCTION havering_operations."getCornerExtentsFromApex"(cnr_id integer)
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
    WHERE c."CornerID" = cnr_id
    AND c."CornerID" = a."CornerID";

    RETURN cornerProtectionLineString;

END;
$BODY$;

--


CREATE OR REPLACE FUNCTION havering_operations.line_junction_protection_at_corner(IN cornerID int) RETURNS geometry AS
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

        SELECT ST_Difference(mhtc_operations."getCornerExtents"(c."CornerID"), ST_Buffer(l.geom, 0.1)) INTO len_DYL
        FROM mhtc_operations."HaveringCorners" h, "toms"."Lines" l
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


