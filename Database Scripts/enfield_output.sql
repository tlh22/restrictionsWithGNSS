SELECT "Area", "GeometryID", "RoadName", "Location", COALESCE("BayStatusTypes"."Description", '') AS "Status",
"RestrictionLength", "NrBays", "Capacity", "Notes", "LastUpdateDateTime", "LastUpdatePerson", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "Photos_01", name, sections, bay_type, baylist_type, "TimePeriod_Description", "MaxStay_Description", "TheoreticalSpaces",  baylist_notes_1, baylist_notes_2,
"BayLineTypes"."Description" AS "RestrictionDescription",
COALESCE("TimePeriods1"."Description", '') AS "Details of Control",
COALESCE("LengthOfTime"."Description", '') AS "Max Stay",
COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description"
	FROM (((((local_authority.enfield_bays a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
	 LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime" ON a."MaxStayID" is not distinct from "LengthOfTime"."Code")
	 LEFT JOIN "mhtc_operations"."BayStatusTypes" AS "BayStatusTypes" ON a."BayStatusTypeID" is not distinct from "BayStatusTypes"."Code")
	ORDER BY "Area", "GeometryID"


-- added BayStatusTypes
ALTER TABLE ONLY local_authority."enfield_bays"
    ADD CONSTRAINT "enfield_bays_BayStatusType_fkey" FOREIGN KEY ("BayStatusTypeID") REFERENCES "mhtc_operations"."BayStatusTypes"("Code");