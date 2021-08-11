/**
Set up labels for Supply
**/

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_Rotation" double precision;
ALTER TABLE mhtc_operations."Supply" ADD COLUMN "label_TextChanged" character varying(254) COLLATE pg_catalog."default";

ALTER TABLE mhtc_operations."Supply" ADD COLUMN "RestrictionID" character varying(254) COLLATE pg_catalog."default";

-- set label position to default

UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5));

UPDATE mhtc_operations."Supply"
SET label_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), ST_LineInterpolatePoint(geom, 0.5)));

-- get trigger working
DROP TRIGGER IF EXISTS "insert_mngmt" ON mhtc_operations."Supply";
CREATE TRIGGER insert_mngmt BEFORE INSERT OR UPDATE ON mhtc_operations."Supply" FOR EACH ROW EXECUTE PROCEDURE toms."labelling_for_restrictions"();

-- Run the trigger once to populate leaders
--UPDATE mhtc_operations."Supply" SET label_pos = label_pos;



-- deal with leader bug?
UPDATE mhtc_operations."Supply"
SET label_pos = ST_Multi(ST_LineInterpolatePoint(geom, 0.5))
WHERE "GeometryID" IN ('S_002716', 'S_002865', 'S_002925');

UPDATE mhtc_operations."Supply"
SET label_ldr = ST_Multi(ST_MakeLine(ST_LineInterpolatePoint(geom, 0.5), ST_LineInterpolatePoint(geom, 0.5)))
WHERE "GeometryID" IN ('S_002716', 'S_002865', 'S_002925');
