/*
-- need to add Map Frame structures
*/

-- Havering MapFrame
DROP SEQUENCE IF EXISTS havering_operations."HaveringMapFramesAllowableScales_Code_seq" CASCADE;

CREATE SEQUENCE havering_operations."HaveringMapFramesAllowableScales_Code_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."HaveringMapFramesAllowableScales_Code_seq"
    OWNER TO postgres;

DROP TABLE IF EXISTS havering_operations."HaveringMapFramesAllowableScales" CASCADE;

CREATE TABLE havering_operations."HaveringMapFramesAllowableScales"
(
    "Code" integer NOT NULL DEFAULT nextval('havering_operations."HaveringMapFramesAllowableScales_Code_seq"'::regclass),
    "Description" character varying COLLATE pg_catalog."default",
    CONSTRAINT "HaveringMapFramesAllowableScales_pkey" PRIMARY KEY ("Code")
);

ALTER TABLE havering_operations."HaveringMapFramesAllowableScales"
    OWNER TO postgres;

DROP SEQUENCE IF EXISTS havering_operations."HaveringMapFrames_id_seq" CASCADE;

CREATE SEQUENCE havering_operations."HaveringMapFrames_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."HaveringMapFrames_id_seq"
    OWNER TO postgres;

DROP TABLE IF EXISTS havering_operations."HaveringMapFrames" CASCADE;

CREATE TABLE havering_operations."HaveringMapFrames"
(
    "GeometryID" character varying(12) DEFAULT ('MF_'::"text" || "to_char"("nextval"('havering_operations."HaveringMapFrames_id_seq"'::"regclass"), 'FM00000'::"text")),
    map_frame_centre_point_geom geometry(Point,27700),
    map_frame_geom geometry(Polygon,27700),
    "HaveringMapFramesOrientation" integer,
    "HaveringMapFramesScaleID" integer,
    "HaveringMapFramesCategoryTypeID" integer,
    "RoadsAtJunction" character varying(254),
    --"NotesOnExistingRestrictions" character varying(254),
    CONSTRAINT "HaveringMapFrames_pkey" PRIMARY KEY ("RestrictionID"),
    CONSTRAINT "HaveringMapFrames_GeometryID_key" UNIQUE ("GeometryID"),
    CONSTRAINT "HaveringMapFrames_HaveringMapFramesAllowableScales_fkey" FOREIGN KEY ("HaveringMapFramesScaleID")
        REFERENCES havering_operations."HaveringMapFramesAllowableScales" ("Code"),
    CONSTRAINT "HaveringMapFrames_HaveringMapFramesCategoryTypeID_fkey" FOREIGN KEY ("HaveringMapFramesCategoryTypeID")
        REFERENCES havering_operations."JunctionProtectionCategoryTypes" ("Code")
)
INHERITS ("highway_assets"."HighwayAssets");

CREATE INDEX "sidx_HaveringMapFrames_geom" ON havering_operations."HaveringMapFrames" USING "gist" ("map_frame_geom");


-- CornersWithinJunctions

DROP TABLE IF EXISTS havering_operations."JunctionsWithinMapFrames";

CREATE TABLE havering_operations."JunctionsWithinMapFrames"
(
    "MapFrameID" character varying(12) NOT NULL,
    "JunctionID" character varying(12) NOT NULL,
    CONSTRAINT "JunctionsWithinMapFrames_pk" PRIMARY KEY ("MapFrameID", "JunctionID"),
    CONSTRAINT "JunctionsWithinMapFrames_JunctionID_fkey" FOREIGN KEY ("JunctionID")
        REFERENCES havering_operations."HaveringJunctions" ("GeometryID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT "JunctionsWithinMapFrames_MapFrameID_fkey" FOREIGN KEY ("MapFrameID")
        REFERENCES havering_operations."HaveringMapFrames" ("GeometryID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);


CREATE OR REPLACE FUNCTION havering_operations.create_geometryid_havering()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 nextSeqVal varchar := '';
BEGIN

	CASE TG_TABLE_NAME
	WHEN 'HaveringCorners' THEN
			SELECT concat('CO_', to_char(nextval('havering_operations."HaveringCorners_id_seq"'::regclass), 'FM00000'::text)) INTO nextSeqVal;
	WHEN 'HaveringJunctions' THEN
			SELECT concat('JU_', to_char(nextval('havering_operations."HaveringJunctions_id_seq"'::regclass), 'FM00000'::text)) INTO nextSeqVal;
	WHEN 'HaveringMapFrames' THEN
			SELECT concat('MF_', to_char(nextval('havering_operations."HaveringMapFrames_id_seq"'::regclass), 'FM00000'::text)) INTO nextSeqVal;
	ELSE
	    nextSeqVal = 'U';
	END CASE;

    NEW."GeometryID" := nextSeqVal;
	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION havering_operations.create_geometryid_havering()
    OWNER TO postgres;



