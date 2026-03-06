/***

Add mid-point easting/northing values to Restriction_Audit_Issues
 
***/

ALTER TABLE IF EXISTS mhtc_operations."20260106_RestrictionsWithOnlyConditionIssues"
    ADD COLUMN "Easting" double precision;
ALTER TABLE IF EXISTS mhtc_operations."20260106_RestrictionsWithOnlyConditionIssues"
    ADD COLUMN "Northing" double precision;

UPDATE mhtc_operations."20260106_RestrictionsWithOnlyConditionIssues"
SET "Easting" = ST_X(ST_LineInterpolatePoint(geom, 0.5))
    , "Northing" = ST_Y(ST_LineInterpolatePoint(geom, 0.5))
;


-- 

SELECT "GeometryID", ogc_fid, "Easting", "Northing"
FROM mhtc_operations."20260106_RestrictionSignSpacingIssues"

UNION

SELECT "GeometryID", ogc_fid, "Easting", "Northing"
FROM mhtc_operations."20260106_RestrictionsWithOnlyConditionIssues"

UNION

SELECT "GeometryID", ogc_fid, "Easting", "Northing"
FROM mhtc_operations."20260106_Restrictions_NonConditionIssues"

ORDER By "GeometryID"

