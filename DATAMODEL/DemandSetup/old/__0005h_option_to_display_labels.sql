/**
Adds field to allow turn on/off of label. This avoid multiple labels/leaders being shown for the same restrictions that are in close proximity
**/

ALTER TABLE "mhtc_operations"."Supply"
    ADD COLUMN IF NOT EXISTS "DisplayLabel" boolean DEFAULT TRUE NOT NULL;


CREATE OR REPLACE FUNCTION mhtc_operations.reset_label_leader()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE

BEGIN

    IF NEW."DisplayLabel" = 'false' THEN
		UPDATE mhtc_operations."Supply"
		SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5)), label_ldr = NULL
		WHERE "GeometryID" = NEW."GeometryID";
    END IF;

	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION mhtc_operations.reset_label_leader()
    OWNER TO postgres;
	
-- When DisplayLabel is set to 'false', reset the leader

CREATE TRIGGER "reset_label_leader_supply"
    BEFORE UPDATE OF "DisplayLabel"
    ON mhtc_operations."Supply"
    FOR EACH ROW
    EXECUTE PROCEDURE mhtc_operations.reset_label_leader();


/***
-- Update any already set to false

UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5)), label_ldr = NULL
WHERE "DisplayLabel" = 'false';

***/




