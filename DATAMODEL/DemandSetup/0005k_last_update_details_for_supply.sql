/***
 * ensure last update details are set
 ***/

CREATE TRIGGER "set_last_update_details_supply"
    BEFORE INSERT OR UPDATE
    ON mhtc_operations."Supply"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_last_update_details();
