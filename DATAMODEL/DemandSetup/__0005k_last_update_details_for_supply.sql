/***
 * ensure last update details are set
 ***/

CREATE TRIGGER "set_last_update_details_supply"
    BEFORE INSERT OR UPDATE OF "GeometryID", geom, "RestrictionTypeID", "GeomShapeID", "Notes", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth"
    ON mhtc_operations."Supply"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_last_update_details();


