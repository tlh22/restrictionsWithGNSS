/***

Find any records that have MaxStayID of 5 (4 hrs) when imported is 11 (40 mins)

***/

-- Update Time Periods Transfer

SELECT operating_hours
FROM import_geojson."TimePeriods_Transfer"
WHERE operating_hours LIKE '%MaxStay: 40m%'
AND "MaxStayID" = 5

-- Update ImportedBays

-- Find Bays

SELECT s."GeometryID", s."RestrictionTypeID", i."Operating_hours", s.geom
FROM toms."Bays" s, import_geojson."Imported_Bays" i, import_geojson."TimePeriods_Transfer" l
WHERE s.ogc_fid = i.ogc_fid
AND i."Operating_hours" = l.operating_hours
AND s."MaxStayID" = 5
AND l."MaxStayID" = 11




