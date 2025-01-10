/**
Deal with unmarked areas within PPZ
**/

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 227
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 216  -- Unmarked (Acceptable)
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 228
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 220   -- Unmarked (Unacceptable)
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 229
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 225   -- Unmarked
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);