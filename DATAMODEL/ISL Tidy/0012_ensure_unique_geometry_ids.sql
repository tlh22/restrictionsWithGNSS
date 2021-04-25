/***
    For some reason tables have 'U' GeometryID values - despite constraint being in place from MASTER tables.
    This is to tidy them up. Unqiue constraint is added later
***/

-- function to remove spaces from "GeometryID"

CREATE OR REPLACE FUNCTION mhtc_operations.generateUniqueGeometryID(tablename regclass, geometry_id_field text)
  RETURNS BOOLEAN AS
$func$
DECLARE
	 squery text;
	 result BOOLEAN;
BEGIN
   RAISE NOTICE 'generating geometry_id: table: % field: % ', tablename, geometry_id_field;

   -- Need to check whether or not the table has a geom column

   squery = format('ALTER TABLE %s DISABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   squery = format('
       UPDATE %1$s
       SET "GeometryID" = DEFAULT
       WHERE "GeometryID" = ''U''
       ', tablename);
       EXECUTE squery;

   squery = format('ALTER TABLE %s ENABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   --RAISE NOTICE '2: %', squery;
   RETURN True;
END;
$func$ LANGUAGE plpgsql;


-- remove spaces

WITH relevant_tables AS (
      select table_schema, table_name, concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'GeometryID'
      AND table_schema NOT IN ('quarantine')
    )
        SELECT mhtc_operations.generateUniqueGeometryID(full_table_name, 'GeometryID')
        FROM relevant_tables;



-- Deal with unique issues

ALTER TABLE "moving_traffic"."AccessRestrictions" DISABLE TRIGGER all;

UPDATE "moving_traffic"."AccessRestrictions" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'U';

ALTER TABLE "moving_traffic"."AccessRestrictions" ENABLE TRIGGER all;


ALTER TABLE "moving_traffic"."HighwayDedications" DISABLE TRIGGER all;

UPDATE "moving_traffic"."HighwayDedications" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'U';

ALTER TABLE "moving_traffic"."HighwayDedications" ENABLE TRIGGER all;


ALTER TABLE "moving_traffic"."RestrictionsForVehicles" DISABLE TRIGGER all;

UPDATE "moving_traffic"."RestrictionsForVehicles" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'U';

ALTER TABLE "moving_traffic"."RestrictionsForVehicles" ENABLE TRIGGER all;


ALTER TABLE "moving_traffic"."SpecialDesignations" ENABLE TRIGGER all;

UPDATE "moving_traffic"."SpecialDesignations" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'U';

ALTER TABLE "moving_traffic"."SpecialDesignations" ENABLE TRIGGER all;


ALTER TABLE "moving_traffic"."TurnRestrictions" DISABLE TRIGGER all;

UPDATE "moving_traffic"."TurnRestrictions" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'U';

ALTER TABLE "moving_traffic"."TurnRestrictions" ENABLE TRIGGER all;


ALTER TABLE "highways_network"."MHTC_RoadLinks" DISABLE TRIGGER all;

UPDATE "highways_network"."MHTC_RoadLinks" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'U';

ALTER TABLE "highways_network"."MHTC_RoadLinks" ENABLE TRIGGER all;



