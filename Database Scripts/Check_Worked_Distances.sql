---  Kerb distances for current day

SELECT "CreatePerson", SUM(dist)
FROM (
SELECT "CreatePerson", SUM("RestrictionLength") AS dist
FROM toms."Bays"
WHERE date_trunc('day', "CreateDateTime") = date_trunc('day', now() - interval '1 day')
GROUP BY "CreatePerson"
UNION
SELECT "CreatePerson", SUM("RestrictionLength")
FROM toms."Lines"
WHERE date_trunc('day', "CreateDateTime") =  date_trunc('day', now() - interval '1 day')
GROUP   BY "CreatePerson"
ORDER BY "CreatePerson"
	) AS s
GROUP BY "CreatePerson"
ORDER BY "CreatePerson"


SELECT "CreatePerson", MIN("CreateDateTime"), MAX("CreateDateTime"), MAX("CreateDateTime") - MIN("CreateDateTime") AS Hours
FROM toms."Signs"
WHERE date_trunc('day', "CreateDateTime") = date_trunc('day', now() - interval '1 day')
GROUP BY "CreatePerson"
ORDER BY "CreatePerson"

SELECT "LastUpdatePerson", MIN("LastUpdateDateTime"), MAX("LastUpdateDateTime"), MAX("LastUpdateDateTime") - MIN("LastUpdateDateTime") AS Hours
FROM toms."Signs"
WHERE date_trunc('day', "LastUpdateDateTime") = date_trunc('day', now() - interval '1 day')
GROUP BY "LastUpdatePerson"
ORDER BY "LastUpdatePerson"

SELECT "Last_MHTC_Check_UpdatePerson", MIN("Last_MHTC_Check_UpdateDateTime"), MAX("Last_MHTC_Check_UpdateDateTime"), MAX("Last_MHTC_Check_UpdateDateTime") - MIN("Last_MHTC_Check_UpdateDateTime") AS Hours
FROM toms."Signs"
WHERE date_trunc('day', "Last_MHTC_Check_UpdateDateTime") = date_trunc('day', now()  - interval '1 day')
GROUP BY "Last_MHTC_Check_UpdatePerson"
ORDER BY "Last_MHTC_Check_UpdatePerson"

CREATE OR REPLACE FUNCTION mhtc_operations.countPhotosInTableForDay(tablename regclass)
  RETURNS TABLE (person character varying(255), count_items bigint) AS
$func$
DECLARE
	 squery text;
BEGIN
   RAISE NOTICE 'checking: %', tablename;
   squery = format('SELECT "CreatePerson", COUNT("Photos_01") As Total
                    FROM   %s
                    WHERE "Photos_01" IS NOT NULL
					AND date_trunc(''day'', "CreateDateTime") = date_trunc(''day'', now() - interval ''1 day'')
					GROUP BY "CreatePerson"
                    UNION
                    SELECT "CreatePerson", COUNT("Photos_02") As Total
                    FROM   %s
                    WHERE "Photos_02" IS NOT NULL
					AND date_trunc(''day'', "CreateDateTime") = date_trunc(''day'', now() - interval ''1 day'')
					GROUP BY "CreatePerson"
                    UNION
                    SELECT "CreatePerson", COUNT("Photos_03") As Total
                    FROM   %s
                    WHERE "Photos_03" IS NOT NULL
					AND date_trunc(''day'', "CreateDateTime") = date_trunc(''day'', now() - interval ''1 day'')
					GROUP BY "CreatePerson"
					ORDER BY "CreatePerson"
                    ', tablename, tablename, tablename);
   RAISE NOTICE '2: %', squery;
   RETURN QUERY EXECUTE squery;
END;
$func$ LANGUAGE plpgsql;



WITH relevant_tables AS (
      select concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'Photos_01'
      AND table_schema NOT IN ('quarantine', 'local_authority')
    )

    SELECT mhtc_operations.countPhotosInTableForDay(full_table_name)
    FROM relevant_tables;