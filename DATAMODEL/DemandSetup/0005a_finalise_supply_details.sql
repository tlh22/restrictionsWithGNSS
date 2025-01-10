
/**
ALTER TABLE mhtc_operations."Supply"
  ADD COLUMN "Capacity" integer;
**/

DROP TRIGGER IF EXISTS "update_capacity_supply" ON "mhtc_operations"."Supply";
CREATE TRIGGER "update_capacity_supply" BEFORE INSERT OR UPDATE OF geom, "RestrictionTypeID", "RestrictionLength", "NrBays" ON "mhtc_operations"."Supply" FOR EACH ROW EXECUTE FUNCTION "public"."update_capacity"();

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
	  AND LENGTH(c1."RoadName") > 0
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

UPDATE mhtc_operations."Supply" s
SET "CPZ" = c."CPZ"
FROM toms."ControlledParkingZones" c
WHERE ST_Within(s.geom, c.geom);

**/

-- 

/**
Use UnacceptableTypeID to show differences
**/

/**
--SYLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 225
WHERE "RestrictionTypeID" in (216, 220);

--SRLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 226
WHERE "RestrictionTypeID" in (217, 222);

--Unmarked
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 224
WHERE "RestrictionTypeID" in (201, 221);
**/

-- or the other way

--SYLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 201
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NOT NULL;

-- SRLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 217
WHERE "RestrictionTypeID" = 226
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 222
WHERE "RestrictionTypeID" = 226
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 216
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 227
WHERE "RestrictionTypeID" = 229
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 228
WHERE "RestrictionTypeID" = 229
AND "UnacceptableTypeID" IS NOT NULL;

--

/**
Consider "short" line areas
**/

/*
SELECT "GeometryID", "RestrictionTypeID", "RestrictionLength", "Capacity"
FROM mhtc_operations."Supply"
WHERE "RestrictionTypeID" = 216
AND "RestrictionLength" < 5.0
ORDER BY "RestrictionLength"
*/

-- Unmarked
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (216, 225)
AND "Capacity" = 0;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (227, 229)
AND "Capacity" = 0;

-- SYLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (201, 224)
AND "Capacity" = 0;

-- SRLs
UPDATE mhtc_operations."Supply"
SET "RestrictionTypeID" = 222, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (217, 226)
AND "Capacity" = 0;

/**
Deal with unmarked areas within PPZ
**/

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 227
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 216  -- Unmarked (Acceptable)
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 228
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 220   -- Unmarked (Unacceptable)
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 229
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 225   -- Unmarked
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

/***
 * ensure last update details are set
 ***/

DROP TRIGGER IF EXISTS "set_last_update_details_supply" ON "mhtc_operations"."Supply";

CREATE TRIGGER "set_last_update_details_supply"
    BEFORE INSERT OR UPDATE OF "GeometryID", geom, "RestrictionTypeID", "GeomShapeID", "Notes", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "AdditionalConditionID", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "BayWidth"
    ON mhtc_operations."Supply"
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_last_update_details();
