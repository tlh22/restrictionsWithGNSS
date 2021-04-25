-- restore features deleted from Bollards

ALTER TABLE highway_assets."Bollards" DISABLE TRIGGER all;

INSERT INTO highway_assets."Bollards" (
	"RestrictionID", "GeometryID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate",
	"AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes",
	geom_linestring, geom_point, "BollardTypeID",
	"FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", "NrFeatures")
SELECT "RestrictionID", "GeometryID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate",
       "AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes",
       geom_linestring, geom_point, "BollardTypeID",
       "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", "NrFeatures"
	FROM highway_assets."Bollards_210411"
WHERE "GeometryID" NOT IN (
	SELECT "GeometryID"
	FROM highway_assets."Bollards" );

ALTER TABLE highway_assets."Bollards" ENABLE TRIGGER all;

-- restore features deleted from CycleParking

ALTER TABLE highway_assets."CycleParking" DISABLE TRIGGER all;

INSERT INTO highway_assets."CycleParking"(
	"RestrictionID", "GeometryID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate",
	"AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes",
	geom_point, "CycleParkingTypeID", "NrStands", geom_linestring,
	"FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", "AttachmentTypeID")
SELECT "RestrictionID", "GeometryID", "Photos_01", "Photos_02", "Photos_03", "Notes", "RoadName", "USRN", "OpenDate", "CloseDate",
       "AssetConditionTypeID", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes",
       geom_point, "CycleParkingTypeID", "NrStands", geom_linestring,
       "FieldCheckCompleted", "Last_MHTC_Check_UpdateDateTime", "Last_MHTC_Check_UpdatePerson", "CreateDateTime", "CreatePerson", "AttachmentTypeID"
	FROM highway_assets."CycleParking_210411"
WHERE "GeometryID" NOT IN (
	SELECT "GeometryID"
	FROM highway_assets."CycleParking" );

ALTER TABLE highway_assets."CycleParking" ENABLE TRIGGER all;