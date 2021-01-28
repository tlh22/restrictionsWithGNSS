-- set up initial structure
CREATE SCHEMA "havering_operations";
ALTER SCHEMA "havering_operations" OWNER TO "postgres";

CREATE SEQUENCE havering_operations."CornerProtectionCategoryType_Code_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."CornerProtectionCategoryType_Code_seq"
    OWNER TO postgres;

CREATE TABLE havering_operations."CornerProtectionCategoryTypes"
(
    "Code" integer NOT NULL DEFAULT nextval('havering_operations."CornerProtectionCategoryType_Code_seq"'::regclass),
    "Description" character varying COLLATE pg_catalog."default",
    CONSTRAINT "CornerProtectionCategoryTypes_pkey" PRIMARY KEY ("Code")
);

CREATE SEQUENCE havering_operations."JunctionProtectionCategoryType_Code_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."JunctionProtectionCategoryType_Code_seq"
    OWNER TO postgres;

CREATE TABLE havering_operations."JunctionProtectionCategoryTypes"
(
    "Code" integer NOT NULL DEFAULT nextval('havering_operations."JunctionProtectionCategoryType_Code_seq"'::regclass),
    "Description" character varying COLLATE pg_catalog."default",
    CONSTRAINT "JunctionProtectionCategoryType_pkey" PRIMARY KEY ("Code")
);

-- HaveringCorners
-- use highway_assets."HighwayAssets" as base table

DROP SEQUENCE IF EXISTS havering_operations."HaveringCorners_id_seq" CASCADE;

CREATE SEQUENCE havering_operations."HaveringCorners_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."HaveringCorners_id_seq"
    OWNER TO postgres;

DROP TABLE IF EXISTS havering_operations."HaveringCorners" CASCADE;

CREATE TABLE havering_operations."HaveringCorners"
(
    "GeometryID" character varying(12) DEFAULT ('CO_'::"text" || "to_char"("nextval"('havering_operations."HaveringCorners_id_seq"'::"regclass"), 'FM00000'::"text")),
    corner_point_geom geometry(Point,27700) NOT NULL,
    apex_point_geom geometry(Point,27700),
    line_from_corner_point_geom geometry(LineString,27700),
    line_from_apex_point_geom geometry(LineString,27700),
    new_corner_protection_geom geometry(MultiLineString,27700),
    corner_dimension_lines_geom geometry(MultiLineString,27700),
    length_conforming_within_line_from_corner_point double precision,
    "CornerProtectionCategoryTypeID" integer,
    "ComplianceRoadMarkingsFadedTypeID" integer,
    CONSTRAINT "HaveringCorners_pkey" PRIMARY KEY ("RestrictionID"),
    CONSTRAINT "HaveringCorners_GeometryID_key" UNIQUE ("GeometryID"),
    CONSTRAINT "HaveringCorners_CornerProtectionCategoryTypeID_fkey" FOREIGN KEY ("CornerProtectionCategoryTypeID")
        REFERENCES havering_operations."CornerProtectionCategoryTypes" ("Code"),
    CONSTRAINT "HaveringCorners_ComplianceRoadMarkingsFadedTypeID_fkey" FOREIGN KEY ("ComplianceRoadMarkingsFadedTypeID")
        REFERENCES havering_operations."CornerProtectionCategoryTypes" ("Code")
)
INHERITS ("highway_assets"."HighwayAssets");

CREATE INDEX "sidx_HaveringCorners_apex_point_geom" ON havering_operations."HaveringCorners" USING "gist" ("apex_point_geom");

--

DROP TABLE IF EXISTS havering_operations."HaveringCorners_Output" CASCADE;

