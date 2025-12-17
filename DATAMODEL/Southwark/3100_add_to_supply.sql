
/***

Now add to Supply

***/


INSERT INTO mhtc_operations."Supply"(
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", label_pos, label_ldr, label_loading_pos, label_loading_ldr, "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", ogc_fid, "SurveyAreaID")
SELECT "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", label_pos, label_ldr, label_loading_pos, label_loading_ldr, "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", COALESCE("NrBays", -1), "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", ogc_fid, "SurveyAreaID"
	FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";
	
