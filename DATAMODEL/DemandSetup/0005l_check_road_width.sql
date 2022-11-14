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
ORDER BY  "Description", "RoadName"