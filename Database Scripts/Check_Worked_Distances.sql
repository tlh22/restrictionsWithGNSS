---  Kerb distances for current day

SELECT "CreatePerson", SUM(dist)
FROM (
SELECT "CreatePerson", SUM("RestrictionLength") AS dist
FROM toms."Bays"
WHERE date_trunc('day', "CreateDateTime") = date_trunc('day', now() - interval '1 day')
GROUP BY "CreatePerson"
UNION
SELECT "CreatePerson", SUM("RestrictionLength")
FROM toms."Lines"
WHERE date_trunc('day', "CreateDateTime") =  date_trunc('day', now() - interval '1 day')
GROUP   BY "CreatePerson"
ORDER BY "CreatePerson"
	) AS s
GROUP BY "CreatePerson"
ORDER BY "CreatePerson"


SELECT "CreatePerson", MIN("CreateDateTime"), MAX("CreateDateTime"), MAX("CreateDateTime") - MIN("CreateDateTime") AS Hours
FROM toms."Signs"
WHERE date_trunc('day', "CreateDateTime") = date_trunc('day', now() - interval '1 day')
GROUP BY "CreatePerson"
ORDER BY "CreatePerson"

SELECT "LastUpdatePerson", MIN("LastUpdateDateTime"), MAX("LastUpdateDateTime"), MAX("LastUpdateDateTime") - MIN("LastUpdateDateTime") AS Hours
FROM toms."Signs"
WHERE date_trunc('day', "LastUpdateDateTime") = date_trunc('day', now() - interval '1 day')
GROUP BY "LastUpdatePerson"
ORDER BY "LastUpdatePerson"