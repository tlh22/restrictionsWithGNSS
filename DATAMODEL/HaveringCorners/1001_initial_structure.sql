-- set up initial structure
CREATE SCHEMA "havering_operations";
ALTER SCHEMA "havering_operations" OWNER TO "postgres";

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
    "CornerID" integer NOT NULL DEFAULT nextval('havering_operations."HaveringCorners_id_seq"'::regclass),
    corner_point_geom geometry(Point,27700),
    apex_point_geom geometry(Point,27700),
    line_from_corner_point_geom geometry(LineString,27700),
    line_from_apex_point_geom geometry(LineString,27700),
    new_junction_protection_geom geometry(MultiLineString,27700),
    length_conforming_within_line_from_corner_point double precision,
    "CornerProtectionCategoryTypeID" integer,
    CONSTRAINT "HaveringCorners_pkey" PRIMARY KEY ("CornerID"),
    CONSTRAINT "HaveringCorners_CornerProtectionCategoryTypeID_fkey" FOREIGN KEY ("CornerProtectionCategoryTypeID")
        REFERENCES mhtc_operations."CornerProtectionCategoryTypes" ("Code")
);

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
    "JunctionID" integer NOT NULL DEFAULT nextval('havering_operations."HaveringJunctions_id_seq"'::regclass),
    junction_point_geom geometry(Point,27700),
    map_frame_geom geometry(Polygon,27700),
    map_frame_orientation integer,
    map_scale integer,
    "JunctionProtectionCategoryTypeID" integer,
    CONSTRAINT "HaveringJunctions_pkey" PRIMARY KEY ("JunctionID"),
    CONSTRAINT "HaveringJunctions_JunctionProtectionCategoryTypeID_fkey" FOREIGN KEY ("JunctionProtectionCategoryTypeID")
        REFERENCES havering_operations."JunctionProtectionCategoryTypes" ("Code")
);

-- CornersWithinJunctions

DROP TABLE IF EXISTS havering_operations."CornersWithinJunctions";

CREATE TABLE havering_operations."CornersWithinJunctions"
(
    "JunctionID" integer NOT NULL,
    "CornerID" integer NOT NULL,
    CONSTRAINT "CornersWithinJunctions_pk" PRIMARY KEY ("JunctionID", "CornerID"),
    CONSTRAINT "CornersWithinJunctions_JunctionID_fkey" FOREIGN KEY ("JunctionID")
        REFERENCES havering_operations."HaveringJunctions" ("JunctionID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "CornersWithinJunctions_CornerID_fkey" FOREIGN KEY ("CornerID")
        REFERENCES havering_operations."HaveringCorners" ("CornerID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

DROP TABLE IF EXISTS havering_operations."HaveringCornerSegments";

CREATE TABLE havering_operations."HaveringCornerSegments"
(
	"CornerID" integer,
	"SegmentLength" double precision,
    geom geometry(LineString, 27700)
);

--

DROP TABLE IF EXISTS havering_operations."HaveringCornerSegmentEndPts";

CREATE TABLE havering_operations."HaveringCornerSegmentEndPts"
(
	"CornerID" integer,
	"StartPt" geometry(Point, 27700),
	"EndPt" geometry(Point, 27700)
);



DROP TABLE IF EXISTS havering_operations."HaveringCornerConformingSegments";

CREATE TABLE havering_operations."HaveringCornerConformingSegments"
(
	"CornerID" integer,
    geom geometry(MultiLineString, 27700),
	new_junction_protection_geom geometry(MultiLineString, 27700)
);
