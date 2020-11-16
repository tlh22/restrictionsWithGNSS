--

SELECT "ID", v."SurveyID" AS "SurveyID", "SurveyDay", "BeatTitle" AS "SurveyTimePeriod", "SectionID", "GeometryID", "PositionID",
       "VRM", "VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionType Description", "Notes"
FROM ((("demand"."VRMs_Saturday_Zone_J" v
     LEFT JOIN "demand"."Surveys" AS "Surveys" ON v."SurveyID" = "Surveys"."SurveyID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON v."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON v."VehicleTypeID" is not distinct from "VehicleTypes"."Code")

-- WHERE "VRM" <> '-'
--AND "VRM" <> '_'
--AND "VRM" <> ''
--AND "VRM" IS NOT NULL

ORDER BY "VRM", "SurveyID"


