**
Assign road names and USRN to all features
**/

-- create sections in usual way but use RAMI data to set road names and USRN

UPDATE mhtc_operations."RC_Sections_merged" s
SET "USRN" = r.identifier::int
FROM public."Street" r
WHERE UPPER(s."RoadName") = r.designatedname1;

-- Now set names

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
--AND c."RoadName" IS NULL;
;
ALTER TABLE toms."Signs" ENABLE TRIGGER all;

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
        AND column_name = 'mt_capture_geom'
    )
        SELECT mhtc_operations.setRoadNameForTable(full_table_name, 'mt_capture_geom')
        FROM geom_tables;

-- MHTC_RoadLinks
WITH relevant_tables AS (
      select table_schema, table_name, concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'RoadName'
      AND table_schema IN ('highways_network')
      AND table_name IN ('MHTC_RoadLinks')
    ), geom_tables AS (
        SELECT full_table_name
        FROM information_schema.columns i, relevant_tables
        WHERE i.table_name = relevant_tables.table_name
        AND i.table_schema = relevant_tables.table_schema
        AND column_name = 'geom'
    )
        SELECT mhtc_operations.setRoadNameForTable(full_table_name, 'geom')
        FROM geom_tables;

-- VehicleBarriers
WITH relevant_tables AS (
      select table_schema, table_name, concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'RoadName'
      AND table_schema IN ('highway_assets')
      AND table_name IN ('VehicleBarriers')
    ), geom_tables AS (
        SELECT full_table_name
        FROM information_schema.columns i, relevant_tables
        WHERE i.table_name = relevant_tables.table_name
        AND i.table_schema = relevant_tables.table_schema
        AND column_name = 'geom'
    )
        SELECT mhtc_operations.setRoadNameForTable(full_table_name, 'geom')
        FROM geom_tables;
