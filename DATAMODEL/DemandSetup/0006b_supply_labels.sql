/**
Set up labels for Supply
**/

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_Rotation" double precision;
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_TextChanged" character varying(254) COLLATE pg_catalog."default";

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "RestrictionID" character varying(254) COLLATE pg_catalog."default";

DROP TRIGGER IF EXISTS "insert_mngmt" ON mhtc_operations."Supply";
CREATE TRIGGER insert_mngmt BEFORE INSERT OR UPDATE ON mhtc_operations."Supply" FOR EACH ROW EXECUTE PROCEDURE toms."labelling_for_restrictions"();

-- Run the trigger once to populate leaders
UPDATE mhtc_operations."Supply" SET label_pos = label_pos;
