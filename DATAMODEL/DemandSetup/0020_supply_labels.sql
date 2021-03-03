ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_pos" geometry(MultiPoint, 27700);
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_ldr" geometry(MultiLinestring, 27700);
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_loading_pos" geometry(MultiPoint, 27700);
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_loading_ldr" geometry(MultiLinestring, 27700);

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_Rotation" double precision;
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_TextChanged" character varying(254) COLLATE pg_catalog."default";

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "RestrictionID" character varying(254) COLLATE pg_catalog."default";

UPDATE mhtc_operations."Supply" SET
    "label_pos" = ST_Multi(ST_SetSRID(ST_MakePoint("label_X", "label_Y"), 27700))
WHERE "label_X" IS NOT NULL AND "label_Y" IS NOT NULL;

UPDATE mhtc_operations."Supply" SET
    "label_loading_pos" = ST_Multi(ST_SetSRID(ST_MakePoint("labelLoading_X", "labelLoading_Y"), 27700))
WHERE "labelLoading_X" IS NOT NULL AND "labelLoading_Y" IS NOT NULL;

CREATE TRIGGER insert_mngmt BEFORE INSERT OR UPDATE ON mhtc_operations."Supply" FOR EACH ROW EXECUTE PROCEDURE toms."labelling_for_restrictions"();

-- Run the trigger once to populate leaders
UPDATE mhtc_operations."Supply" SET label_pos = label_pos;
