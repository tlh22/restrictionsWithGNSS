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
AND ST_Intersects(ST_Buffer(l.geom, 0.5), p2.geom)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON mhtc_operations."TrafficCalming_NotFound" TO toms_operator, toms_admin;

-- check for features that do not appear in OS topo, but were picked up in the field

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
AND ST_Intersects(ST_Buffer(l.geom, 0.5), p2.geom)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON mhtc_operations."TrafficCalming_Extras" TO toms_operator, toms_admin;