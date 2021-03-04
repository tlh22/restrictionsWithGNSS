-- check for overlaps

DROP TABLE IF EXISTS mhtc_operations."Supply_Overlaps";

CREATE TABLE mhtc_operations."Supply_Overlaps"
(
    gid SERIAL,
	"GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
	"RoadName" character varying(254) COLLATE pg_catalog."default",
    geom geometry(Geometry,27700)
);

INSERT INTO mhtc_operations."Supply_Overlaps" ("GeometryID", "RoadName", geom)
SELECT s1."GeometryID", s1."RoadName", ST_Intersection(s1.geom, s2.geom) AS geom
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_Overlaps(s1.geom, s2.geom)
ORDER BY s1."RoadName";

ALTER TABLE mhtc_operations."Supply_Overlaps"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."Supply_Overlaps" TO postgres;


