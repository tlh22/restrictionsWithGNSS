-- check for overlaps

DROP TABLE IF EXISTS mhtc_operations."Supply_Overlaps";

CREATE TABLE mhtc_operations."Supply_Overlaps"
(
    id SERIAL,
    "GeometryID_1" character varying(12) COLLATE pg_catalog."default" NOT NULL,
	"RestrictionTypeID_1" integer,
    "GeometryID_2" character varying(12) COLLATE pg_catalog."default" NOT NULL,
	"RestrictionTypeID_2" integer,
	"RoadName" character varying(254) COLLATE pg_catalog."default",
    geom geometry,
    CONSTRAINT "Supply_Overlaps_pkey" PRIMARY KEY ("id")
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."Supply_Overlaps"
    OWNER to postgres;

INSERT INTO mhtc_operations."Supply_Overlaps" ("GeometryID_1", "RestrictionTypeID_1", "GeometryID_2", "RestrictionTypeID_2", "RoadName", geom)
SELECT s1."GeometryID" AS "GeometryID_1", s1."RestrictionTypeID" AS "RestrictionTypeID_1", 
s2."GeometryID"  AS "GeometryID_2", s2."RestrictionTypeID" AS "RestrictionTypeID_2", s1."RoadName", ST_Intersection(s1.geom, s2.geom) AS geom
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" < s2."GeometryID"
ORDER BY s1."GeometryID", s1."RoadName";

GRANT ALL ON TABLE mhtc_operations."Supply_Overlaps" TO postgres;

-- Output

SELECT "GeometryID_1", "BayLineTypes1"."Description" AS "RestrictionType Description",
       "GeometryID_2", "BayLineTypes2"."Description" AS "RestrictionType Description", "RoadName"
FROM mhtc_operations."Supply_Overlaps" so
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes1" ON so."RestrictionTypeID_1" is not distinct from "BayLineTypes1"."Code"
	 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes2" ON so."RestrictionTypeID_2" is not distinct from "BayLineTypes2"."Code"
;

SELECT s1."GeometryID", s1."RestrictionTypeID", s2."GeometryID", s2."RestrictionTypeID", s1."RoadName", ST_Intersection(s1.geom, s2.geom) AS geom
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" < s2."GeometryID"
ORDER BY s1."GeometryID", s1."RoadName";


