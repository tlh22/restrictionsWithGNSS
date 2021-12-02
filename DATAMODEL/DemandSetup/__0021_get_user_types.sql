/***
 * Rules are:
 * a. Resident if seen overnight
 * b. Commuter is seen twice (AM/PM) during one day
 * c. Visitor if seen only once during a given day (and not one of the other categories)
 ***/

-- setup lookup

CREATE SEQUENCE "demand_lookups"."UserTypes_Code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "demand_lookups"."UserTypes_Code_seq" OWNER TO "postgres";

CREATE TABLE "demand_lookups"."UserTypes" (
    "Code" integer DEFAULT "nextval"('"demand_lookups"."UserTypes_Code_seq"'::"regclass") NOT NULL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."UserTypes" OWNER TO "postgres";

ALTER TABLE "demand_lookups"."UserTypes"
    ADD PRIMARY KEY ("Code");

-- Add values
INSERT INTO "demand_lookups"."UserTypes" ("Code", "Description") VALUES (1, 'Resident');
INSERT INTO "demand_lookups"."UserTypes" ("Code", "Description") VALUES (2, 'Commuter');
INSERT INTO "demand_lookups"."UserTypes" ("Code", "Description") VALUES (3, 'Visitor');

-- Add user type to the table

alter table demand."vrms_final"
    add COLUMN "UserTypeID" integer;

-- Now assign types

-- Residents
SELECT "VRM", 1
FROM demand."vrms_final"
WHERE "SurveyID" IN (311, 321);

UPDATE demand."vrms_final"
SET "UserTypeID" = 1
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."vrms_final"
    WHERE "SurveyID" IN (311, 321)
);

-- Visitors

SELECT "VRM"
FROM demand."vrms_final"
WHERE "SurveyID" NOT IN (311, 321)  -- not in overnights
AND "SurveyID" < 320  -- consider just one day
AND "UserTypeID" IS NULL  -- user type is not already set
GROUP BY "VRM"
HAVING COUNT("VRM") = 1

UNION

SELECT "VRM"
FROM demand."vrms_final"
WHERE "SurveyID" NOT IN (311, 321)
AND "SurveyID" > 320
AND "UserTypeID" IS NULL
GROUP BY "VRM"
HAVING COUNT("VRM") = 1;

UPDATE demand."vrms_final"
SET "UserTypeID" = 3
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."vrms_final"
    WHERE "SurveyID" NOT IN (311, 321)  -- not in overnights
    AND "SurveyID" < 320  -- consider just one day
    AND "UserTypeID" IS NULL  -- user type is not already set
    GROUP BY "VRM"
    HAVING COUNT("VRM") = 1

    UNION

    SELECT "VRM"
    FROM demand."vrms_final"
    WHERE "SurveyID" NOT IN (311, 321)
    AND "SurveyID" > 320
    AND "UserTypeID" IS NULL
    GROUP BY "VRM"
    HAVING COUNT("VRM") = 1
);

-- Anything left is a commuter

UPDATE demand."vrms_final"
SET "UserTypeID" = 2
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."vrms_final"
    WHERE "UserTypeID" IS NULL  -- user type is not already set
);


--- Output results

SELECT DISTINCT "VRM", "UserTypes"."Description" AS "UserType"
FROM (demand."vrms_final" AS a
     LEFT JOIN "demand_lookups"."UserTypes"  AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
ORDER BY "VRM"