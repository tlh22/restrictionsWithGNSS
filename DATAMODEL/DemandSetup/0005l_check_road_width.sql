-- Check for SYL/SRL/Unmarked areas that overlap

SELECT '4.9' AS "Distance", s."GeometryID", s."Description", s."RoadName"
FROM (mhtc_operations."Supply" a LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s,
      mhtc_operations."IntersectionWithin49m" d
WHERE ST_INTERSECTS(s.geom, ST_Buffer(d.geom, 0.1))
AND (s."RestrictionTypeID" IN (201, 216, 217)
--OR s."RestrictionTypeID" IN (220, 221, 222)
--OR s."RestrictionTypeID" IN (224, 225, 226)
	 )
--ORDER BY  s."Description"

UNION

SELECT '6.7' AS "Distance", s."GeometryID", s."Description", s."RoadName"
FROM (mhtc_operations."Supply" a LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s,
      mhtc_operations."IntersectionWithin67m" d
WHERE ST_INTERSECTS(s.geom, ST_Buffer(d.geom, 0.1))
AND (s."RestrictionTypeID" IN (201, 216, 217)
--OR s."RestrictionTypeID" IN (220, 221, 222)
--OR s."RestrictionTypeID" IN (224, 225, 226)
	 )
ORDER BY  "Description", "RoadName";

/***
 Add fields
***/

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN "IntersectionWithin49m" double precision;

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN "IntersectionWithin67m" double precision;

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN "IntersectionWithin10m" double precision;


UPDATE mhtc_operations."Supply" AS s
SET "IntersectionWithin49m" = ST_LENGTH(ST_INTERSECTION(s.geom, ST_Buffer(d.geom, 0.1)))
FROM mhtc_operations."IntersectionWithin49m" d
WHERE ST_INTERSECTS(s.geom, ST_Buffer(d.geom, 0.1));

UPDATE mhtc_operations."Supply" AS s
SET "IntersectionWithin67m" = ST_LENGTH(ST_INTERSECTION(s.geom, ST_Buffer(d.geom, 0.1)))
FROM mhtc_operations."IntersectionWithin67m" d
WHERE ST_INTERSECTS(s.geom, ST_Buffer(d.geom, 0.1));