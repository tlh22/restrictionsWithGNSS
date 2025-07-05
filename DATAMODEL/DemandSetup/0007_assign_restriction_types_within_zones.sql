-- Set restriction type within zones

-- for unmarked areas within ped zone or restricted zone

UPDATE "mhtc_operations"."Supply" AS s
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 5
FROM toms."RestrictionPolygons" a
WHERE s."RestrictionTypeID" = 216
AND ST_INTERSECTS (a.geom, s.geom)
AND a."RestrictionTypeID" IN (3, 9, 10);

UPDATE "mhtc_operations"."Supply" AS s
SET "RestrictionTypeID" = 228
FROM toms."RestrictionPolygons" a
WHERE s."RestrictionTypeID" = 220
AND ST_INTERSECTS (a.geom, s.geom)
AND a."RestrictionTypeID" IN (3, 9, 10);

UPDATE "mhtc_operations"."Supply" AS s
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 5
FROM toms."RestrictionPolygons" a
WHERE s."RestrictionTypeID" = 225
AND ST_INTERSECTS (a.geom, s.geom)
AND a."RestrictionTypeID" IN (3, 9, 10);

-- for any restrictions within PPZ

UPDATE "mhtc_operations"."Supply" AS s
SET "PermitCode" = a."AreaPermitCode"
FROM toms."RestrictionPolygons" a
WHERE ST_INTERSECTS (a.geom, s.geom)
AND a."RestrictionTypeID" IN (2);

UPDATE "mhtc_operations"."Supply" AS s
SET "PermitCode" = a."AreaPermitCode"
FROM toms."RestrictionPolygons" a
WHERE ST_INTERSECTS (a.geom, s.geom)
AND a."RestrictionTypeID" IN (2);

UPDATE "mhtc_operations"."Supply" AS s
SET "PermitCode" = a."AreaPermitCode"
FROM toms."RestrictionPolygons" a
WHERE ST_INTERSECTS (a.geom, s.geom)
AND a."RestrictionTypeID" IN (2);