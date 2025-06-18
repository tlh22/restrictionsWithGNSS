/***

break at site area and rename sections outside site area

***/

DROP TABLE IF EXISTS highways_network."roadlink2" CASCADE;

-- CREATE TABLE highways_network."roadlink2" (LIKE highways_network."roadlink" INCLUDING ALL);
CREATE TABLE highways_network."roadlink2" AS
  TABLE highways_network."roadlink";

DELETE FROM highways_network."roadlink";

--- from standard RoadLink

INSERT INTO highways_network."roadlink"(
	"endNode", "startNode", "roadNumberTOID", "roadNameTOID", fictitious, "roadClassification", "roadFunction", "formOfWay", length, length_uom, loop, "primaryRoute", "trunkRoad", "roadClassificationNumber", name1, name1_lang, name2, name2_lang, "roadStructure", "RoadFrom", "RoadTo",
	geom)
SELECT "endNode", "startNode", "roadNumberTOID", "roadNameTOID", fictitious, "roadClassification", "roadFunction", "formOfWay", length, length_uom, loop, "primaryRoute", "trunkRoad", "roadClassificationNumber", name1, name1_lang, name2, name2_lang, "roadStructure", "RoadFrom", "RoadTo",
(ST_Dump(ST_Split(r1.geom, ST_Buffer(b.geom, 0.00001)))).geom
FROM highways_network."roadlink2" r1, (
	SELECT ST_Union(geom) AS geom
	FROM (
		SELECT ST_Intersection(r2.geom,ST_ExteriorRing(s.geom)) as geom
		FROM highways_network."roadlink2" r2, local_authority."SiteArea" s
		WHERE ST_DWithin(r2.geom,ST_ExteriorRing(s.geom), 0.25)
		AND r2."name1" IS NOT NULL
		) a
	) b
WHERE ST_DWithin(r1.geom, b.geom, 0.25)
AND r1."name1" IS NOT NULL
union
SELECT "endNode", "startNode", "roadNumberTOID", "roadNameTOID", fictitious, "roadClassification", "roadFunction", "formOfWay", length, length_uom, loop, "primaryRoute", "trunkRoad", "roadClassificationNumber", name1, name1_lang, name2, name2_lang, "roadStructure", "RoadFrom", "RoadTo",
r1.geom
FROM highways_network."roadlink2" r1, (
	SELECT ST_Union(geom) AS geom
	FROM (
		SELECT ST_Intersection(r2.geom,ST_ExteriorRing(s.geom)) as geom
		FROM highways_network."roadlink2" r2, local_authority."SiteArea" s
		WHERE ST_DWithin(r2.geom,ST_ExteriorRing(s.geom), 0.25)
		AND r2."name1" IS NOT NULL
		) a
	) b
WHERE NOT ST_DWithin(r1.geom, b.geom, 0.25)
AND r1."name1" IS NOT NULL;

DELETE FROM highways_network."roadlink"
WHERE ST_Length(geom) < 0.0001;

-- Now rename sections outside the Site area that have the same name as sections inside

UPDATE highways_network."roadlink"
SET "name1" = CONCAT(' ', "name1")
WHERE id IN (
	SELECT DISTINCT r2."id"
	FROM highways_network."roadlink" r1, highways_network."roadlink" r2, local_authority."SiteArea" s
	WHERE r1."name1" = r2."name1"
	AND ST_Within(r1.geom, s.geom)
	AND NOT ST_Within(r2.geom, s.geom)
	);



--- from RAMI

INSERT INTO highways_network."roadlink"(
primaryindex, "TOID", identifier, "identifierVersionId", "beginLifespanVersion", fictitious, "validFrom", "reasonForChange", "roadClassification", "routeHierarchy", "formOfWay", "trunkRoad", "primaryRoute", "roadClassificationNumber", "roadName1_Name", "roadName2_Name", "roadName1_Language", "roadName2_Language", "operationalState", provenance, directionality, length, "matchStatus", "alternateIdentifier1", "alternateIdentifier2", "alternateIdentifier3", "alternateIdentifier4", "alternateIdentifier5", "startGradeSeparation", "endGradeSeparation", "roadStructure", "cycleFacility", "roadWidthMinimum", "roadWidthAverage", "elevationGainInDirection", "elevationGainOppositeDirection", "startNode", "endNode", "RoadFrom", "RoadTo", 
	
--	"endNode", "startNode", "roadNumberTOID", "roadNameTOID", fictitious, "roadClassification", "roadFunction", "formOfWay", length, length_uom, loop, "primaryRoute", "trunkRoad", "roadClassificationNumber", name1, name1_lang, name2, name2_lang, "roadStructure", "RoadFrom", "RoadTo",
	geom)
