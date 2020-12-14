-- check for overlaps

DROP TABLE IF EXISTS mhtc_operations."Supply_Overlaps";

CREATE TABLE mhtc_operations."Supply_Overlaps" AS
SELECT s1."GeometryID", s1."RoadName", ST_Intersection(s1.geom, s2.geom) AS geom
FROM mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE ST_Overlaps(s1.geom, s2.geom)
ORDER BY s1."RoadName";


