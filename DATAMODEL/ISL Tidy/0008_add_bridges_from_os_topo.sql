-- Bridges

-- add temp type to TrafficCalmingTypes

INSERT INTO "highway_asset_lookups"."BridgeTypes" ("Code", "Description") VALUES (0, 'Not classified');

-- add OS details

INSERT INTO highway_assets."Bridges"(
	"RestrictionID", "Notes", "AssetConditionTypeID", "BridgeTypeID", geom_polygon)
SELECT uuid_generate_v4(), 'TH: from os_topo', 4, 0, (ST_Dump(ST_Multi(ST_Union (c.geom)))).geom AS geom
FROM (SELECT a.wkb_geometry AS geom FROM topography.topographicarea a, local_authority."Lb_Islington" i
      WHERE descriptiveterm = '{"Bridge"}'
      AND ST_Within(a.wkb_geometry, ST_Buffer(i.geom, 25.0))
) AS c;

-- Add any others and classify ??
