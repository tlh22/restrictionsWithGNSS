-- export photo details

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

UNION

SELECT CONCAT('copy ', RiS."Photos_02", ' "../Photos_With_Details/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_02", '"')
FROM demand."Demand_Merged" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID"
--AND su."CPZ" = 'FPC'
) a
WHERE "Photos_02" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"
--AND s."SurveyID" in ( SELECT "SurveyID" FROM demand."Surveys" WHERE "SiteArea" LIKE 'FP%')

UNION

SELECT CONCAT('copy ', RiS."Photos_03", ' "../Photos_With_Details/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_03", '"')
FROM demand."Demand_Merged" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID"
--AND su."CPZ" = 'FPC'
) a
WHERE "Photos_03" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"
--AND s."SurveyID" in ( SELECT "SurveyID" FROM demand."Surveys" WHERE "SiteArea" LIKE 'FP%')