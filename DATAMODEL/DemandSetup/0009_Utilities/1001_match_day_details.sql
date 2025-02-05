ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN "MatchDayEventDayZone" character varying(40) COLLATE pg_catalog."default";

UPDATE mhtc_operations."Supply" AS r
SET "MatchDayEventDayZone" = c."EDZ"
FROM "toms"."MatchDayEventDayZones" c
WHERE ST_WITHIN (r.geom, c.geom);