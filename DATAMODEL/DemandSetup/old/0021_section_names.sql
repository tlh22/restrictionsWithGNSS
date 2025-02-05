-- set up names for sections

ALTER TABLE mhtc_operations."RC_Sections_merged" ADD COLUMN "SectionName" character varying(254);

/***
SELECT gid, geom, "RoadName", "Az", "StartStreet", "EndStreet", "SideOfStreet", "SurveyArea", "SectionName", n."SubID", n."SectionID", n."Road Name", n."Section Start", n."Section End", n."Section Side of Street"
	FROM mhtc_operations."RC_Sections_merged" s, mhtc_operations."SectionNames" n
	WHERE n."SubID" = s.gid
***/

WITH section_details AS (
    SELECT gid,
	"RoadName",
	UPPER(CONCAT(REPLACE("RoadName", ' ', '_'), '_', to_char(ROW_NUMBER () OVER (
                                                             PARTITION BY "RoadName"
                                                             ORDER BY "RoadName"
                                                            ), 'FM00'))) AS "SectionName"
	FROM mhtc_operations."RC_Sections_merged"
        )

UPDATE mhtc_operations."RC_Sections_merged" s
SET "SectionName" = n."SectionName"
FROM section_details n
WHERE n.gid = s.gid
;