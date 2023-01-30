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

-- For RBKC need to consider that Market Bays, taxi bays and cycle hangards should have lower status than SYL/DYL.

INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
SELECT s1."GeometryID", s2."GeometryID"
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" != s2."GeometryID"
AND s1."RestrictionTypeID" > 200
AND s2."RestrictionTypeID" NOT IN (121, 147, 151, 164);

-- Now consider specifically
INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
SELECT s1."GeometryID", s2."GeometryID"
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" != s2."GeometryID"
AND s1."RestrictionTypeID" IN (121, 147, 151, 164)
AND s2."RestrictionTypeID" IN (201, 221, 224, 202);

-- Also need to consider School Keep Clears and SYLs/DYLs

INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
SELECT s1."GeometryID", s2."GeometryID"
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" != s2."GeometryID"
AND s1."RestrictionTypeID" IN (203, 204, 205, 206, 207, 208)
AND s2."RestrictionTypeID" IN (201, 221, 224, 202);

-- Remove duplicates

DELETE
FROM mhtc_operations."DualRestrictions" d1
USING mhtc_operations."DualRestrictions" d2
WHERE d1."GeometryID" = d2."GeometryID"
AND d1."LinkedTo" = d2."LinkedTo"
AND d1.id < d2.id;

-- Add geometry column

ALTER TABLE mhtc_operations."DualRestrictions"
    ADD COLUMN "geom" geometry(LineString,27700);

UPDATE mhtc_operations."DualRestrictions" AS d
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID";

-- Remove any short restrictions from this list

DELETE
FROM mhtc_operations."DualRestrictions" d
WHERE ST_Length(d.geom) < 1.0;

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND ST_Length(s.geom) < 1.0;

-- Remove any restrictions that no longer exist

DELETE
FROM mhtc_operations."DualRestrictions" d
WHERE "GeometryID" NOT IN
    (SELECT "GeometryID" FROM mhtc_operations."Supply");

DELETE
FROM mhtc_operations."DualRestrictions" d
WHERE "LinkedTo" NOT IN
    (SELECT "GeometryID" FROM mhtc_operations."Supply");

-- Remove any DYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = 202;

-- Remove and SYLs/DYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE d."GeometryID" = s1."GeometryID"
AND s1."GeometryID" IN (201, 221, 224)
AND d."LinkedTo" = s2."GeometryID"
AND s2."RestrictionTypeID" = 202;

-- Remove and SYLs/SYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE d."GeometryID" = s1."GeometryID"
AND s1."RestrictionTypeID" IN (201, 221, 224)
AND d."LinkedTo" = s2."GeometryID"
AND s2."RestrictionTypeID" IN (201, 221, 224);

-- Remove any situations where the ZigZag is linked to
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (203, 204, 205, 206, 207, 208);

-- Remove DRLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = 218;

-- Remove and SYLs/SYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE d."GeometryID" = s1."GeometryID"
AND s1."RestrictionTypeID" IN (217, 222, 226)
AND d."LinkedTo" = s2."GeometryID"
AND s2."RestrictionTypeID" IN (217, 222, 226);

-- Remove crossings
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (209, 210, 211, 212, 213, 214, 215);

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (209, 210, 211, 212, 213, 214, 215);

-- Remove any Cycle Hire bays
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (116);

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (116);


