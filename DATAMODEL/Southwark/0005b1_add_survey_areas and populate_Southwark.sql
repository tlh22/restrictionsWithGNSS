


-- Add to Supply

ALTER TABLE IF EXISTS mhtc_operations."Supply"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE mhtc_operations."Supply"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE "mhtc_operations"."Supply" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

-- Add to RestrictionPolygons

ALTER TABLE IF EXISTS toms."RestrictionPolygons"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE toms."RestrictionPolygons"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE toms."RestrictionPolygons" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

--

ALTER TABLE IF EXISTS highways_network.roadlink
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE highways_network.roadlink
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE highways_network.roadlink AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE highways_network.roadlink AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;


--
/***
-- Add to Supply_A_B_S1

ALTER TABLE IF EXISTS mhtc_operations."Supply_A_B_S1"
  ADD COLUMN IF NOT EXISTS "SouthwarkProposedDeliveryZoneID" INTEGER;

UPDATE mhtc_operations."Supply_A_B_S1"
SET "SouthwarkProposedDeliveryZoneID" = NULL;

UPDATE "mhtc_operations"."Supply_A_B_S1" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_WITHIN (s.geom, a.geom);

UPDATE "mhtc_operations"."Supply_A_B_S1" AS s
SET "SouthwarkProposedDeliveryZoneID" = a."ogc_fid"
FROM import_geojson."SouthwarkProposedDeliveryZones" a
WHERE ST_INTERSECTS (s.geom, a.geom)
AND "SouthwarkProposedDeliveryZoneID" IS NULL;

***/

/***

Add into main 

-- Supply

INSERT INTO mhtc_operations."Supply"(
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", label_pos, label_ldr, label_loading_pos, label_loading_ldr, "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyAreaID", "SouthwarkProposedDeliveryZoneID")	
SELECT 
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", label_pos, label_ldr, label_loading_pos, label_loading_ldr, "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyAreaID", "SouthwarkProposedDeliveryZoneID"
	FROM mhtc_operations."Supply_A_B_S1";
	
-- RiS
	
INSERT INTO demand."RestrictionsInSurveys"(
	"SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03", "CaptureSource", "Demand_ALL", "Demand", "DemandInSuspendedAreas", "Demand_Waiting", "Demand_Idling", "Demand_ParkedIncorrectly", "CapacityAtTimeOfSurvey", "Stress", "PerceivedAvailableSpaces", "PerceivedCapacityAtTimeOfSurvey", "PerceivedStress", "Supply_Notes", "MCL_Notes", geom, "GeometryID_SurveyID")
SELECT 
    "SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03", "CaptureSource", "Demand_ALL", "Demand", "DemandInSuspendedAreas", "Demand_Waiting", "Demand_Idling", "Demand_ParkedIncorrectly", "CapacityAtTimeOfSurvey", "Stress", "PerceivedAvailableSpaces", "PerceivedCapacityAtTimeOfSurvey", "PerceivedStress", "Supply_Notes", "MCL_Notes", geom, "GeometryID_SurveyID"
	FROM "demand_A_B_S1"."RestrictionsInSurveys_20250728";


INSERT INTO demand."Counts"(
	"SurveyID", "GeometryID", "NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses", "NrSpaces", "Notes", "DoubleParkingDetails", "NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended", "NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended", "NrCarsWaiting", "NrLGVsWaiting", "NrMCLsWaiting", "NrTaxisWaiting", "NrOGVsWaiting", "NrMiniBusesWaiting", "NrBusesWaiting", "NrCarsIdling", "NrLGVsIdling", "NrMCLsIdling", "NrTaxisIdling", "NrOGVsIdling", "NrMiniBusesIdling", "NrBusesIdling", "NrCarsParkedIncorrectly", "NrLGVsParkedIncorrectly", "NrMCLsParkedIncorrectly", "NrTaxisParkedIncorrectly", "NrOGVsParkedIncorrectly", "NrMiniBusesParkedIncorrectly", "NrBusesParkedIncorrectly", "NrCarsWithDisabledBadgeParkedInPandD", "GeometryID_SurveyID")
SELECT 
    "SurveyID", "GeometryID", "NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses", "NrSpaces", "Notes", "DoubleParkingDetails", "NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended", "NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended", "NrCarsWaiting", "NrLGVsWaiting", "NrMCLsWaiting", "NrTaxisWaiting", "NrOGVsWaiting", "NrMiniBusesWaiting", "NrBusesWaiting", "NrCarsIdling", "NrLGVsIdling", "NrMCLsIdling", "NrTaxisIdling", "NrOGVsIdling", "NrMiniBusesIdling", "NrBusesIdling", "NrCarsParkedIncorrectly", "NrLGVsParkedIncorrectly", "NrMCLsParkedIncorrectly", "NrTaxisParkedIncorrectly", "NrOGVsParkedIncorrectly", "NrMiniBusesParkedIncorrectly", "NrBusesParkedIncorrectly", "NrCarsWithDisabledBadgeParkedInPandD", "GeometryID_SurveyID"
	FROM "demand_A_B_S1"."Counts_20250728";
	
***/