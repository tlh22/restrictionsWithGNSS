--

-- deal with unacceptability

DROP TABLE IF EXISTS mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" CASCADE;

CREATE TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" AS 
TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";


ALTER TABLE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" ADD PRIMARY KEY ("GeometryID");

CREATE INDEX "sidx_Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2_geom"
    ON mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" USING gist
    (geom)
    TABLESPACE pg_default;
	
--- populate
/***
INSERT INTO mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2"(
	--"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr","OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet")
SELECT
    --"RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr","OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet"
	FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";
***/
--
CREATE OR REPLACE FUNCTION mhtc_operations."cnrBufferExtent"(geometry, real) RETURNS geometry AS
'SELECT ST_Collect(ST_ExteriorRing(ST_Buffer(c.geom, $2, ''endcap=flat''))) AS geom
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Intersects($1, ST_Buffer(c.geom, $2, ''endcap=flat''))'
LANGUAGE SQL;

DELETE FROM mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3";

INSERT INTO "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3" (
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
       geom)
SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
    (ST_Dump(ST_Split(lg1.geom, mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25)))).geom
    FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" lg1 LEFT JOIN LATERAL mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25) pt ON TRUE
	WHERE lg1."RestrictionTypeID" in (201, 216, 217, 224, 225, 226, 227, 229)

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr","OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID",  "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
    geom
	FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" lg1
    WHERE mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25) IS NULL
    AND lg1."RestrictionTypeID" in (201, 216, 217, 224, 225, 226, 227, 229)

UNION

	SELECT
	--"RestrictionID", "GeometryID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "Capacity", "BayWidth",
    "SectionID", "StartStreet", "EndStreet", "SideOfStreet", ogc_fid,
    geom
	FROM "mhtc_operations"."Supply_tmp_L_M_N_O_P_Q_S2_S3_orig2" lg1
    WHERE lg1."RestrictionTypeID" NOT IN (201, 216, 217, 224, 225, 226, 227, 229);

-- deal with acceptablity around corners

-- Unmarked
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (216, 225);

-- SYLs 
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 221, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (201, 224);

-- SRLs
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 222, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (217, 226);

-- Unmarked within PPZ
UPDATE mhtc_operations."Supply_tmp_L_M_N_O_P_Q_S2_S3" AS s
SET "RestrictionTypeID" = 228, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (227, 229);

--


CREATE OR REPLACE FUNCTION line_length_at_corner(IN cornerID int) RETURNS float AS
$BODY$
DECLARE
    len_DYL float;
    len_Bays float;
    len_relevant_line float;
BEGIN

        len_DYL = 0;
        len_Bays = 0;
        len_relevant_line = 0;

        RAISE NOTICE '**** CornerID: %', cornerID;

        SELECT COALESCE(SUM(ST_Length(ST_Intersection(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1)))), 0) INTO len_DYL
        FROM mhtc_operations."CornerSegments" c, "toms"."Lines" l
        WHERE c."id" = cornerID
        AND ST_Intersects(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1))
        AND l."RestrictionTypeID" NOT IN (201, 221, 224, 216, 220);

        --RAISE NOTICE 'DYL: %', len_DYL;

        SELECT COALESCE(SUM(ST_Length(ST_Intersection(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1)))), 0) INTO len_Bays
        FROM mhtc_operations."CornerSegments" c, "toms"."Bays" l
		WHERE c."id" = cornerID
        AND ST_Intersects(l.geom, ST_Buffer(ST_SetSRID(c.geom, 27700), 0.1));

        --RAISE NOTICE 'Bays: %', len_Bays;

        len_relevant_line = len_DYL + len_Bays;

        RAISE NOTICE 'len_relevant_line: %', len_relevant_line;

        RETURN len_relevant_line;

END
$BODY$
LANGUAGE plpgsql;

DROP TABLE IF EXISTS mhtc_operations."LineLengthAtCorner";

CREATE TABLE mhtc_operations."LineLengthAtCorner"
(
	"id" integer,
	"LineLength" double precision
);

