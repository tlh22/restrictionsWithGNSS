/*** 

Tidy

***/

-- Delete any records that have an overlap and for which the GeometryID is null. This means that it has been replaced.

DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
WHERE "gid" IN (
SELECT s1."gid"
FROM mhtc_operations."Restrictions_Audit_Issues" s1, mhtc_operations."Restrictions_Audit_Issues" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."gid" < s2."gid"
AND s1."GeometryID" != s2."GeometryID"
AND LENGTH(s1."GeometryID") = 0 AND LENGTH(s2."GeometryID") > 0
);

DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
WHERE "gid" IN (
SELECT s2."gid"
FROM mhtc_operations."Restrictions_Audit_Issues" s1, mhtc_operations."Restrictions_Audit_Issues" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."gid" < s2."gid"
AND s1."GeometryID" != s2."GeometryID"
AND LENGTH(s2."GeometryID") = 0 AND LENGTH(s1."GeometryID") > 0
);

-- Now concat all the reasons for the same GeometryID and remove duplicates
/***
UPDATE mhtc_operations."Restrictions_Audit_Issues" AS a
SET "Reason" = z."Reason"
FROM (
	SELECT s1."GeometryID"
	, string_agg(s1."Reason", '; ') AS "Reason"
	FROM mhtc_operations."Restrictions_Audit_Issues" s1
	WHERE LENGTH(s1."GeometryID") > 0
	GROUP BY s1."GeometryID"
	HAVING COUNT(*) > 1
   ) AS z
WHERE  a."GeometryID" = z."GeometryID";

DELETE FROM mhtc_operations."Restrictions_Audit_Issues" i1
USING mhtc_operations."Restrictions_Audit_Issues" i2
WHERE LENGTH(s1."GeometryID") > 0
AND s1."GeometryID" = s2."GeometryID"
AND s1.gid > s2.gid
***/

DO $$
DECLARE
	duplicate_restriction RECORD;
	i_count integer = 0;
	
BEGIN

    FOR duplicate_restriction IN
		SELECT i1."GeometryID", i1.gid AS "gid1", i1."Reason" AS "Reason1", i2.gid AS "gid2", i2."Reason" AS "Reason2"
		FROM mhtc_operations."Restrictions_Audit_Issues" i1, mhtc_operations."Restrictions_Audit_Issues" i2
		WHERE LENGTH(i1."GeometryID") > 0
		AND i1."GeometryID" = i2."GeometryID"
		AND i1.gid < i2.gid
		ORDER BY i1.gid ASC

	LOOP

		RAISE NOTICE 'GeometryID: %', duplicate_restriction."GeometryID";
		i_count = i_count + 1;
		
		IF duplicate_restriction."Reason1" IN ('Restriction Type', 'Time Period', 'Nr Bays', 'No Return', 'Length', 'Restriction Shape', 'Unknown') THEN 
		   
			UPDATE mhtc_operations."Restrictions_Audit_Issues" AS a
			SET "Reason" = CONCAT (duplicate_restriction."Reason1", '; ', duplicate_restriction."Reason2")
			WHERE a.gid = duplicate_restriction.gid1;
			
			DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
			WHERE gid = duplicate_restriction.gid2;

		ELSE

			UPDATE mhtc_operations."Restrictions_Audit_Issues" AS a
			SET "Reason" = CONCAT (duplicate_restriction."Reason1", '; ', duplicate_restriction."Reason2")
			WHERE a.gid = duplicate_restriction.gid2;
			
			DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
			WHERE gid = duplicate_restriction.gid1;
			
			RAISE NOTICE 'Reason2 ***';
			
		END IF;
		
    END LOOP;
	
	RAISE NOTICE 'i_count: %', i_count;

END; $$;


-- Remove "NrBays" as this is not significant

DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
WHERE "Reason" = 'Nr Bays';

-- Check for perpendicular bays that are close to bays of te same type

DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
WHERE gid IN (
	SELECT gid  --, "RestrictionDescription_orig", "RestrictionDescription"
	FROM (  SELECT gid, "RestrictionDescription_orig", geom
			FROM mhtc_operations."Restrictions_Audit_Issues"
			WHERE LENGTH("GeometryID") = 0
			AND "Reason" = 'Removed'
			) p
	, (SELECT r.geom,  "BayLineTypes"."Description" AS "RestrictionDescription"
		FROM toms."Bays" r
			LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
			WHERE "GeomShapeID" IN (4, 5, 6, 9, 24, 25, 26, 29) ) s

	WHERE ST_INTERSECTS(ST_LineSubstring (p.geom, 0.1, 0.9), ST_Buffer(s.geom, 1.0, 'endcap=flat'))
	AND s."RestrictionDescription" = p."RestrictionDescription_orig"
);

-- Check for bays that have been removed and and within a bay of the same type. remove these as well

DELETE FROM mhtc_operations."Restrictions_Audit_Issues"
WHERE gid IN (
SELECT gid --, "RestrictionDescription_orig", "RestrictionDescription"
FROM (  SELECT gid, "RestrictionDescription_orig", geom
		FROM mhtc_operations."Restrictions_Audit_Issues"
		WHERE LENGTH("GeometryID") = 0
		AND "Reason" = 'Removed'
		) p
, (SELECT r.geom,  "BayLineTypes"."Description" AS "RestrictionDescription"
	FROM toms."Bays" r
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON r."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") s

WHERE ST_INTERSECTS(ST_LineSubstring (p.geom, 0.1, 0.9), ST_Buffer(s.geom, 0.1, 'endcap=flat'))
AND s."RestrictionDescription" = p."RestrictionDescription_orig"
);


/***

SELECT "Reason", COUNT(*)
FROM mhtc_operations."Restrictions_Audit_Issues"
GROUP BY "Reason"


SELECT s1."GeometryID", s1.gid, s2."gid"
FROM mhtc_operations."Restrictions_Audit_Issues" s1, mhtc_operations."Restrictions_Audit_Issues" s2
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."gid" < s2."gid"
AND s1."GeometryID" != s2."GeometryID"
ORDER BY "GeometryID"

***/

/***

Need to also do some checks:
 - Bays without signs
 
 
 ***/
 