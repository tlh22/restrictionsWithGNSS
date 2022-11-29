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