WITH corners AS (
SELECT "id" FROM mhtc_operations."Corners" c)
    INSERT INTO mhtc_operations."LineLengthAtCorner" (id, "LineLength")
    SELECT corners.id, line_length_at_corner(corners.id)
	FROM corners;

 ALTER TABLE ONLY mhtc_operations."LineLengthAtCorner"
    ADD CONSTRAINT "LineLengthAtCorner_pkey" PRIMARY KEY ("id");

SELECT id, "LineLength"
	FROM mhtc_operations."LineLengthAtCorner"
	WHERE "LineLength" < 19.0;

SELECT "LineLength"::int AS grouping, COUNT(id) AS nrCorners
FROM  mhtc_operations."LineLengthAtCorner"
GROUP BY  grouping
ORDER  BY grouping DESC;

GRANT ALL ON TABLE mhtc_operations."LineLengthAtCorner" TO postgres;
GRANT ALL ON TABLE mhtc_operations."LineLengthAtCorner" TO toms_admin, toms_operator;
GRANT SELECT ON TABLE mhtc_operations."LineLengthAtCorner" TO toms_public;


--

-- classify corners according to the amount of line


ALTER TABLE mhtc_operations."LineLengthAtCorner"
    ADD COLUMN "CornerProtectionCategoryTypeID" integer;

DROP TABLE IF EXISTS "mhtc_operations"."CornerProtectionCategoryTypes";

CREATE TABLE "mhtc_operations"."CornerProtectionCategoryTypes" (
    "Code" integer NOT NULL,
    "Description" character varying
);

CREATE SEQUENCE "mhtc_operations"."CornerProtectionCategoryType_Code_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "mhtc_operations"."CornerProtectionCategoryType_Code_seq" OWNER TO "postgres";

ALTER SEQUENCE "mhtc_operations"."CornerProtectionCategoryType_Code_seq" OWNED BY "mhtc_operations"."CornerProtectionCategoryTypes"."Code";

ALTER TABLE ONLY "mhtc_operations"."CornerProtectionCategoryTypes" ALTER COLUMN "Code" SET DEFAULT "nextval"('"mhtc_operations"."CornerProtectionCategoryType_Code_seq"'::"regclass");

ALTER TABLE ONLY "mhtc_operations"."CornerProtectionCategoryTypes"
    ADD CONSTRAINT "CornerProtectionCategoryType_pkey" PRIMARY KEY ("Code");

ALTER TABLE ONLY mhtc_operations."LineLengthAtCorner"
    ADD CONSTRAINT "LineLengthAtCorner_CornerProtectionCategoryTypeID_fkey" FOREIGN KEY ("CornerProtectionCategoryTypeID") REFERENCES "mhtc_operations"."CornerProtectionCategoryTypes"("Code");

-- add values

INSERT INTO "mhtc_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (1, 'No suitable markings');
INSERT INTO "mhtc_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (2, 'Some suitable markings');
INSERT INTO "mhtc_operations"."CornerProtectionCategoryTypes" ("Code", "Description") VALUES (3, 'In compliance');

-- update

UPDATE mhtc_operations."LineLengthAtCorner"
    SET "CornerProtectionCategoryTypeID" = 1
    WHERE "LineLength" = 0.0;

UPDATE mhtc_operations."LineLengthAtCorner"
    SET "CornerProtectionCategoryTypeID" = 2
    WHERE "LineLength" > 0.0 and "LineLength" < 16.0;

UPDATE mhtc_operations."LineLengthAtCorner"
    SET "CornerProtectionCategoryTypeID" = 3
    WHERE "LineLength" >= 16.0;

-- group by ward

/*
select w."NAME", p."CornerProtectionCategoryTypeID",  count(*) as Totals
   from
      (SELECT c.geom, l."CornerProtectionCategoryTypeID"
	   FROM mhtc_operations."Corners" c, mhtc_operations."LineLengthAtCorner" l
	   WHERE c.id = l.id) p, local_authority."Wards" w
   WHERE ST_Within (p.geom, w.geom)
   group by w."NAME", p."CornerProtectionCategoryTypeID"
*/