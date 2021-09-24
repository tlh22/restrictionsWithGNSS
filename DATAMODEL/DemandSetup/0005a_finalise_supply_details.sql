
/**
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "Capacity" integer;
**/

DROP TRIGGER IF EXISTS "update_capacity_supply" ON "mhtc_operations"."Supply";
CREATE TRIGGER "update_capacity_supply" BEFORE INSERT OR UPDATE OF geom, "RestrictionLength", "NrBays" ON "mhtc_operations"."Supply" FOR EACH ROW EXECUTE FUNCTION "public"."update_capacity"();

UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

-- set road details

UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply" s, mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

-- Reset all road names, etc

/*
UPDATE mhtc_operations."Supply" su
SET "RoadName" = s."RoadName",
"StartStreet" = s."StartStreet",
"EndStreet" = s."EndStreet",
"SideOfStreet" = s."SideOfStreet"
FROM mhtc_operations."RC_Sections_merged" s
WHERE su."SectionID" = s.gid;
*/

/**
Deal with default values for time periods
**/

UPDATE "mhtc_operations"."Supply"
SET "NoWaitingTimeID" = 1  -- At any time
WHERE "RestrictionTypeID" >=202 AND "RestrictionTypeID" <=215  -- Lines
AND "NoWaitingTimeID" IS NULL;

UPDATE "mhtc_operations"."Supply"
SET "TimePeriodID" = 1  -- At any time
WHERE "RestrictionTypeID" IN (107, 110, 111, 112, 116, 117, 118, 119, 120, 122, 127, 130, 144, 145, 146, 147, 149, 150, 152, 161, 162, 165, 166, 167)  -- Bays
AND "TimePeriodID" IS NULL;


/**
Assign CPZ??

UPDATE mhtc_operations."Supply" s
SET "CPZ" = r."AreaPermitCode"
FROM toms."RestrictionPolygons" r
WHERE ST_Within(s.geom, r.geom)
AND r."AreaPermitCode" = 'NA'

**/


