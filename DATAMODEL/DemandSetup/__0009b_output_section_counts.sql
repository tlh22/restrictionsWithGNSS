--

SELECT "SurveyID", "SectionID",
    SUM(CASE
          WHEN "VehicleTypeID" IN (1, 7) OR "VehicleTypeID" IS NULL THEN 1
		  ELSE 0
    END) AS "NrCars",
    SUM(CASE
          WHEN "VehicleTypeID" = 2 THEN 1
    END) AS "NrLGVs",
	SUM(CASE
          WHEN "VehicleTypeID" = 3 THEN 1
    END) AS "NrMCLs",
	SUM(CASE
          WHEN "VehicleTypeID" = 4 THEN 1
    END) AS "NrOGVs",
	SUM(CASE
          WHEN "VehicleTypeID" = 5 THEN 1
    END) AS "NrBuses",
	SUM (
	CASE
          WHEN "VehicleTypeID" IN (1, 2, 7) OR "VehicleTypeID" IS NULL THEN 1 -- Car, LGV or Taxi

		  WHEN "VehicleTypeID" = 3 THEN 0.33 -- MCL
	      WHEN "VehicleTypeID" IN (4, 5) THEN 1.5 -- OGV or Bus
		  ELSE 0
    END
		) AS "Demand",
	SUM (1) AS "NrEntries"

FROM demand."VRMs_Wednesday_Zone_K"
GROUP BY "SurveyID", "SectionID"
ORDER BY "SurveyID", "SectionID"