/*
To copy photos from folder tree

SET DATA_FOLDER=%1
SET PHOTOS_FOLDER=%2
echo %DATA_FOLDER% %PHOTOS_FOLDER%
@echo off
cd /d %DATA_FOLDER%
call :treeProcess
goto :eof

:treeProcess
for %%f in (*.png *.jpg) do (
    REM echo %%f %PHOTOS_FOLDER%
    COPY /Y %%f %PHOTOS_FOLDER%
)
for /D %%d in (*) do (
    cd /d %%d
    REM echo -- %%d
    call :treeProcess
    cd ..
)

for Haringey we used:

copy_photos_from_demand "Z:\Tim\PC20-28 Haringey (9 CPZs)\Demand - EoD" "Z:\Tim\PC20-28 Haringey (9 CPZs)\Mapping\Photos"

add any relevant details
Use this to create a .bat file; create the relevant destination folder and run from the source folder

*/

-- Set RoadName within "Signs"

UPDATE toms."Signs" AS c
SET "RoadName" = closest."RoadName"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id,
        ST_ClosestPoint(c1.geom, s.geom) AS geom,
        ST_Distance(c1.geom, s.geom) AS length, c1."name1" AS "RoadName"
      FROM toms."Signs" s, highways_network."roadlink" c1
      WHERE ST_DWithin(c1.geom, s.geom, 10.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

-- Add simple id for display
ALTER TABLE IF EXISTS "toms"."Signs"
  ADD COLUMN IF NOT EXISTS "SignRef" integer;

UPDATE toms."Signs" AS c
SET "SignRef" = sid
FROM
(
SELECT row_number() OVER (PARTITION BY true::boolean) AS sid,
	b."GeometryID", b."RoadName", b."Photo"
FROM
(
SELECT su."GeometryID", su."RoadName", su."Photos_01" AS "Photo"
FROM toms."Signs" su
WHERE su."SignType_1" = 9999
AND su."Photos_01" IS NOT NULL

/**
UNION

SELECT su."GeometryID", su."RoadName", su."Photos_02" AS "Photo"
FROM toms."Signs" su
WHERE su."SignType_2" = 9999
AND su."Photos_02" IS NOT NULL

UNION

SELECT su."GeometryID", su."RoadName", su."Photos_03" AS "Photo"
FROM toms."Signs" su
WHERE su."SignType_3" = 9999
AND su."Photos_03" IS NOT NULL
**/
ORDER BY "Photo"
) b
	) g
WHERE c."GeometryID" = g."GeometryID";

-- Set up copy script
-- https://stackoverflow.com/questions/10768924/match-sequence-using-regex-after-a-specified-character

SELECT CONCAT('copy ', g."Photo", ' "', '../Street_Scene_Photos/', "RoadName", '_Photo_', to_char(g."sid", 'fm000'), '.', ext, '"')
FROM
(
SELECT row_number() OVER (PARTITION BY true::boolean) AS sid,
	b."RoadName", b."Photo", substring(b."Photo", '(?<=\.)[^\]]+') AS ext
FROM
(
SELECT su."RoadName", su."Photos_01" AS "Photo"
FROM toms."Signs" su
WHERE su."SignType_1" = 9999
AND su."Photos_01" IS NOT NULL

/**
UNION

SELECT su."RoadName", su."Photos_02" AS "Photo"
FROM toms."Signs" su
WHERE su."SignType_2" = 9999
AND su."Photos_02" IS NOT NULL

UNION

SELECT su."RoadName", su."Photos_03" AS "Photo"
FROM toms."Signs" su
WHERE su."SignType_3" = 9999
AND su."Photos_03" IS NOT NULL
**/
ORDER BY "Photo"

) b
) g

