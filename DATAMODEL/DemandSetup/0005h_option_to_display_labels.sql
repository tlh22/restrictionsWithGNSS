/**
Adds field to allow turn on/off of label. This avoid multiple labels/leaders being shown for the same restrictions that are in close proximity
**/

ALTER TABLE "mhtc_operations"."Supply"
    ADD COLUMN "DisplayLabel" boolean DEFAULT TRUE NOT NULL;

