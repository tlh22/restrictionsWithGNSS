---

--DROP FUNCTION IF EXISTS mhtc_operations."getParameter";

CREATE OR REPLACE FUNCTION mhtc_operations."getParameter"(param text) RETURNS text AS
'SELECT "Value"
FROM mhtc_operations."project_parameters"
WHERE "Field" = $1'
LANGUAGE SQL;

--- identify extent of corner "protection" on kerbline using details from "CornerSegments"

DROP FUNCTION IF EXISTS mhtc_operations."getCornerExtents";

CREATE OR REPLACE FUNCTION mhtc_operations."getCornerExtents"(cnr_id integer)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionDistance float = 5.0;
   cornerProtectionLineString geometry;
BEGIN

    -- get the corner protection distance from "project_parameters"

    -- get intersection points between apex point buffer and corner segment
    SELECT ST_Intersection(c.geom, ST_Buffer(a."ApexPt", mhtc_operations."getParameter"('CornerProtectionDistance')::float))
    INTO cornerProtectionLineString
    FROM mhtc_operations."CornerSegments" c, mhtc_operations."CornerApexPts" a
    WHERE c.id = cnr_id
    AND c.id = a.id;

    RETURN cornerProtectionLineString;

END;
$BODY$;

DROP TABLE IF EXISTS mhtc_operations."CornerProtectionSections";

CREATE TABLE mhtc_operations."CornerProtectionSections"
(
	"id" integer,
	"geom" geometry(LineString)
);

INSERT INTO mhtc_operations."CornerProtectionSections" (id, geom)
SELECT c.id, mhtc_operations."getCornerExtents"(c.id)
FROM mhtc_operations."Corners" c;

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
  geom geometry(Point,27700),
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