/***

Now, add a field with the original geometry IDENTIFIED

***/

ALTER TABLE IF EXISTS mhtc_operations."Supply"
    ADD COLUMN "DemandSection_GeometryID" character varying(12);
	
UPDATE mhtc_operations."Supply" AS c
SET "DemandSection_GeometryID" = "GeometryID";


