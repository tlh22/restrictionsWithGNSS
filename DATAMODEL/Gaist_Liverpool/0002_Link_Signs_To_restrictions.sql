/***
 Create link between signs and restrictions - usually many signs for one restriction - but could be many to many
 ***/
 
 -- Add GeometryID to Gaist tables
ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN IF NOT EXISTS "GeometryID" character varying(12) COLLATE pg_catalog."default";

UPDATE local_authority."Gaist_Signs"
SET "GeometryID" = concat('GS_', to_char(id, 'FM000000'::text));

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ALTER COLUMN "GeometryID" SET NOT NULL;
 
ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ADD COLUMN IF NOT EXISTS "GeometryID" character varying(12) COLLATE pg_catalog."default";

UPDATE local_authority."Gaist_RoadMarkings_Lines"
SET "GeometryID" = concat('GL_', to_char(id, 'FM000000'::text));

ALTER TABLE IF EXISTS local_authority."Gaist_RoadMarkings_Lines"
    ALTER COLUMN "GeometryID" SET NOT NULL;


 --
 
DROP TABLE IF EXISTS "mhtc_operations"."SignsForRestrictions" CASCADE;

CREATE TABLE "mhtc_operations"."SignsForRestrictions"
(
  gid SERIAL,
  "SignGeometryID" character varying(12),
  "RestrictionGeometryID" character varying(12),
  CONSTRAINT "SignsForRestrictions_pkey" PRIMARY KEY (gid),
  UNIQUE ("SignGeometryID", "RestrictionGeometryID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "mhtc_operations"."SignsForRestrictions"
  OWNER TO postgres;
  
/***
-- Link signs that are "close" (within 5m) and which have the same restriction type

Restriction types are:
1017 - SYL
1018.1 - DYL
1025.1.3.4 - Bus Stop
1027.1 - Zig Zag
1028.1.4 - Parking bay
***/

-- lines
INSERT INTO "mhtc_operations"."SignsForRestrictions" ("SignGeometryID", "RestrictionGeometryID")
SELECT s."GeometryID", l."GeometryID"
FROM local_authority."Gaist_Signs" s, local_authority."Gaist_RoadMarkings_Lines" l
WHERE ST_DWithin(s.geom, l.geom, 5.0)
AND l."Dft Diagra" IN ( '1017', '1018.1')
AND s."Dft Diagra" IN ('637.3', '638', '638.1', '639', '640', '650.2', '650.3');

-- bays
INSERT INTO "mhtc_operations"."SignsForRestrictions" ("SignGeometryID", "RestrictionGeometryID")
SELECT s."GeometryID", l."GeometryID"
FROM local_authority."Gaist_Signs" s, local_authority."Gaist_RoadMarkings_Lines" l
WHERE ST_DWithin(s.geom, l.geom, 5.0)
AND l."Dft Diagra" IN ( '1028.1', '1028.4')
AND s."Dft Diagra" IN ('660', '660.3', '660.4', '660.6', '661.1', '661.2A', '661.3A', '661.4', '661A', '662', '667', '668', '801', '969');

-- Bus stops
INSERT INTO "mhtc_operations"."SignsForRestrictions" ("SignGeometryID", "RestrictionGeometryID")
SELECT s."GeometryID", l."GeometryID"
FROM local_authority."Gaist_Signs" s, local_authority."Gaist_RoadMarkings_Lines" l
WHERE ST_DWithin(s.geom, l.geom, 5.0)
AND l."Dft Diagra" IN ( '1025.1', '1025.3', '1025.4')
AND s."Dft Diagra" IN ('974');

-- Zig Zags
INSERT INTO "mhtc_operations"."SignsForRestrictions" ("SignGeometryID", "RestrictionGeometryID")
SELECT s."GeometryID", l."GeometryID"
FROM local_authority."Gaist_Signs" s, local_authority."Gaist_RoadMarkings_Lines" l
WHERE ST_DWithin(s.geom, l.geom, 5.0)
AND l."Dft Diagra" IN ( '1027.1')
AND s."Dft Diagra" IN ('642.2A');
