/***

Check lengths of road

***/

SELECT name1, SUM(ST_Length(geom))
FROM highways_network."roadlink"
GROUP BY name1

