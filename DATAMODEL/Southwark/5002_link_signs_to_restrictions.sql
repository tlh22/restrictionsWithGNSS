/***

Link restrictions to signs

***/

/***

set up linkage between restriction type and sign type

***/

CREATE TABLE IF NOT EXISTS mhtc_operations."RestrictionTypes_SignType_Lookup"
(
    id SERIAL,
    "RestrictionTypeID" integer,
	"SignType" integer,
    CONSTRAINT "RestrictionTypes_SignType_Lookup_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS mhtc_operations."RestrictionTypes_SignType_Lookup"
    OWNER to postgres;

INSERT INTO mhtc_operations."RestrictionTypes_SignType_Lookup" ("RestrictionTypeID")
SELECT "Code" FROM toms_lookups."BayTypesInUse";

INSERT INTO mhtc_operations."RestrictionTypes_SignType_Lookup" ("RestrictionTypeID")
SELECT "Code" FROM toms_lookups."LineTypesInUse";


--- Manually assigns sign types to restrictions

-- Now link restrictions to signs

DROP TABLE IF EXISTS mhtc_operations."SignRestrictionLink";

CREATE TABLE mhtc_operations."SignRestrictionLink"
(
    id SERIAL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "LinkedTo" character varying(12) COLLATE pg_catalog."default" NOT NULL,
	geom geometry(Point,27700),
	distance double precision,
    CONSTRAINT "SignRestrictionLink_pkey" PRIMARY KEY ("id")
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."SignRestrictionLink"
    OWNER to postgres;

ALTER TABLE mhtc_operations."SignRestrictionLink"
ADD UNIQUE ("GeometryID", "LinkedTo");

-- Bays

INSERT INTO mhtc_operations."SignRestrictionLink" ("GeometryID", "LinkedTo", geom, distance)
SELECT s."GeometryID", r."GeometryID", s.geom, ST_Length(ST_ShortestLine(s.geom, r.geom)) As this_distance
FROM toms."Bays" r, mhtc_operations."RestrictionTypes_SignType_Lookup" l, toms."Signs" s
WHERE ST_DWithin(s.geom, r.geom, 7.5)
AND r."RestrictionTypeID" = l."RestrictionTypeID"
AND l."SignType" IN (s."SignType_1", s."SignType_2", s."SignType_3", s."SignType_4")
AND (s."GeometryID", r."GeometryID") NOT IN (
    SELECT "GeometryID", "LinkedTo"
    FROM mhtc_operations."SignRestrictionLink"
    );
	
-- Lines

INSERT INTO mhtc_operations."SignRestrictionLink" ("GeometryID", "LinkedTo", geom, distance)
SELECT DISTINCT ON (s."GeometryID", r."GeometryID") s."GeometryID", r."GeometryID", s.geom, ST_Length(ST_ShortestLine(s.geom, r.geom)) As this_distance
FROM toms."Lines" r, mhtc_operations."RestrictionTypes_SignType_Lookup" l, toms."Signs" s
WHERE ST_DWithin(s.geom, r.geom, 7.5)
AND r."RestrictionTypeID" = l."RestrictionTypeID"
AND l."SignType" IN (s."SignType_1", s."SignType_2", s."SignType_3", s."SignType_4")
AND (s."GeometryID", r."GeometryID") NOT IN (
    SELECT "GeometryID", "LinkedTo"
    FROM mhtc_operations."SignRestrictionLink"
    )
;

-- Check for bay signs that are linked to the different Bays

DELETE FROM mhtc_operations."SignRestrictionLink"
WHERE  ("GeometryID", "LinkedTo") IN 
(SELECT l2."GeometryID", l2."LinkedTo"
FROM mhtc_operations."SignRestrictionLink" l1, mhtc_operations."SignRestrictionLink" l2, toms."Signs" r 
WHERE l1."GeometryID" = l2."GeometryID"
AND l1."LinkedTo" != l2."LinkedTo"
AND l1.distance < l2.distance
AND l1."GeometryID" = r."GeometryID"
AND r."SignType_1" IN (26, 28, 31, 32, 45)
)
;

-- Are there any signs that are not associated with restrictions??

SELECT "GeometryID", "RoadName", "SignType_1", "SignTypes"."Description" AS "SignType_Description" --, geom
FROM toms."Signs" r
	LEFT JOIN "toms_lookups"."SignTypes" AS "SignTypes" ON r."SignType_1" is not distinct from "SignTypes"."Code"
WHERE "GeometryID" NOT IN (SELECT "GeometryID"
						   FROM mhtc_operations."SignRestrictionLink")
AND COALESCE("ComplianceRestrictionSignIssue", 1) = 1
AND COALESCE("SignConditionTypeID", 1) = 1
AND COALESCE("MHTC_CheckIssueTypeID", 1) = 1

-- exclude CPZ entry/exit, PPA entry/exit, half-on/half-off parking, ped zones and overnight bus/truck restrictions

AND NOT (
	r."SignType_1" IN (6,7, 17, 27, 30, 37, 40, 44, 46, 47, 48, 49, 50, 52, 53, 6634, 64021) AND
	r."SignType_2" IN (6,7, 17, 27, 30, 37, 40, 44, 46, 47, 48, 49, 50, 52, 53, 6634, 64021) AND
	r."SignType_3" IN (6,7, 17, 27, 30, 37, 40, 44, 46, 47, 48, 49, 50, 52, 53, 6634, 64021) AND
	r."SignType_4" IN (6,7, 17, 27, 30, 37, 40, 44, 46, 47, 48, 49, 50, 52, 53, 6634, 64021)
)

-- exclude any permit holder signs within a PPA

AND r."GeometryID" NOT IN (
	SELECT b."GeometryID"
	FROM toms."Signs" b, toms."RestrictionPolygons" p 
	WHERE ST_DWithin(b.geom, p.geom, 7.5)
	AND p."RestrictionTypeID" IN (2, 4) -- PPA
	AND (
	b."SignType_1" IN (28, 31) OR  -- permit holders
	b."SignType_2" IN (28, 31) OR
	b."SignType_3" IN (28, 31) OR
	b."SignType_4" IN (28, 31)
	)
) 

ORDER BY "GeometryID"
