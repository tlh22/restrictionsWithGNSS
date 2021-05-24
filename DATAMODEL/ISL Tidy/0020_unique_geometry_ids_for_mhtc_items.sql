-- MHTC_RoadLinks

ALTER TABLE highways_network."MHTC_RoadLinks"
    ALTER COLUMN "GeometryID" SET DEFAULT ('J_'::text || to_char(nextval('highways_network."MHTC_RoadLinks_id_seq"'::regclass), 'FM0000000'::text));

ALTER TABLE highways_network."MHTC_RoadLinks" DISABLE TRIGGER all;

UPDATE highways_network."MHTC_RoadLinks" AS r
SET "GeometryID" = DEFAULT
--WHERE "GeometryID" = 'U'
;

ALTER TABLE highways_network."MHTC_RoadLinks" ENABLE TRIGGER all;

-- MHTC_Kerblines

ALTER TABLE "mhtc_operations"."MHTC_Kerblines"
    ALTER COLUMN "GeometryID" SET DEFAULT ('K_'::text || to_char(nextval('mhtc_operations."MHTC_Kerblines_id_seq"'::regclass), 'FM0000000'::text));

ALTER TABLE "mhtc_operations"."MHTC_Kerblines" ENABLE TRIGGER all;

ALTER TABLE "mhtc_operations"."MHTC_Kerblines" DISABLE TRIGGER all;

UPDATE "mhtc_operations"."MHTC_Kerblines" AS r
SET "GeometryID" = DEFAULT
--WHERE "GeometryID" = 'U'
;

ALTER TABLE "mhtc_operations"."MHTC_Kerblines" ENABLE TRIGGER all;

-- Lines
ALTER TABLE "toms"."Lines" DISABLE TRIGGER all;

UPDATE "toms"."Lines" AS r
SET "GeometryID" = DEFAULT
WHERE "GeometryID" = 'a';

ALTER TABLE "toms"."Lines" ENABLE TRIGGER all;