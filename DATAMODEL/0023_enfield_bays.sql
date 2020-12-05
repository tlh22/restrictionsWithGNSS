--

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
			SELECT concat('BE_', to_char(nextval('highway_assets."Benches_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'Bins' THEN
			SELECT concat('BI_', to_char(nextval('highway_assets."Bins_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'Bollards' THEN
		   SELECT concat('BO_', to_char(nextval('highway_assets."Bollards_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'Bridges' THEN
		   SELECT concat('BR_', to_char(nextval('highway_assets."Bridges_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'BusShelters' THEN
		   SELECT concat('BS_', to_char(nextval('highway_assets."BusShelters_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
    WHEN 'BusStopSigns' THEN
			SELECT concat('BU_', to_char(nextval('highway_assets."BusStopSigns_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'CCTV_Cameras' THEN
		   SELECT concat('CT_', to_char(nextval('highway_assets."CCTV_Cameras_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'CommunicationCabinets' THEN
		   SELECT concat('CC_', to_char(nextval('highway_assets."CommunicationCabinets_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'CrossingPoints' THEN
		   SELECT concat('CR_', to_char(nextval('highway_assets."CrossingPoints_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'CycleParking' THEN
		   SELECT concat('CY_', to_char(nextval('highway_assets."CycleParking_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'DisplayBoards' THEN
		   SELECT concat('DB_', to_char(nextval('highway_assets."DisplayBoards_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'EV_ChargingPoints' THEN
		   SELECT concat('EV_', to_char(nextval('highway_assets."EV_ChargingPoints_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'EndOfStreetMarkings' THEN
		   SELECT concat('ES_', to_char(nextval('highway_assets."EndOfStreetMarkings_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'PedestrianRailings' THEN
		   SELECT concat('PR_', to_char(nextval('highway_assets."PedestrianRailings_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'Postboxes' THEN
		   SELECT concat('PO_', to_char(nextval('highway_assets."Postboxes_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'StreetNamePlates' THEN
		   SELECT concat('SN_', to_char(nextval('highway_assets."StreetNamePlates_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'TelephoneBoxes' THEN
		   SELECT concat('TE_', to_char(nextval('highway_assets."TelephoneBoxes_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'TelegraphPoles' THEN
		   SELECT concat('TP_', to_char(nextval('highway_assets."TelegraphPoles_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'SubterraneanFeatures' THEN
		   SELECT concat('SF_', to_char(nextval('highway_assets."SubterraneanFeatures_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'TrafficCalming' THEN
		   SELECT concat('TC_', to_char(nextval('highway_assets."TrafficCalming_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	WHEN 'TrafficSignals' THEN
		   SELECT concat('TS_', to_char(nextval('highway_assets."TrafficSignals_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'UnidentifiedStaticObjects' THEN
		   SELECT concat('US_', to_char(nextval('highway_assets."UnidentifiedStaticObjects_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'VehicleBarriers' THEN
		   SELECT concat('VB_', to_char(nextval('highway_assets."VehicleBarriers_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;

	WHEN 'enfield_bays' THEN
		   SELECT concat('EB_', to_char(nextval('local_authority."enfield_bays_id_seq"'::regclass), '00000000'::text)) INTO nextSeqVal;
	ELSE
	    nextSeqVal = 'U';
	END CASE;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION public.create_geometryid_highway_assets()
    OWNER TO postgres;

CREATE SEQUENCE "local_authority"."enfield_bays_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "local_authority"."enfield_bays_id_seq" OWNER TO "postgres";


CREATE TABLE "local_authority"."enfield_bays" (
    "GeometryID" character varying(12) DEFAULT ('BE_'::"text" || "to_char"("nextval"('"local_authority"."enfield_bays_id_seq"'::"regclass"), '00000000'::"text")),
    "geom" "public"."geometry"(Polygon,27700),
     name character varying(254) COLLATE pg_catalog."default",
    sections character varying(100) COLLATE pg_catalog."default",
    bay_type character varying(100) COLLATE pg_catalog."default",
    "Location" character varying COLLATE pg_catalog."default",
    "Area" character varying COLLATE pg_catalog."default",
    baylist_type character varying COLLATE pg_catalog."default",
    "TimePeriod_Description" character varying COLLATE pg_catalog."default",
    "MaxStay_Description" character varying COLLATE pg_catalog."default",
    "RestrictionLength" character varying COLLATE pg_catalog."default",
    "NrBays" character varying COLLATE pg_catalog."default",
    "TheoreticalSpaces" character varying COLLATE pg_catalog."default",
    "Capacity" character varying COLLATE pg_catalog."default",
    baylist_notes_1 character varying COLLATE pg_catalog."default",
    baylist_notes_2 character varying COLLATE pg_catalog."default",
    "RestrictionTypeID" integer,
    "TimePeriodID" integer,
    "MaxStayID" integer
    "GeomShapeID" integer,
)
INHERITS ("highway_assets"."HighwayAssets");

ALTER TABLE ONLY "local_authority"."enfield_bays"
    ADD CONSTRAINT "enfield_bays_pkey" PRIMARY KEY ("RestrictionID");

CREATE INDEX "sidx_enfield_bays_geom" ON "local_authority"."enfield_bays" USING "gist" ("geom");

CREATE TRIGGER "create_geometryid_enfield_bays" BEFORE INSERT ON "local_authority"."enfield_bays" FOR EACH ROW EXECUTE FUNCTION "public"."create_geometryid_highway_assets"();

CREATE TRIGGER "set_last_update_details_enfield_bays" BEFORE INSERT OR UPDATE ON "local_authority"."enfield_bays" FOR EACH ROW EXECUTE FUNCTION "public"."set_last_update_details"();

CREATE TRIGGER "set_create_details_enfield_bays" BEFORE INSERT ON "local_authority"."enfield_bays" FOR EACH ROW EXECUTE FUNCTION "public"."set_create_details"();

-- permissions
REVOKE ALL ON ALL TABLES IN SCHEMA local_authority FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA local_authority TO toms_public, toms_operator, toms_admin;

GRANT SELECT ON TABLE "local_authority"."enfield_bays" TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "local_authority"."enfield_bays" TO toms_operator, toms_admin;
GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA highways_network FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA highways_network TO toms_public, toms_operator, toms_admin;

GRANT SELECT ON TABLE mhtc_operations."Enfield_Sections" TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."Enfield_Sections" TO toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;