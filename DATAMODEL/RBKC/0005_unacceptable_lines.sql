/***
 Deal with unacceptable lines using details from previous survey
***/

-- SYLs  (Check to see if the previous lines sit within the current)
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 14
WHERE "GeometryID" IN (
SELECT DISTINCT s1."GeometryID"
FROM mhtc_operations."Supply" s1, local_authority."RBKC18_SupplyMaster_190123" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s2.geom, 0.1, 0.9), ST_Buffer(s1.geom, 0.1, 'endcap=flat'))
AND s1."RestrictionTypeID" IN (201, 224)
AND s2."RestrictionTypeID" IN (221)
);

-- SRLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 222, "UnacceptableTypeID" = 14
WHERE "GeometryID" IN (
SELECT DISTINCT s1."GeometryID"
FROM mhtc_operations."Supply" s1, local_authority."RBKC18_SupplyMaster_190123" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."RestrictionTypeID" IN (217, 226)
AND s2."RestrictionTypeID" IN (222)
);


-- Maybe had buffer too small. This seems better - with 0.5m buffer

SELECT s."GeometryID", s."RoadName"
FROM mhtc_operations."Supply" s, mhtc_operations."2018_Buffered_SYL_Unacc" u
WHERE s."RestrictionTypeID" IN (201, 224)
AND ST_Within(ST_LineSubstring(s.geom, 0.1, 0.9), u.geom)

