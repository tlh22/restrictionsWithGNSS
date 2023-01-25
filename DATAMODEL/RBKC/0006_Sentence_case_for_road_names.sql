/***
 For Road Names that are in capitals ...

***/

UPDATE mhtc_operations."Supply"
SET "RoadName" = INITCAP("RoadName")
WHERE UPPER("RoadName") = "RoadName";


SELECT "RoadName"
FROM mhtc_operations."Supply"
WHERE upper("RoadName") = "RoadName";