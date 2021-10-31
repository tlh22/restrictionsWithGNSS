
-- disable triggers
/**
ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs" AS c
SET "RoadName" = closest."RoadName", "USRN" = closest."USRN"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, s.geom) AS geom,
        ST_Distance(c1.geom, s.geom) AS length, c1."RoadName", c1."USRN"
      FROM toms."Signs" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 10.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."RoadName" IS NULL;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;
**/
-- Deal with other tables

--DROP mhtc_operations.setRoadNameForTable;

CREATE OR REPLACE FUNCTION mhtc_operations.setRoadNameForTable(tablename regclass)
  RETURNS BOOLEAN AS
$func$
DECLARE
	 squery text;
	 geom_type text;
	 result BOOLEAN;
	 text_var1 text;
     text_var2 text;
     text_var3 text;
     r RECORD;
     geom_field text;
     table_schema TEXT;
     table_name TEXT;
     table_details ARRAY;
BEGIN
   RAISE NOTICE 'set road details for: %', tablename;

   -- Need to check whether or not the table has a geom column

   squery = format('ALTER TABLE %s DISABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   -- Need to get the geometry type(s) for the table

/**
   squery = format('SELECT f_geometry_column, type
                    FROM geometry_columns
                    WHERE f_table_schema = (parse_ident(%1$s))[1]
                    AND f_table_name = (parse_ident(%1$s))[2]
                    ', tablename);

   -- NOW NEED TO LOOP
***/

    SELECT (parse_ident(tablename))
    INTO table_details;

    table_schema = table_details[1];
    table_name = table_details[2];

    RAISE NOTICE 'sconsidering: schema: %. table: %', table_schema, table_name;

    FOR r IN SELECT f_geometry_column, type
             FROM geometry_columns
             WHERE f_table_schema = table_schema
             AND f_table_name = table_name
        LOOP
          RAISE NOTICE '%', r;

           --squery = format('SELECT GeometryType(%s) FROM %s
           --                ', geom_field, tablename);
           --EXECUTE squery INTO geom_type;

           geom_type = r.type;
           geom_field = r.f_geometry_column;

           IF geom_type = 'POINT' THEN

               squery = format('
               UPDATE %1$s AS c
               SET "RoadName" = closest."RoadName", "USRN" = closest."USRN"
               FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
                            ST_ClosestPoint(c1.geom, s.%2$s) AS geom,
                            ST_Distance(c1.geom, s.%2$s) AS length, c1."RoadName", c1."USRN"
                    FROM %1$s s, mhtc_operations."RC_Sections_merged" c1
                    WHERE ST_DWithin(c1.geom, s.%2$s, 25.0)
                    ORDER BY s."GeometryID", length) AS closest
                WHERE c."GeometryID" = closest.id
                AND c."RoadName" IS NULL
                AND c.%2$s IS NOT NULL
               ', tablename, geom_field);
               EXECUTE squery;

           ELSIF geom_type = 'LINESTRING' THEN

               squery = format('
               UPDATE %1$s AS c
               SET "RoadName" = closest."RoadName", "USRN" = closest."USRN"
               FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id,
                            ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.%2$s, 0.5)) AS geom,
                            ST_Distance(cl.geom, ST_LineInterpolatePoint(s.%2$s, 0.5)) AS length, cl."RoadName", cl."USRN"
                    FROM %1$s s, mhtc_operations."RC_Sections_merged" cl
                    WHERE ST_DWithin(cl.geom, s.%2$s, 25.0)
                    ORDER BY s."GeometryID", length) AS closest
               WHERE c."GeometryID" = closest.id
               AND c."RoadName" IS NULL
               AND c.%2$s IS NOT NULL
               ', tablename, geom_field);
               BEGIN
               EXECUTE squery;
               EXCEPTION WHEN OTHERS THEN
                    GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
                                  text_var2 = PG_EXCEPTION_DETAIL,
                                  text_var3 = PG_EXCEPTION_HINT;
                    RAISE NOTICE 'error: %. %. %. %', squery, text_var1, text_var2, text_var3;
               END;

           ELSIF geom_type = 'POLYGON' THEN

               squery = format('
               UPDATE %1$s AS c
               SET "RoadName" = closest."RoadName", "USRN" = closest."USRN"
               FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id,
                            ST_ClosestPoint(cl.geom, s.%2$s) AS geom,
                            ST_Distance(ST_ClosestPoint(cl.geom, s.%2$s), ST_ClosestPoint(s.%2$s, cl.geom)) AS length, cl."RoadName", cl."USRN"
                    FROM %1$s s, mhtc_operations."RC_Sections_merged" cl
                    WHERE ST_DWithin(cl.geom, s.%2$s, 25.0)
                    ORDER BY s."GeometryID", length) AS closest
               WHERE c."GeometryID" = closest.id
               AND c."RoadName" IS NULL
               AND c.%2$s IS NOT NULL
               ', tablename, geom_field);
               BEGIN
               EXECUTE squery;
               EXCEPTION WHEN OTHERS THEN
                    GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
                                  text_var2 = PG_EXCEPTION_DETAIL,
                                  text_var3 = PG_EXCEPTION_HINT;
                    RAISE NOTICE 'error: %. %. %. %', squery, text_var1, text_var2, text_var3;
               END;

           ELSE

                result = False;

           END IF;

        END LOOP;

   squery = format('ALTER TABLE %s ENABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   --RAISE NOTICE '2: %', squery;
   RETURN True;
END;
$func$ LANGUAGE plpgsql;


WITH relevant_tables AS (
      select table_schema, table_name, concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'RoadName'
      AND (
          (table_schema IN ('toms')
          AND table_name IN ('Signs', 'RestrictionPolygons'))
          OR table_schema IN ('moving_traffic')
          OR (table_schema IN ('highway_assets')
          AND table_name IN ('VehicleBarriers'))
          )
    ), geom_tables AS (
        SELECT full_table_name
        FROM information_schema.columns i, relevant_tables
        WHERE i.table_name = relevant_tables.table_name
        AND i.table_schema = relevant_tables.table_schema
        --AND column_name = 'geom_point'
    )
        SELECT mhtc_operations.setRoadNameForTable(full_table_name)
        FROM geom_tables;
