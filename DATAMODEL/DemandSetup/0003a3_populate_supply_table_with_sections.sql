-- Using sections

CREATE TRIGGER "create_geometryid_supply" BEFORE INSERT ON mhtc_operations."Supply" FOR EACH ROW EXECUTE FUNCTION "public"."create_supply_geometryid"();

INSERT INTO mhtc_operations."Supply"(
	--"RestrictionID",
	geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Photos_01", "Photos_02", "Photos_03", "RoadName")
SELECT
    --"RestrictionID",
    geom, 1000, 10, "Az", "Photos_01", "Photos_02", "Photos_03", "RoadName"
	FROM mhtc_operations."RC_Sections_merged";


UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."USRN"
      FROM mhtc_operations."Supply" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
;

-- Need to remove distance from corners ?? not sure how to continuously do this ??

UPDATE "mhtc_operations"."Supply" AS s
SET "RestrictionLength" = "RestrictionLength" - 5.0
FROM mhtc_operations."Corners" c
WHERE ST_DWithin(ST_StartPoint (s.geom), c.geom, 0.01);

UPDATE "mhtc_operations"."Supply" AS s
SET "RestrictionLength" = "RestrictionLength" - 5.0
FROM mhtc_operations."Corners" c
WHERE ST_DWithin(ST_EndPoint (s.geom), c.geom, 0.01);