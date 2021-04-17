-- change over the trigger functions so that they don't include spaces ...

-- from 0007_moving_traffic_structure.sql (may need to break out)

CREATE OR REPLACE FUNCTION public.create_geometryid()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 nextSeqVal varchar := '';
BEGIN

	CASE TG_TABLE_NAME
	WHEN 'Bays' THEN
			SELECT concat('B_', to_char(nextval('toms."Bays_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'Lines' THEN
		   SELECT concat('L_', to_char(nextval('toms."Lines_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'Signs' THEN
		   SELECT concat('S_', to_char(nextval('toms."Signs_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'RestrictionPolygons' THEN
		   SELECT concat('P_', to_char(nextval('toms."RestrictionPolygons_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'ControlledParkingZones' THEN
		   SELECT concat('C_', to_char(nextval('toms."ControlledParkingZones_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'ParkingTariffAreas' THEN
		   SELECT concat('T_', to_char(nextval('toms."ParkingTariffAreas_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'AccessRestrictions' THEN
		   SELECT concat('A_', to_char(nextval('moving_traffic."AccessRestrictions_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'HighwayDedications' THEN
		   SELECT concat('H_', to_char(nextval('moving_traffic."HighwayDedications_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'RestrictionsForVehicles' THEN
		   SELECT concat('R_', to_char(nextval('moving_traffic."RestrictionsForVehicles_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'SpecialDesignations' THEN
		   SELECT concat('D_', to_char(nextval('moving_traffic."SpecialDesignations_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'TurnRestrictions' THEN
		   SELECT concat('V_', to_char(nextval('moving_traffic."TurnRestrictions_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'CarriagewayMarkings' THEN
		   SELECT concat('M_', to_char(nextval('moving_traffic."CarriagewayMarkings_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'MHTC_RoadLinks' THEN
		   SELECT concat('L_', to_char(nextval('highways_network."MHTC_RoadLinks_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	ELSE
	    nextSeqVal = 'U';
	END CASE;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$BODY$;

-- from 0011_highway_assets_structure.sql

ALTER FUNCTION public.create_geometryid()
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.create_geometryid_highway_assets()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 nextSeqVal varchar := '';
BEGIN

	CASE TG_TABLE_NAME
	WHEN 'Benches' THEN
			SELECT concat('BE_', to_char(nextval('highway_assets."Benches_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'Bins' THEN
			SELECT concat('BI_', to_char(nextval('highway_assets."Bins_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'Bollards' THEN
		   SELECT concat('BO_', to_char(nextval('highway_assets."Bollards_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'Bridges' THEN
		   SELECT concat('BR_', to_char(nextval('highway_assets."Bridges_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'BusShelters' THEN
		   SELECT concat('BS_', to_char(nextval('highway_assets."BusShelters_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
    WHEN 'BusStopSigns' THEN
			SELECT concat('BU_', to_char(nextval('highway_assets."BusStopSigns_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'CCTV_Cameras' THEN
		   SELECT concat('CT_', to_char(nextval('highway_assets."CCTV_Cameras_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'CommunicationCabinets' THEN
		   SELECT concat('CC_', to_char(nextval('highway_assets."CommunicationCabinets_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'CrossingPoints' THEN
		   SELECT concat('CR_', to_char(nextval('highway_assets."CrossingPoints_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'CycleParking' THEN
		   SELECT concat('CY_', to_char(nextval('highway_assets."CycleParking_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'DisplayBoards' THEN
		   SELECT concat('DB_', to_char(nextval('highway_assets."DisplayBoards_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'EV_ChargingPoints' THEN
		   SELECT concat('EV_', to_char(nextval('highway_assets."EV_ChargingPoints_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'EndOfStreetMarkings' THEN
		   SELECT concat('ES_', to_char(nextval('highway_assets."EndOfStreetMarkings_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'PedestrianRailings' THEN
		   SELECT concat('PR_', to_char(nextval('highway_assets."PedestrianRailings_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'Postboxes' THEN
		   SELECT concat('PO_', to_char(nextval('highway_assets."Postboxes_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'StreetNamePlates' THEN
		   SELECT concat('SN_', to_char(nextval('highway_assets."StreetNamePlates_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'TelephoneBoxes' THEN
		   SELECT concat('TE_', to_char(nextval('highway_assets."TelephoneBoxes_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'TelegraphPoles' THEN
		   SELECT concat('TP_', to_char(nextval('highway_assets."TelegraphPoles_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'SubterraneanFeatures' THEN
		   SELECT concat('SF_', to_char(nextval('highway_assets."SubterraneanFeatures_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'TrafficCalming' THEN
		   SELECT concat('TC_', to_char(nextval('highway_assets."TrafficCalming_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;
	WHEN 'TrafficSignals' THEN
		   SELECT concat('TS_', to_char(nextval('highway_assets."TrafficSignals_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'UnidentifiedStaticObjects' THEN
		   SELECT concat('US_', to_char(nextval('highway_assets."UnidentifiedStaticObjects_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	WHEN 'VehicleBarriers' THEN
		   SELECT concat('VB_', to_char(nextval('highway_assets."VehicleBarriers_id_seq"'::regclass), 'FM0000000'::"text")) INTO nextSeqVal;

	ELSE
	    nextSeqVal = 'U';
	END CASE;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$BODY$;

-- from 0013_ISL_tables_structure.sql

ALTER FUNCTION public.create_geometryid_highway_assets()
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.create_geometryid_isl_electrical_items()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 nextSeqVal varchar := '';
BEGIN

	CASE TG_TABLE_NAME
	WHEN 'ISL_Electrical_Items' THEN
			SELECT concat('EI_', to_char(nextval('local_authority."ISL_Electrical_Items_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	ELSE
	    nextSeqVal = 'U';
	END CASE;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION public.create_geometryid_isl_electrical_items()
    OWNER TO postgres;


-- function to remove spaces from "GeometryID"

CREATE OR REPLACE FUNCTION mhtc_operations.removeSpacesFromGeometryID(tablename regclass, geometry_id_field text)
  RETURNS BOOLEAN AS
$func$
DECLARE
	 squery text;
	 result BOOLEAN;
BEGIN
   RAISE NOTICE 'remove spaces in geometry_id: table: % field: % ', tablename, geometry_id_field;

   -- Need to check whether or not the table has a geom column

   squery = format('ALTER TABLE %s DISABLE TRIGGER ALL
                    ', tablename);
   EXECUTE squery;

   /*squery = format('SELECT "%1$s" = trim(regexp_replace("%1$s", ''s+'', '''', ''g''))
                    FROM %2$s
                    ', geometry_id_field, tablename);
   EXECUTE squery;*/

   squery = format('
       UPDATE %1$s
       SET "%2$s" = trim(regexp_replace("%2$s", ''\s+'', '''', ''g''))
       ', tablename, geometry_id_field);
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
        SELECT mhtc_operations.removeSpacesFromGeometryID(full_table_name, 'GeometryID')
        FROM relevant_tables;