CREATE TABLE havering_operations."HaveringCorners_Output"
(
    gid SERIAL,
    "GeometryID" character varying(12) NOT NULL,
    new_corner_protection_geom geometry(LineString,27700) NOT NULL,
    "RestrictionTypeID" integer DEFAULT 202,
    "AzimuthToRoadCentreLine" double precision DEFAULT 0.0,
    "GeomShapeID" integer DEFAULT 10,
    CONSTRAINT "HaveringCorners_Output_pkey" PRIMARY KEY ("gid"),
    CONSTRAINT "HaveringCorners_Output_GeometryID_fkey" FOREIGN KEY ("GeometryID")
        REFERENCES havering_operations."HaveringCorners" ("GeometryID")
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE INDEX "sidx_HaveringCorners_Output_new_corner_protection_geom" ON havering_operations."HaveringCorners_Output" USING "gist" ("new_corner_protection_geom");

-- HaveringJunctions

DROP SEQUENCE IF EXISTS havering_operations."HaveringJunctions_id_seq" CASCADE;

CREATE SEQUENCE havering_operations."HaveringJunctions_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."HaveringJunctions_id_seq"
    OWNER TO postgres;

DROP TABLE IF EXISTS havering_operations."HaveringJunctions" CASCADE;

CREATE TABLE havering_operations."HaveringJunctions"
(
    "GeometryID" character varying(12) DEFAULT ('JU_'::"text" || "to_char"("nextval"('havering_operations."HaveringJunctions_id_seq"'::"regclass"), 'FM00000'::"text")),
    junction_point_geom geometry(Point,27700),
    map_frame_geom geometry(Polygon,27700),
    map_frame_orientation integer,
    map_scale integer,
    "JunctionProtectionCategoryTypeID" integer,
    "RoadsAtJunction" character varying(254),
    "NotesOnExistingRestrictions" character varying(254),
    CONSTRAINT "HaveringJunctions_pkey" PRIMARY KEY ("RestrictionID"),
    CONSTRAINT "HaveringJunctions_GeometryID_key" UNIQUE ("GeometryID"),
    CONSTRAINT "HaveringJunctions_JunctionProtectionCategoryTypeID_fkey" FOREIGN KEY ("JunctionProtectionCategoryTypeID")
        REFERENCES havering_operations."JunctionProtectionCategoryTypes" ("Code")
)
INHERITS ("highway_assets"."HighwayAssets");

CREATE INDEX "sidx_HaveringJunctions_junction_point_geom" ON havering_operations."HaveringJunctions" USING "gist" ("junction_point_geom");

-- CornersWithinJunctions

DROP TABLE IF EXISTS havering_operations."CornersWithinJunctions";

CREATE TABLE havering_operations."CornersWithinJunctions"
(
    "JunctionID" character varying(12) NOT NULL,
    "CornerID" character varying(12) NOT NULL,
    CONSTRAINT "CornersWithinJunctions_pk" PRIMARY KEY ("JunctionID", "CornerID"),
    CONSTRAINT "CornersWithinJunctions_CornerID_key" UNIQUE ("CornerID"),
    CONSTRAINT "CornersWithinJunctions_JunctionID_fkey" FOREIGN KEY ("JunctionID")
        REFERENCES havering_operations."HaveringJunctions" ("GeometryID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT "CornersWithinJunctions_CornerID_fkey" FOREIGN KEY ("CornerID")
        REFERENCES havering_operations."HaveringCorners" ("GeometryID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

DROP TABLE IF EXISTS havering_operations."HaveringCornerSegments";

CREATE TABLE havering_operations."HaveringCornerSegments"
(
	"GeometryID" character varying(12),
	"SegmentLength" double precision,
    geom geometry(LineString, 27700)
);

--

DROP TABLE IF EXISTS havering_operations."HaveringCornerSegmentEndPts";

CREATE TABLE havering_operations."HaveringCornerSegmentEndPts"
(
	"GeometryID" character varying(12),
	"StartPt" geometry(Point, 27700),
	"EndPt" geometry(Point, 27700)
);



DROP TABLE IF EXISTS havering_operations."HaveringCornerConformingSegments";

CREATE TABLE havering_operations."HaveringCornerConformingSegments"
(
	"GeometryID" character varying(12),
    geom geometry(MultiLineString, 27700),
	new_corner_protection_geom geometry(MultiLineString, 27700)
);

-- deal with not null on condition type

ALTER TABLE havering_operations."HaveringCorners"
    ALTER COLUMN "AssetConditionTypeID" DROP NOT NULL;

ALTER TABLE havering_operations."HaveringJunctions"
    ALTER COLUMN "AssetConditionTypeID" DROP NOT NULL;