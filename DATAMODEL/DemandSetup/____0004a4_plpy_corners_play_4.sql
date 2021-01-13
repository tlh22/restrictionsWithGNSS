---
CREATE OR REPLACE FUNCTION mhtc_operations."test_py"(distance_from_corner_point float) RETURNS geometry AS /*"""*/ $$
    import plpy
    #from sys import path
    #path.append( 'C:\\Users\\marie_000\\AppData\\Roaming\\QGIS\\QGIS3\\profiles\\default\\python\\plugins' )
    #from TOMs.generateGeometryUtils import generateGeometryUtils
    #from TOMs.core.TOMsMessageLog import TOMsMessageLog

    from qgis.core import (
        Qgis,
        QgsExpressionContextUtils,
        QgsMessageLog,
        QgsFeature,
        QgsGeometry, QgsGeometryUtils,
        QgsFeatureRequest,
        QgsPoint,
        QgsPointXY,
        QgsRectangle,
        QgsVectorLayer,
        QgsProject,
        QgsWkbTypes
    )

    params = TOMsParams()
    #from plpygis import Geometry
    """
    This function generates the section of road casement of interest
    """
    line_segment_geom = None

    return line_segment_geom

    def findFeatureAt2(feature, layerPt, layer, tolerance):
        """ Find the feature close to the given position.

            'layerPt' is the position to check, in layer coordinates.
            'layer' is specified layer
            'tolerance' is search distance in layer units

            If no feature is close to the given coordinate, we return None.
        """

        #TOMsMessageLog.logMessage("In findFeatureAt2. Incoming layer: " + str(layer) + "tol: " + str(tolerance), level=Qgis.Info)

        searchRect = QgsRectangle(layerPt.x() - tolerance,
                                  layerPt.y() - tolerance,
                                  layerPt.x() + tolerance,
                                  layerPt.y() + tolerance)

        ST_MakeEnvelope(float xmin, float ymin, float xmax, float ymax, integer srid=unknown);

        request = QgsFeatureRequest()
        request.setFilterRect(searchRect)
        request.setFlags(QgsFeatureRequest.ExactIntersect)

        for feature in layer.getFeatures(request):
            TOMsMessageLog.logMessage("In findFeatureAt2. feature found", level=Qgis.Info)
            return feature  # Return first matching feature.

        return None


$$ LANGUAGE plpython3u;



-- get nearest feature

WITH objects AS
    (SELECT
        name,
        (ST_Dump(roads.geom)).geom AS geometries
    FROM roads),
point AS
    (SELECT
        'SRID=4326;POINT(long lat)'::geometry AS point
    );

SELECT DISTINCT ON
    (ST_Distance(point, geometries)),
    objects.name
FROM objects, point
    ORDER BY ST_Distance(point, geometries)
    LIMIT 1;

CREATE OR REPLACE FUNCTION nearestFeature(pt geometry, tableOfInterest text) RETURNS geometry AS
EXEC SQL BEGIN DECLARE SECTION;
char dbaname[128];
char datname[128];
char *stmt = "SELECT u.usename as dbaname, d.datname "
             "  FROM pg_database d, pg_user u "
             "  WHERE d.datdba = u.usesysid";
EXEC SQL END DECLARE SECTION;


'SELECT ST_ClosestPoint($1, c.geom) AS geom FROM mhtc_operations."Corners_Single" c
                    WHERE ST_Intersects($1, ST_Buffer(c.geom, 2.0))
                    AND ST_DWithin($1, c.geom, 1.0)'
LANGUAGE SQL;


CREATE OR REPLACE FUNCTION report_get_countries_new (starts_with text
                                                   , ends_with   text = NULL)
  RETURNS text AS
$func$
DECLARE
   sql text := 'SELECT * FROM lookups.countries WHERE country_name >= $1';
BEGIN
   IF ends_with IS NOT NULL THEN
      sql := sql || ' AND country_name <= $2';
   END IF;

   RETURN QUERY EXECUTE sql
   USING starts_with, ends_with;
END
$func$ LANGUAGE plpgsql;


---

DROP FUNCTION mhtc_operations."AzToNearestRoadCentreLine";

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
SELECT c.id, ST_AsText(c."StartPt"), mhtc_operations."AzToNearestRoadCentreLine"(c."StartPt", 10.0)
FROM mhtc_operations."CornerSegementEndPts" c;


--
DROP FUNCTION mhtc_operations."getCornerApexPoint";

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

    RAISE NOTICE 'apexPt_GeometryType', apexPt_GeometryType;

    IF apexPt_GeometryType != 'ST_Point' THEN
        apexPt = NULL;
    END IF;

    RETURN apexPt;

END;
$BODY$;

--

SELECT c.id, St_AsText(mhtc_operations."getCornerApexPoint"(c.id, 10.0))
FROM mhtc_operations."Corners" c

DROP TABLE IF EXISTS mhtc_operations."CornerApexPts";

CREATE TABLE mhtc_operations."CornerApexPts"
(
	"id" integer,
	"ApexPt" geometry(Point)
);

INSERT INTO mhtc_operations."CornerApexPts" (id, "ApexPt")
SELECT c.id, mhtc_operations."getCornerApexPoint"(c.id, 10.0)
FROM mhtc_operations."Corners" c

ALTER TABLE ONLY mhtc_operations."CornerApexPts"
    ADD CONSTRAINT "CornerApexPts_pkey" PRIMARY KEY ("id");