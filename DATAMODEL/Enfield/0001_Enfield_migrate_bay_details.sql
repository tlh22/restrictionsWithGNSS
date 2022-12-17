/***
 * For P&D monitoring ...

 Currently have P&D bays as polygons

***/

-- Migrate Bays geometry type to polygon

-- need to remove relevant triggers

ALTER TABLE toms."Bays"
ALTER COLUMN geom type geometry(Polygon, 27700)
--USING ST_TRANSFORM(geom, 27700);

-- Amend structure / Add extra field(s)
ALTER TABLE IF EXISTS toms."Bays"
    ADD COLUMN "Location" character varying(250);

ALTER TABLE toms."Bays"
    ALTER COLUMN "Notes" TYPE character varying(10000) COLLATE pg_catalog."default";

ALTER TABLE IF EXISTS toms."Bays"
    ALTER COLUMN "RestrictionLength" DROP NOT NULL;

ALTER TABLE toms."Bays"
    ADD COLUMN "Last_MHTC_Check_UpdateDateTime" timestamp without time zone;
ALTER TABLE toms."Bays"
    ADD COLUMN "Last_MHTC_Check_UpdatePerson" character varying(255);
ALTER TABLE toms."Bays"
    ADD COLUMN "FieldCheckCompleted" BOOLEAN NOT NULL DEFAULT FALSE;

-- add set_last_update_details trigger (0014c1 .. TOMs)

-- migrate data

INSERT INTO toms."Bays"(
	"RestrictionID", "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID",
	"Notes",
	"RoadName", "LastUpdateDateTime", "LastUpdatePerson", "NrBays",
	"TimePeriodID", "MaxStayID", "CreateDateTime", "CreatePerson", "Location"
)

SELECT "RestrictionID", "GeometryID", geom, "RestrictionLength"::real, COALESCE("RestrictionTypeID"::integer, 103), COALESCE("GeomShapeID"::integer, 21),
CONCAT("Notes", ' | ', baylist_notes_1, ' | ', baylist_notes_2),
"RoadName", "LastUpdateDateTime", "LastUpdatePerson", COALESCE("NrBays"::integer, -1),
 "TimePeriodID", "MaxStayID", "CreateDateTime", "CreatePerson", "Location"
	FROM local_authority.enfield_bays;