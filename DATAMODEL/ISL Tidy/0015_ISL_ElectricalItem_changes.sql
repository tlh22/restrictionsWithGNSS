/*
Details of changes to the Electrical items data set ...
*/

SELECT DISTINCT ON ("GeometryID"), "ReasonForChange", "Unit_Reference", "Type_Description", "Notes"
FROM (
SELECT "GeometryID", 'New item' AS "ReasonForChange", "Unit_Reference", "Type_Description", "Notes"
FROM local_authority."ISL_Electrical_Items"
WHERE "Unit_Reference" IS NULL

UNION

SELECT "GeometryID", 'Comment' AS "ReasonForChange", "Unit_Reference", "Type_Description", "Notes"
FROM local_authority."ISL_Electrical_Items"
WHERE "Notes" IS NOT NULL

UNION

SELECT e."GeometryID", 'Moved' AS "ReasonForChange", e."Unit_Reference", e."Type_Description", e."Notes"
FROM local_authority."ISL_Electrical_Items" e, local_authority."ISL_Electrical_Items_orig" o
WHERE e."Unit_Reference" = o."Unit_Reference"
AND NOT ST_Within(e.geom, ST_Buffer(o.geom, 1.0))
) As a
--ORDER BY "Type_Description", "GeometryID"




SELECT DISTINCT ON ("GeometryID") "GeometryID", "ReasonForChange", "Unit_Reference", "Type_Description", "Notes"
FROM (
    SELECT "GeometryID", 'New item' AS "ReasonForChange", "Unit_Reference", "Type_Description", "Notes"
    FROM local_authority."ISL_Electrical_Items"
    WHERE "Unit_Reference" IS NULL

    UNION

    SELECT e."GeometryID", 'Moved' AS "ReasonForChange", e."Unit_Reference", e."Type_Description", e."Notes"
    FROM local_authority."ISL_Electrical_Items" e, local_authority."ISL_Electrical_Items_orig" o
    WHERE e."Unit_Reference" = o."Unit_Reference"
    AND NOT ST_Within(e.geom, ST_Buffer(o.geom, 1.0))
) As a

UNION

SELECT "GeometryID", 'Comment' AS "ReasonForChange", "Unit_Reference", "Type_Description", "Notes"
FROM local_authority."ISL_Electrical_Items"
WHERE "Notes" IS NOT NULL
AND "GeometryID" NOT IN (
    SELECT "GeometryID"
    FROM local_authority."ISL_Electrical_Items"
    WHERE "Unit_Reference" IS NULL

    UNION

    SELECT e."GeometryID"
    FROM local_authority."ISL_Electrical_Items" e, local_authority."ISL_Electrical_Items_orig" o
    WHERE e."Unit_Reference" = o."Unit_Reference"
    AND NOT ST_Within(e.geom, ST_Buffer(o.geom, 1.0))
)
