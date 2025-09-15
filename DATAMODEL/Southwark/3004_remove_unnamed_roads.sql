-- Remove any roads without names

DELETE FROM highways_network."roadlink"
WHERE "name1" IS NULL
OR LENGTH("name1") = 0;

