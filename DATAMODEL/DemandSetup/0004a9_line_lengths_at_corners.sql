
CREATE OR REPLACE FUNCTION line_length_at_corner(IN cornerID int) RETURNS float AS
$BODY$
DECLARE
    len_DYL float;
    len_Bays float;
    len_relevant_line float;
BEGIN

        len_DYL = 0;
        len_Bays = 0;
        len_relevant_line = 0;

        RAISE NOTICE '**** CornerID: %', cornerID;

        SELECT COALESCE(SUM(ST_Length(ST_Intersection(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1)))), 0) INTO len_DYL
        FROM mhtc_operations."CornerSegments" c, "toms"."Lines" l
        WHERE c."id" = cornerID
        AND ST_Intersects(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1))
        AND l."RestrictionTypeID" NOT IN (201, 221, 224, 216, 220);

        --RAISE NOTICE 'DYL: %', len_DYL;

        SELECT COALESCE(SUM(ST_Length(ST_Intersection(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1)))), 0) INTO len_Bays
        FROM mhtc_operations."CornerSegments" c, "toms"."Bays" l
		WHERE c."id" = cornerID
        AND ST_Intersects(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1));

        --RAISE NOTICE 'Bays: %', len_Bays;

        len_relevant_line = len_DYL + len_Bays;

        RAISE NOTICE 'len_relevant_line: %', len_relevant_line;

        RETURN len_relevant_line;

END
$BODY$
LANGUAGE plpgsql;

DROP TABLE IF EXISTS mhtc_operations."LineLengthAtCorner";

CREATE TABLE mhtc_operations."LineLengthAtCorner"
(
	"id" integer,
	"LineLength" double precision
);

WITH corners AS (
SELECT "id" FROM mhtc_operations."Corners" c)
    INSERT INTO mhtc_operations."LineLengthAtCorner" (id, "LineLength")
    SELECT corners.id, line_length_at_corner(corners.id)
	FROM corners;

 ALTER TABLE ONLY mhtc_operations."LineLengthAtCorner"
    ADD CONSTRAINT "LineLengthAtCorner_pkey" PRIMARY KEY ("id");

SELECT id, "LineLength"
	FROM mhtc_operations."LineLengthAtCorner"
	WHERE "LineLength" < 19.0;

SELECT "LineLength"::int AS grouping, COUNT(id) AS nrCorners
FROM  mhtc_operations."LineLengthAtCorner"
GROUP BY  grouping
ORDER  BY grouping DESC;

GRANT ALL ON TABLE mhtc_operations."LineLengthAtCorner" TO postgres;
GRANT ALL ON TABLE mhtc_operations."LineLengthAtCorner" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."LineLengthAtCorner" TO toms_public;
