/***
 * Dual restrictions
 * If a restriction appears here, it is subserviant to the "LinkedTo" restriction, i.e.,
 * it's capacity is not to be included in any supply calculations (unless it is within it's hours of operation)
 ***/

DROP TABLE IF EXISTS mhtc_operations."DualRestrictions";

CREATE TABLE mhtc_operations."DualRestrictions"
(
    id SERIAL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "LinkedTo" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "DualRestrictions_pkey" PRIMARY KEY ("id")
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."DualRestrictions"
    OWNER to postgres;

-- Supply output

INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
SELECT s1."GeometryID", s2."GeometryID"
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" != s2."GeometryID"
AND s1."RestrictionTypeID" > 200;