/***

 Move trigger on project parameters to Supply
 
 ***/

CREATE OR REPLACE FUNCTION public.revise_all_capacities()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	 vehicleLength real := 0.0;
	 vehicleWidth real := 0.0;
	 motorcycleWidth real := 0.0;
BEGIN

    IF NEW."Field" = 'VehicleLength' OR  NEW."Field" = 'VehicleWidth' OR NEW."Field" = 'MotorcycleWidth' THEN
        UPDATE "mhtc_operations"."Supply" SET "RestrictionLength" = ROUND(public.ST_Length ("geom")::numeric,2);
    END IF;

	RETURN NEW;

END;
$BODY$;

ALTER FUNCTION public.revise_all_capacities()
    OWNER TO postgres;