SELECT primaryindex, "TOID", identifier, "identifierVersionId", "beginLifespanVersion", fictitious, "validFrom", "reasonForChange", "roadClassification", "routeHierarchy", "formOfWay", "trunkRoad", "primaryRoute", "roadClassificationNumber", "roadName1_Name", "roadName2_Name", "roadName1_Language", "roadName2_Language", "operationalState", provenance, directionality, length, "matchStatus", "alternateIdentifier1", "alternateIdentifier2", "alternateIdentifier3", "alternateIdentifier4", "alternateIdentifier5", "startGradeSeparation", "endGradeSeparation", "roadStructure", "cycleFacility", "roadWidthMinimum", "roadWidthAverage", "elevationGainInDirection", "elevationGainOppositeDirection", "startNode", "endNode", "RoadFrom", "RoadTo", 
(ST_Dump(ST_Split(r1.geom, ST_Buffer(b.geom, 0.00001)))).geom
FROM highways_network."roadlink2" r1, (
	SELECT ST_Union(geom) AS geom
	FROM (
		SELECT ST_Intersection(r2.geom,ST_ExteriorRing(s.geom)) as geom
		FROM highways_network."roadlink2" r2, local_authority."SiteArea" s
		WHERE ST_DWithin(r2.geom,ST_ExteriorRing(s.geom), 0.25)
		AND r2."roadName1_Name" IS NOT NULL
		) a
	) b
WHERE ST_DWithin(r1.geom, b.geom, 0.25)
AND r1."roadName1_Name" IS NOT NULL
union
SELECT primaryindex, "TOID", identifier, "identifierVersionId", "beginLifespanVersion", fictitious, "validFrom", "reasonForChange", "roadClassification", "routeHierarchy", "formOfWay", "trunkRoad", "primaryRoute", "roadClassificationNumber", "roadName1_Name", "roadName2_Name", "roadName1_Language", "roadName2_Language", "operationalState", provenance, directionality, length, "matchStatus", "alternateIdentifier1", "alternateIdentifier2", "alternateIdentifier3", "alternateIdentifier4", "alternateIdentifier5", "startGradeSeparation", "endGradeSeparation", "roadStructure", "cycleFacility", "roadWidthMinimum", "roadWidthAverage", "elevationGainInDirection", "elevationGainOppositeDirection", "startNode", "endNode", "RoadFrom", "RoadTo", 
r1.geom
FROM highways_network."roadlink2" r1, (
	SELECT ST_Union(geom) AS geom
	FROM (
		SELECT ST_Intersection(r2.geom,ST_ExteriorRing(s.geom)) as geom
		FROM highways_network."roadlink2" r2, local_authority."SiteArea" s
		WHERE ST_DWithin(r2.geom,ST_ExteriorRing(s.geom), 0.25)
		AND r2."roadName1_Name" IS NOT NULL
		) a
	) b
WHERE NOT ST_DWithin(r1.geom, b.geom, 0.25)
AND r1."roadName1_Name" IS NOT NULL;

DELETE FROM highways_network."roadlink"
WHERE ST_Length(geom) < 0.0001;

-- Now rename sections outside the Site area that have the same name as sections inside

UPDATE highways_network."roadlink"
SET "roadName1_Name" = CONCAT(' ', "roadName1_Name")
WHERE id IN (
	SELECT DISTINCT r2."id"
	FROM highways_network."roadlink" r1, highways_network."roadlink" r2, local_authority."SiteArea" s
	WHERE r1."roadName1_Name" = r2."roadName1_Name"
	AND ST_Within(r1.geom, s.geom)
	AND NOT ST_Within(r2.geom, s.geom)
	);
