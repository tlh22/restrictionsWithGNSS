/***

Check lengths of road

***/

SELECT name1, SUM(ST_Length(geom)) AS "Length"
FROM highways_network."roadlink"
GROUP BY name1
ORDER BY "Length" DESC


/***
SELECT "roadName1_Name", SUM(ST_Length(geom)) AS "Length"
FROM highways_network."roadlink"
GROUP BY "roadName1_Name"
ORDER BY "Length" DESC
***/

