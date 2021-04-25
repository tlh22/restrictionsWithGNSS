/*
Allow linework to be created without a corner.
Needs to be associated with a junction ?? (or a map frame??)
*/

-- Ensure record created in HaveringCorners_Output

ALTER TABLE ONLY havering_operations."HaveringCorners_Output"
    ALTER COLUMN "GeometryID" SET DEFAULT ('CO_'::"text" || "to_char"("nextval"('havering_operations."HaveringCorners_id_seq"'::"regclass"), 'FM00000'::"text"));

ALTER TABLE ONLY havering_operations."HaveringCorners_Output"
    DROP CONSTRAINT IF EXISTS "HaveringCorners_Output_GeometryID_fkey";

-- added in ISL details ... (but missed here...)

ALTER TABLE toms."Bays"
    ADD COLUMN "FieldCheckCompleted" BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE toms."Lines"
    ADD COLUMN "FieldCheckCompleted" BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE toms."Signs"
    ADD COLUMN "FieldCheckCompleted" BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE toms."RestrictionPolygons"
    ADD COLUMN "FieldCheckCompleted" BOOLEAN NOT NULL DEFAULT FALSE;

---

CREATE OR REPLACE FUNCTION havering_operations."set_new_corner_dimension_lines_geom"()
RETURNS trigger
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   cornerProtectionLineString geometry;
   cnr_id text;
   nearestJunction text;
BEGIN

    cnr_id = NEW."GeometryID";
    RAISE NOTICE '***** IN set_new_corner_dimension_lines_geom: cnr_id(%)', cnr_id;

    -- TODO: Check that corner exists
    -- regenerate dimension lines
    IF EXISTS(
        SELECT 1
        FROM havering_operations."HaveringCorners"
        WHERE "GeometryID" = cnr_id
    ) THEN

        RAISE NOTICE '***** IN set_new_corner_dimension_lines_geom: setting new corner prot geom ...';

        UPDATE havering_operations."HaveringCorners" AS c
        SET corner_dimension_lines_geom = ST_Multi(havering_operations."get_all_new_corner_dimension_lines"(cnr_id))
        WHERE havering_operations."get_all_new_corner_dimension_lines"(cnr_id) IS NOT NULL
        AND c."GeometryID" = cnr_id;

    END IF;
    --NEW."new_corner_protection_geom" := cornerProtectionLineString;
    RETURN NEW;

END;
$BODY$;
