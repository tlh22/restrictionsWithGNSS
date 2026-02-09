/***

Output any supply issues

***/

-- need to remove "," from fields

SELECT RiS.gid, RiS."SurveyID", RiS."GeometryID", "DemandSurveyDateTime", "Enumerator",  "SuspensionNotes", c."Notes"
 "Supply_Notes", "MCL_Notes"
	FROM demand."RestrictionsInSurveys" RiS, demand."Counts" c
WHERE RiS."SurveyID" = c."SurveyID"
AND RiS."GeometryID" = c."GeometryID"
AND (LENGTH("SuspensionNotes") > 0
OR LENGTH("Notes") > 0)
	