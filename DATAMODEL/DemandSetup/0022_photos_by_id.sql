-- export photo details

SELECT "GeometryID", "SectionID", "SurveyID", "Photos_01", "Photos_02", "Photos_03",  "RoadName", "StartStreet", "EndStreet", "SideOfStreet"
	FROM demand."MASTER_Thursday_Merged"
	WHERE "Photos_01" IS NOT NULL OR "Photos_02" IS NOT NULL OR "Photos_03" IS NOT NULL
UNION
SELECT "GeometryID", "SectionID", "SurveyID", "Photos_01", "Photos_02", "Photos_03",  "RoadName", "StartStreet", "EndStreet", "SideOfStreet"
	FROM demand."MASTER_Saturday_Merged"
	WHERE "Photos_01" IS NOT NULL OR "Photos_02" IS NOT NULL OR "Photos_03" IS NOT NULL;

 SELECT mhtc_operations.getPhotosFromTable(demand."MASTER_Saturday_Merged")