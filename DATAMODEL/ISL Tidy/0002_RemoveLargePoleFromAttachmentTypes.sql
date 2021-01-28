ALTER TABLE toms."Signs" DISABLE TRIGGER all;

UPDATE toms."Signs"
SET "SignsAttachmentTypeID" = 3
WHERE "SignsAttachmentTypeID" = 9;

UPDATE highway_assets."Bins"
SET "AttachmentTypeID" = 3
WHERE "AttachmentTypeID" = 9;

UPDATE highway_assets."CycleParking"
SET "AttachmentTypeID" = 3
WHERE "AttachmentTypeID" = 9;

DELETE FROM compliance_lookups."SignAttachmentTypes"
WHERE "Code" = 9;

ALTER TABLE toms."Signs" ENABLE TRIGGER all;