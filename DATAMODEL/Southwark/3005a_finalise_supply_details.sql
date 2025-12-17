
UPDATE "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "NoWaitingTimeID" = 1  -- At any time
WHERE "RestrictionTypeID" >=202 AND "RestrictionTypeID" <=215  -- Lines
AND "NoWaitingTimeID" IS NULL;

UPDATE "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "TimePeriodID" = 1  -- At any time
WHERE "RestrictionTypeID" IN (107, 110, 111, 112, 116, 117, 118, 119, 120, 122, 127, 130, 144, 145, 146, 147, 149, 150, 152, 161, 162, 165, 166, 167)  -- Bays
AND "TimePeriodID" IS NULL;


--SYLs
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 201
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 221
WHERE "RestrictionTypeID" = 224
AND "UnacceptableTypeID" IS NOT NULL;

-- SRLs
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 217
WHERE "RestrictionTypeID" = 226
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 222
WHERE "RestrictionTypeID" = 226
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 216
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 220
WHERE "RestrictionTypeID" = 225
AND "UnacceptableTypeID" IS NOT NULL;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 227
WHERE "RestrictionTypeID" = 229
AND "UnacceptableTypeID" IS NULL;

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 228
WHERE "RestrictionTypeID" = 229
AND "UnacceptableTypeID" IS NOT NULL;

--

/**
Consider "short" line areas
**/

/*
SELECT "GeometryID", "RestrictionTypeID", "RestrictionLength", "Capacity"
FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
WHERE "RestrictionTypeID" = 216
AND "RestrictionLength" < 5.0
ORDER BY "RestrictionLength"
*/

-- Unmarked
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (216, 225)
AND "Capacity" = 0;

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (227, 229)
AND "Capacity" = 0;

-- SYLs
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (201, 224)
AND "Capacity" = 0;

-- SRLs
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3"
SET "RestrictionTypeID" = 222, "UnacceptableTypeID" = 10
WHERE "RestrictionTypeID" IN (217, 226)
AND "Capacity" = 0;

/**
Deal with unmarked areas within PPZ
**/

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 227
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 216  -- Unmarked (Acceptable)
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 228
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 220   -- Unmarked (Unacceptable)
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 229
FROM toms."RestrictionPolygons" p
WHERE s."RestrictionTypeID" = 225   -- Unmarked
AND p."RestrictionTypeID" IN ( 2, 3, 4, 9, 10, 11 )
AND ST_Within(s.geom, p.geom);

