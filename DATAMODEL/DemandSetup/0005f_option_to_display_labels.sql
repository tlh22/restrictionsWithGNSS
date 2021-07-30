**
Adds field to allow turn on/off of label. This avoid multiple labels/leaders being shown for the same restrictions that are in close proximity
**/

ALTER TABLE "mhtc_operations"."Supply"
    ADD COLUMN "DisplayLabel" boolean DEFAULT TRUE NOT NULL;

ALTER TABLE "mhtc_operations"."Supply"
    ADD COLUMN "label_Rotation" double precision;

CREATE TRIGGER insert_mngmt BEFORE INSERT OR UPDATE ON "mhtc_operations"."Supply" FOR EACH ROW EXECUTE PROCEDURE toms."labelling_for_restrictions"();

UPDATE "mhtc_operations"."Supply" SET label_pos = label_pos;