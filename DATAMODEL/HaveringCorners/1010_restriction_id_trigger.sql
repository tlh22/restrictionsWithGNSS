-- add restriction_id to create ...

CREATE OR REPLACE FUNCTION public.create_geometryid()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 nextSeqVal varchar := '';
	 restriction_id uuid;
BEGIN

	CASE TG_TABLE_NAME
	WHEN 'Bays' THEN
			SELECT concat('B_', to_char(nextval('toms."Bays_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'Lines' THEN
		   SELECT concat('L_', to_char(nextval('toms."Lines_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'Signs' THEN
		   SELECT concat('S_', to_char(nextval('toms."Signs_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'RestrictionPolygons' THEN
		   SELECT concat('P_', to_char(nextval('toms."RestrictionPolygons_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'ControlledParkingZones' THEN
		   SELECT concat('C_', to_char(nextval('toms."ControlledParkingZones_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'ParkingTariffAreas' THEN
		   SELECT concat('T_', to_char(nextval('toms."ParkingTariffAreas_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'AccessRestrictions' THEN
		   SELECT concat('A_', to_char(nextval('moving_traffic."AccessRestrictions_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'HighwayDedications' THEN
		   SELECT concat('H_', to_char(nextval('moving_traffic."HighwayDedications_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'RestrictionsForVehicles' THEN
		   SELECT concat('R_', to_char(nextval('moving_traffic."RestrictionsForVehicles_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'SpecialDesignations' THEN
		   SELECT concat('D_', to_char(nextval('moving_traffic."SpecialDesignations_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'TurnRestrictions' THEN
		   SELECT concat('V_', to_char(nextval('moving_traffic."TurnRestrictions_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'CarriagewayMarkings' THEN
		   SELECT concat('M_', to_char(nextval('moving_traffic."CarriagewayMarkings_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'MHTC_RoadLinks' THEN
		   SELECT concat('L_', to_char(nextval('highways_network."MHTC_RoadLinks_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;
	WHEN 'MHTC_Kerblines' THEN
		   SELECT concat('K_', to_char(nextval('mhtc_operations."MHTC_Kerbline_id_seq"'::regclass), '000000000'::text)) INTO nextSeqVal;

	ELSE
	    nextSeqVal = 'U';
	END CASE;

    SELECT uuid_generate_v4() INTO restriction_id;

    NEW."GeometryID" := nextSeqVal;
    NEW."RestrictionID" := restriction_id;
	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION public.create_geometryid()
    OWNER TO postgres;
