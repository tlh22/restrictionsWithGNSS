-- export photo details

SELECT "GeometryID", "SectionID", "SurveyID", "Photos_01", "Photos_02", "Photos_03",  "RoadName", "StartStreet", "EndStreet", "SideOfStreet"
	FROM demand."MASTER_Thursday_Merged"
	WHERE "Photos_01" IS NOT NULL OR "Photos_02" IS NOT NULL OR "Photos_03" IS NOT NULL
UNION
SELECT "GeometryID", "SectionID", "SurveyID", "Photos_01", "Photos_02", "Photos_03",  "RoadName", "StartStreet", "EndStreet", "SideOfStreet"
	FROM demand."MASTER_Saturday_Merged"
	WHERE "Photos_01" IS NOT NULL OR "Photos_02" IS NOT NULL OR "Photos_03" IS NOT NULL;

SELECT mhtc_operations.getPhotosFromTable(demand."MASTER_Saturday_Merged")


SELECT CONCAT('copy ', RiS."Photos_01", ' "../Photos_With_Details/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_01", '"')
FROM demand."Demand_Merged" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID"
--AND su."CPZ" = 'FPC'
) a
WHERE "Photos_01" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"