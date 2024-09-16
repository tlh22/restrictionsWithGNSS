
SET search_path TO toms, mhtc_operations, highways_assets, moving_traffic, public;

-- set up corner table

DROP TABLE IF EXISTS mhtc_operations."Corners_Single" CASCADE;

CREATE TABLE mhtc_operations."Corners_Single"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "Corners_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."Corners_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."Corners_Single" TO postgres;

-- Index: public."sidx_Corners_Single_geom"

-- DROP INDEX public."sidx_Corners_Single_geom";

CREATE INDEX "sidx_Corners_Single_geom"
  ON mhtc_operations."Corners_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."Corners_Single" (geom)
SELECT DISTINCT((ST_Dump(geom)).geom) As geom
FROM mhtc_operations."Corners"
UNION
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."SectionBreakPoints";
