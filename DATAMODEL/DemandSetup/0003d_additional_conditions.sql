--


DROP TRIGGER IF EXISTS "insert_mngmt" ON mhtc_operations."Supply";

ALTER TABLE IF EXISTS mhtc_operations."Supply"
    ALTER "AdditionalConditionID" DROP DEFAULT,
    ALTER "AdditionalConditionID" TYPE integer[][] using array["AdditionalConditionID"][],
    ALTER "AdditionalConditionID" SET DEFAULT '{{}, {}}';

CREATE TRIGGER insert_mngmt BEFORE INSERT OR UPDATE ON mhtc_operations."Supply" FOR EACH ROW EXECUTE PROCEDURE toms."labelling_for_restrictions"();


