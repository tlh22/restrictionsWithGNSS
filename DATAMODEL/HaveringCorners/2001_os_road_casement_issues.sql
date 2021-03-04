-- function to remove "spikes" from road casement. Not sure why/how they were created, but ...

CREATE OR REPLACE FUNCTION havering_operations."clean_road_casement"(road_casement_geom geometry)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    process_geom geometry;
    currPt geometry;
    point_id integer;
    nr_pts integer;
    points_changed boolean;
BEGIN

    -- https://trac.osgeo.org/postgis/wiki/UsersWikiExamplesSpikeRemover

    IF (SELECT ST_GeometryType(road_casement_geom)) = 'ST_Polygon' THEN
        process_geom := ST_Boundary(road_casement_geom);
    ELSE
        process_geom := road_casement_geom;
    END IF;

    nr_pts := ST_NPoints(process_geom);

    RAISE NOTICE 'Nr pts (%)', nr_pts;
    points_changed := true;

    -- process need to interate to complete the clean ...

    WHILE (points_changed = true) LOOP

        RAISE NOTICE 'Starting loop ...';
        points_changed := false;
        point_id := 1;

        IF nr_pts > 3 THEN

            WHILE (point_id <= nr_pts-2)  LOOP
                currPt := ST_PointN(process_geom, point_id);

                --RAISE NOTICE 'Considering pt (%)', point_id;
                --RAISE NOTICE ' -- pt geom (%)', ST_AsText(currPt);
                -- check the point after next ...
                -- NB: ST_PointN is 1-based; ST_removePoint is 0-based

                IF ST_Within(currPt, ST_Buffer(ST_PointN(process_geom, point_id+2), 0.00001)) THEN
                    RAISE NOTICE ' -- deleting pts (%, %)', point_id+1, point_id;
                    --RAISE NOTICE ' -- pt+1 geom (%)', ST_AsText(st_pointn(process_geom, point_id+1));
                    process_geom := ST_RemovePoint(process_geom, point_id+1);
                    process_geom := ST_RemovePoint(process_geom, point_id);
                    nr_pts := nr_pts - 2;
                    points_changed := true;
                END IF;

                IF nr_pts <= 3 THEN
                    EXIT;
                END IF;

                IF ST_Within(currPt, ST_Buffer(ST_PointN(process_geom, point_id+1), 0.00001)) THEN
                    RAISE NOTICE ' ---- deleting pt (%)', point_id+1;
                    --RAISE NOTICE ' ---- pt+1 geom (%)', ST_AsText(st_pointn(process_geom, point_id));
                    process_geom := ST_RemovePoint(process_geom, point_id);
                    nr_pts := nr_pts - 1;
                    points_changed := true;
                END IF;

                point_id := point_id + 1;

            END LOOP;
        END IF;
    END LOOP;

    RETURN process_geom;

END;
$BODY$;
