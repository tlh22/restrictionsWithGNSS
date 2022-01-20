-- set road name for all layers

GRANT SELECT ON TABLE mhtc_operations."RC_Sections_merged" TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."RC_Sections_merged" TO toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;

-- Add sectionID

ALTER TABLE toms."Bays"
    ADD COLUMN "SectionID" integer;

ALTER TABLE toms."Lines"
    ADD COLUMN "SectionID" integer;

-- disable triggers

ALTER TABLE toms."Bays" DISABLE TRIGGER all;
ALTER TABLE toms."Lines" DISABLE TRIGGER all;
ALTER TABLE toms."Signs" DISABLE TRIGGER all;


UPDATE toms."Bays" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "USRN" = closest."USRN"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."USRN"
      FROM toms."Bays" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."RoadName" IS NULL;

UPDATE toms."Lines" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "USRN" = closest."USRN"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."USRN"
      FROM toms."Lines" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."RoadName" IS NULL;

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
ALTER TABLE toms."Bays" ENABLE TRIGGER all;
ALTER TABLE toms."Lines" ENABLE TRIGGER all;
ALTER TABLE toms."Signs" ENABLE TRIGGER all;

-- Deal with other tables

CREATE OR REPLACE FUNCTION mhtc_operations.setRoadNameForTable(tablename regclass, geom_field text)
  RETURNS BOOLEAN AS
$func$
DECLARE
	 squery text;
	 geom_type text;
	 result BOOLEAN;
	 text_var1 text;
     text_var2 text;
     text_var3 text;
BEGIN
   RAISE NOTICE 'set road details for: %', tablename;

   -- Need to check whether or not the table has a geom column

   squery = format('ALTER TABLE %s DISABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   squery = format('SELECT GeometryType(%s) FROM %s
                    ', geom_field, tablename);
   EXECUTE squery INTO geom_type;

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

   squery = format('ALTER TABLE %s ENABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   --RAISE NOTICE '2: %', squery;
   RETURN True;
END;
$func$ LANGUAGE plpgsql;

-- deal with Carriageway Markings and RestrictionPolygons
WITH relevant_tables AS (
      select table_schema, table_name, concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'RoadName'
      AND table_schema IN ('toms', 'highway_assets', 'moving_traffic')
      AND table_name NOT IN ('Bays', 'Lines', 'Signs')
    ), geom_tables AS (
        SELECT full_table_name
        FROM information_schema.columns i, relevant_tables
        WHERE i.table_name = relevant_tables.table_name
        AND i.table_schema = relevant_tables.table_schema
        AND column_name = 'geom'
    )
        SELECT mhtc_operations.setRoadNameForTable(full_table_name, 'geom')
        FROM geom_tables;

-- now the other MT items
WITH relevant_tables AS (
      select table_schema, table_name, concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'RoadName'
      AND table_schema IN ('toms', 'highway_assets', 'moving_traffic')
      AND table_name NOT IN ('Bays', 'Lines', 'Signs')
    ), geom_tables AS (
        SELECT full_table_name
        FROM information_schema.columns i, relevant_tables
        WHERE i.table_name = relevant_tables.table_name
        AND i.table_schema = relevant_tables.table_schema
        AND column_name = 'geom_point'
    )
        SELECT mhtc_operations.setRoadNameForTable(full_table_name, 'mt_capture_geom')
        FROM geom_tables;