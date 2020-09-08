---  Kerb distances for current day

SELECT "LastUpdatePerson", SUM(dist)
FROM (
SELECT "LastUpdatePerson", SUM("RestrictionLength") AS dist
FROM toms."Bays"
WHERE date_trunc('day', "LastUpdateDateTime") = date_trunc('day', now())
GROUP BY "LastUpdatePerson"
UNION
SELECT "LastUpdatePerson", SUM("RestrictionLength")
FROM toms."Lines"
WHERE date_trunc('day', "LastUpdateDateTime") =  date_trunc('day', now())
GROUP   BY "LastUpdatePerson"
ORDER BY "LastUpdatePerson"
	) AS s
GROUP BY "LastUpdatePerson"
ORDER BY "LastUpdatePerson"