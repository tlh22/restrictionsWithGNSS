--

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a
WHERE ST_WITHIN (s.geom, a.geom);

