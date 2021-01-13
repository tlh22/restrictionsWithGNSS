--- measure distance from corner ...

DROP TABLE IF EXISTS mhtc_operations."CornerProtectionSections";

CREATE TABLE mhtc_operations."CornerProtectionSections"
(
	"id" integer,
	"geom" geometry
);

WITH cornerDetails AS (
SELECT c.id, c.geom As corner_geom, r.geom as road_casement_geom
FROM mhtc_operations."Corners" c, topography."road_casement" r
WHERE ST_INTERSECTS(r.geom, ST_Buffer(c.geom, 0.1))
 )
 INSERT INTO mhtc_operations."CornerProtectionSections" (id, geom)
 SELECT d.id, mhtc_operations."get_road_casement_section"(d.id, d.road_casement_geom, d.corner_geom, mhtc_operations."getParameter"('CornerProtectionDistance')::float)
 FROM cornerDetails d;

-- print out duplicate entries
SELECT id, count(*)
FROM mhtc_operations."CornerProtectionSections"
GROUP BY id
HAVING count(*) > 1;

DELETE FROM mhtc_operations."CornerProtectionSections" c1
WHERE id IN (
    SELECT id
    FROM (
        SELECT id, count(*)
        FROM mhtc_operations."CornerProtectionSections"
        GROUP BY id
        HAVING count(*) > 1) a
        );

ALTER TABLE ONLY mhtc_operations."CornerProtectionSections"
    ADD CONSTRAINT "CornerProtectionSections_pkey" PRIMARY KEY ("id");

GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerProtectionSections" TO toms_public;

--

DROP TABLE IF EXISTS  mhtc_operations."CornerProtectionSections_Single" CASCADE;

CREATE TABLE mhtc_operations."CornerProtectionSections_Single"
(
  id SERIAL,
  geom geometry(LineString,27700),
  CONSTRAINT "CornerProtectionSections_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."CornerProtectionSections_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO postgres;

-- Index: public."sidx_Corners_Single_geom"

-- DROP INDEX public."sidx_Corners_Single_geom";

CREATE INDEX "sidx_CornerProtectionSections_Single_geom"
  ON mhtc_operations."CornerProtectionSections_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."CornerProtectionSections_Single" (geom)
SELECT (ST_Dump(geom)).geom As geom
FROM mhtc_operations."CornerProtectionSections";

GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO postgres;
GRANT ALL ON TABLE mhtc_operations."CornerProtectionSections_Single" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."CornerProtectionSections_Single" TO toms_public;