/*
add any relevant details
Use this to create a .bat file; create the relevant destination folder and run from the source folder
*/
SELECT CONCAT('copy ', RiS."Photos_01", ' "../Photos_With_Details/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_01", '"')
FROM demand."RestrictionsInSurveys_ALL" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID") a
WHERE "Photos_01" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"

UNION

SELECT CONCAT('copy ', RiS."Photos_02", ' "../Photos_With_Details/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_02", '"')
FROM demand."RestrictionsInSurveys_ALL" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID") a
WHERE "Photos_02" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"

UNION

SELECT CONCAT('copy ', RiS."Photos_03", ' "../Photos_With_Details/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_03", '"')
FROM demand."RestrictionsInSurveys_ALL" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID") a
WHERE "Photos_03" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"