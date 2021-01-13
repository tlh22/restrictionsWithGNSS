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