-- Bus Shelters
UPDATE highway_assets."BusShelters"
SET "GeomShapeID" = 23;  # Polygon (on pavement)

UPDATE highway_assets."BusShelters"
SET "BayWidth" = 1.0;

UPDATE highway_assets."BusShelters" AS c
SET "AzimuthToRoadCentreLine" = ST_Azimuth(ST_LineInterpolatePoint(c.geom, 0.5), closest.geom)
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id,
	  ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
	  ST_Distance(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length
      FROM "highways_network"."roadlink" cl, highway_assets."BusShelters" s
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

/*
Actually it is better to use the TOMs functions:
 - update Az
 - update polygon_geom -   concat( 'SRID=27700;',  geom_to_wkt( generateDisplayGeometry() ))

*/

-- Would be good to make the shelters parallel to the kerb ...
