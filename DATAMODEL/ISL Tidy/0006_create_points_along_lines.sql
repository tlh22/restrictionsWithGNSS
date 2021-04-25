-- add points along lines

-- Bollards

DO
$do$
DECLARE
   row RECORD;
   columns text;
   feature_count integer;
   new_pt_geom geometry;
   fraction float;
BEGIN

    -- get the field list for the table -- https://stackoverflow.com/questions/25507477/postgresql-update-inside-for-loop

     /*
     SELECT  string_agg(CONCAT('"', c1.attname, '"'), ',')
     INTO    columns
     FROM    pg_attribute c1
     WHERE   attnum > 0
	 AND c1.attrelid = 'highway_assets."Bollards"'::regclass;
	 */

    FOR row IN SELECT *
               FROM highway_assets."Bollards"
               WHERE geom_linestring IS NOT NULL
               AND "NrFeatures" > 0  -- only look at the items with lines
    LOOP

        feature_count = row."NrFeatures" - 1;
        row."Notes" = CONCAT (row."Notes", ' TH: derived from line');
        RAISE NOTICE '***** geometryid: %s count: (%)', row."GeometryID", feature_count;

        FOR i IN 0 .. feature_count
        LOOP

			fraction = i::float/feature_count::float;
            new_pt_geom = public.ST_LineInterpolatePoint(row.geom_linestring, fraction);
            RAISE NOTICE '***** i: %s new_geom: (%)', i, public.ST_AsText(new_pt_geom);
            row.geom_point = new_pt_geom;

            INSERT INTO highway_assets."Bollards"(
	            "RestrictionID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate", "AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", geom_linestring, geom_point, "BollardTypeID", "NrFeatures")
            VALUES(
                 uuid_generate_v4(), row."Photos_01", row."Photos_02", row."Photos_03", row."Notes", row."RoadName", row."USRN", row."OpenDate", row."CloseDate", row."AssetConditionTypeID", row."LastUpdateDateTime", row."LastUpdatePerson", row."MHTC_CheckIssueTypeID", row."MHTC_CheckNotes", row."FieldCheckCompleted", row."Last_MHTC_Check_UpdateDateTime", row."Last_MHTC_Check_UpdatePerson", row."CreateDateTime", row."CreatePerson", row.geom_linestring, row.geom_point, row."BollardTypeID", row."NrFeatures"
            );

        END LOOP;

    END LOOP;

END
$do$;

-- Cycle parking

DO
$do$
DECLARE
   row RECORD;
   columns text;
   feature_count integer;
   new_pt_geom geometry;
   fraction float;
BEGIN

    -- get the field list for the table -- https://stackoverflow.com/questions/25507477/postgresql-update-inside-for-loop

     /*
     SELECT  string_agg(CONCAT('"', c1.attname, '"'), ',')
     INTO    columns
     FROM    pg_attribute c1
     WHERE   attnum > 0
	 AND c1.attrelid = 'highway_assets."Bollards"'::regclass;
	 */

    FOR row IN SELECT *
               FROM highway_assets."CycleParking"
               WHERE geom_linestring IS NOT NULL
               AND "NrStands" > 0  -- only look at the items with lines
    LOOP

        feature_count = row."NrStands" - 1;
        row."Notes" = CONCAT (row."Notes", ' TH: derived from line');
        RAISE NOTICE '***** geometryid: %s count: (%)', row."GeometryID", feature_count;

        FOR i IN 0 .. feature_count
        LOOP

			fraction = i::float/feature_count::float;
            new_pt_geom = public.ST_LineInterpolatePoint(row.geom_linestring, fraction);
            RAISE NOTICE '***** i: %s new_geom: (%)', i, public.ST_AsText(new_pt_geom);
            row.geom_point = new_pt_geom;

            INSERT INTO highway_assets."CycleParking"(
            	"RestrictionID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate", "AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", geom_point, "CycleParkingTypeID", "NrStands", geom_linestring, "AttachmentTypeID")
            VALUES(
                 uuid_generate_v4(), row."Photos_01", row."Photos_02", row."Photos_03", row."Notes", row."RoadName", row."USRN", row."OpenDate", row."CloseDate", row."AssetConditionTypeID", row."LastUpdateDateTime", row."LastUpdatePerson", row."MHTC_CheckIssueTypeID", row."MHTC_CheckNotes", row."FieldCheckCompleted", row."Last_MHTC_Check_UpdateDateTime", row."Last_MHTC_Check_UpdatePerson", row."CreateDateTime", row."CreatePerson", row.geom_point, row."CycleParkingTypeID", row."NrStands", row.geom_linestring, row."AttachmentTypeID"
            );

        END LOOP;

    END LOOP;

END
$do$;

-- Subterranean features

DO
$do$
DECLARE
   row RECORD;
   columns text;
   feature_count integer;
   new_pt_geom geometry;
   fraction float;
BEGIN

    -- get the field list for the table -- https://stackoverflow.com/questions/25507477/postgresql-update-inside-for-loop

     /*
     SELECT  string_agg(CONCAT('"', c1.attname, '"'), ',')
     INTO    columns
     FROM    pg_attribute c1
     WHERE   attnum > 0
	 AND c1.attrelid = 'highway_assets."Bollards"'::regclass;
	 */

    FOR row IN SELECT *
               FROM highway_assets."SubterraneanFeatures"
               WHERE geom_linestring IS NOT NULL
               AND "NrFeatures" > 0  -- only look at the items with lines
    LOOP

        feature_count = row."NrFeatures" - 1;
        row."Notes" = CONCAT (row."Notes", ' TH: derived from line');
        RAISE NOTICE '***** geometryid: %s count: (%)', row."GeometryID", feature_count;

        FOR i IN 0 .. feature_count
        LOOP

			fraction = i::float/feature_count::float;
            new_pt_geom = public.ST_LineInterpolatePoint(row.geom_linestring, fraction);
            RAISE NOTICE '***** i: %s new_geom: (%)', i, public.ST_AsText(new_pt_geom);
            row.geom_point = new_pt_geom;

            INSERT INTO highway_assets."SubterraneanFeatures"(
	            "RestrictionID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate", "AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", geom_linestring, geom_point, "SubterraneanFeatureTypeID", "NrFeatures")
            VALUES(
                 uuid_generate_v4(), row."Photos_01", row."Photos_02", row."Photos_03", row."Notes", row."RoadName", row."USRN", row."OpenDate", row."CloseDate", row."AssetConditionTypeID", row."LastUpdateDateTime", row."LastUpdatePerson", row."MHTC_CheckIssueTypeID", row."MHTC_CheckNotes", row."FieldCheckCompleted", row."Last_MHTC_Check_UpdateDateTime", row."Last_MHTC_Check_UpdatePerson", row."CreateDateTime", row."CreatePerson", row.geom_linestring, row.geom_point, row."SubterraneanFeatureTypeID", row."NrFeatures"
            );

        END LOOP;

    END LOOP;

END
$do$;
