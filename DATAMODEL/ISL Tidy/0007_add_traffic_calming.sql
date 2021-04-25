-- Traffic calming

-- add temp type to TrafficCalmingTypes

INSERT INTO "highway_asset_lookups"."TrafficCalmingTypes" ("Code", "Description") VALUES (0, 'Not classified');

-- add OS details

INSERT INTO highway_assets."TrafficCalming"(
	"RestrictionID", "Notes", "AssetConditionTypeID", "TrafficCalmingTypeID", geom_polygon)
SELECT uuid_generate_v4(), 'TH: from os_topo', 4, 0, a.wkb_geometry
FROM topography.topographicarea a, local_authority."Lb_Islington" i
WHERE descriptiveterm = '{"Traffic Calming"}'
AND ST_Within(a.wkb_geometry, i.geom);

-- check for OS records that were not picked up in the field

DROP TABLE IF EXISTS mhtc_operations."TrafficCalming_NotFound" CASCADE;

CREATE TABLE mhtc_operations."TrafficCalming_NotFound"
AS
SELECT p1."GeometryID", p1.geom_polygon
FROM highway_assets."TrafficCalming" p1
WHERE p1.geom_polygon IS NOT null
AND p1."GeometryID" NOT IN (
SELECT p2."GeometryID"
FROM highway_assets."TrafficCalming" p2, highway_assets."TrafficCalming" l
WHERE p2.geom_polygon IS NOT null
AND l.geom IS NOT NULL
AND ST_Intersects(ST_Buffer(l.geom, 0.5), p2.geom_polygon)
);

ALTER TABLE ONLY mhtc_operations."TrafficCalming_NotFound"
    ADD CONSTRAINT "TrafficCalming_NotFound_pkey" PRIMARY KEY ("GeometryID");

GRANT SELECT, UPDATE, INSERT, DELETE ON mhtc_operations."TrafficCalming_NotFound" TO toms_operator, toms_admin;

-- check for features that do not appear in OS topo, but were picked up in the field

DROP TABLE IF EXISTS mhtc_operations."TrafficCalming_Extras" CASCADE;

CREATE TABLE mhtc_operations."TrafficCalming_Extras"
AS
SELECT p1."GeometryID", p1.geom
FROM highway_assets."TrafficCalming" p1
WHERE p1.geom IS NOT null
AND p1."GeometryID" NOT IN (
SELECT l."GeometryID"
FROM highway_assets."TrafficCalming" p2, highway_assets."TrafficCalming" l
WHERE p2.geom_polygon IS NOT null
AND l.geom IS NOT NULL
AND ST_Intersects(ST_Buffer(l.geom, 0.5), p2.geom_polygon)
);

ALTER TABLE ONLY mhtc_operations."TrafficCalming_Extras"
    ADD CONSTRAINT "TrafficCalming_Extras_pkey" PRIMARY KEY ("GeometryID");

GRANT SELECT, UPDATE, INSERT, DELETE ON mhtc_operations."TrafficCalming_Extras" TO toms_operator, toms_admin;

-- Now get the details from the survey ...

ALTER TABLE highway_assets."TrafficCalming" DISABLE TRIGGER all;

UPDATE highway_assets."TrafficCalming" AS tc1
SET "TrafficCalmingTypeID" = tc2."TrafficCalmingTypeID",
    "NrCushions" = tc2."NrCushions",
    "Photos_01"=tc2."Photos_01",
    "Photos_02"=tc2."Photos_02",
    "Photos_03"=tc2."Photos_03",
    "LastUpdateDateTime"=tc2."LastUpdateDateTime",
    "LastUpdatePerson"=tc2."LastUpdatePerson",
    "MHTC_CheckIssueTypeID"=tc2."MHTC_CheckIssueTypeID",
    "MHTC_CheckNotes"=tc2."MHTC_CheckNotes",
    "FieldCheckCompleted"=tc2."FieldCheckCompleted",
    "Last_MHTC_Check_UpdateDateTime"=tc2."Last_MHTC_Check_UpdateDateTime",
    "Last_MHTC_Check_UpdatePerson"=tc2."Last_MHTC_Check_UpdatePerson",
    "CreateDateTime"=tc2."CreateDateTime",
    "CreatePerson"=tc2."CreatePerson"
FROM highway_assets."TrafficCalming" AS tc2
WHERE tc1.geom_polygon IS NOT NULL
AND tc2.geom IS NOT NULL
AND ST_Intersects(ST_Buffer(tc2.geom, 0.5), tc1.geom_polygon);

ALTER TABLE highway_assets."TrafficCalming" ENABLE TRIGGER all;