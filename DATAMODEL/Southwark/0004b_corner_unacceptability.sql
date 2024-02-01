/***
Deal with unacceptability in WaitingLoadingStoppingRestrictions
***/

DROP TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions_orig2" CASCADE;

CREATE TABLE local_authority."WaitingLoadingStoppingRestrictions_orig2"
(
    "GeometryID" integer NOT NULL,
    image character varying COLLATE pg_catalog."default",
    type character varying COLLATE pg_catalog."default",
    road_marking character varying COLLATE pg_catalog."default",
    days_of_operation character varying COLLATE pg_catalog."default",
    hours_of_operation character varying COLLATE pg_catalog."default",
    length_m double precision,
    tsrgd character varying COLLATE pg_catalog."default",
    spec character varying COLLATE pg_catalog."default",
    zone character varying COLLATE pg_catalog."default",
    street character varying COLLATE pg_catalog."default",
    featid integer,
    notes character varying COLLATE pg_catalog."default",
    photo character varying COLLATE pg_catalog."default",
    id character varying COLLATE pg_catalog."default",
    fault_rpt character varying COLLATE pg_catalog."default",
    geom geometry(LineString,27700),
    "RestrictionTypeID" integer,
    "GeometryTypeID" integer,
    "NoWaitingTimeID" integer,
	"DemandSection_GeometryID" character varying(12),
    CONSTRAINT "WaitingLoadingStoppingRestrictions_orig2_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO local_authority."WaitingLoadingStoppingRestrictions_orig2"(
	"GeometryID", image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, geom, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", "DemandSection_GeometryID")
SELECT
	"GeometryID", image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, geom, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", "DemandSection_GeometryID"
	FROM local_authority."WaitingLoadingStoppingRestrictions";

-- process 

DELETE FROM local_authority."WaitingLoadingStoppingRestrictions";

INSERT INTO local_authority."WaitingLoadingStoppingRestrictions" (
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", "DemandSection_GeometryID",
       geom)
SELECT
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", "DemandSection_GeometryID",    (ST_Dump(ST_Split(lg1.geom, mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25)))).geom
    FROM local_authority."WaitingLoadingStoppingRestrictions_orig2" lg1 LEFT JOIN LATERAL mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25) pt ON TRUE
	WHERE lg1."RestrictionTypeID" in (201, 216, 217, 224, 225, 226, 227, 229)

UNION

	SELECT
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", "DemandSection_GeometryID",
    geom
	FROM local_authority."WaitingLoadingStoppingRestrictions_orig2" lg1
    WHERE mhtc_operations."cnrBufferExtent"(lg1.geom, 0.25) IS NULL
    AND lg1."RestrictionTypeID" in (201, 216, 217, 224, 225, 226, 227, 229)

UNION

	SELECT
	image, type, road_marking, days_of_operation, hours_of_operation, length_m, tsrgd, spec, zone, street, featid, notes, photo, id, fault_rpt, "RestrictionTypeID", "GeometryTypeID", "NoWaitingTimeID", "DemandSection_GeometryID",
    geom
	FROM local_authority."WaitingLoadingStoppingRestrictions_orig2" lg1
    WHERE lg1."RestrictionTypeID" NOT IN (201, 216, 217, 224, 225, 226, 227, 229);


-- new field

ALTER TABLE IF EXISTS local_authority."WaitingLoadingStoppingRestrictions"
    ADD COLUMN IF NOT EXISTS "UnacceptableTypeID" integer;

--SYLs
UPDATE local_authority."WaitingLoadingStoppingRestrictions" AS s
SET "RestrictionTypeID" = 220, "UnacceptableTypeID" = 6
FROM mhtc_operations."CornerProtectionSections_Single" c
WHERE ST_Within(s.geom, (ST_BUFFER(c.geom, 1.0, 'endcap=round')))
AND s."RestrictionTypeID" IN (201, 224);


