/*
-- set up triggers to update labels
-- https://kartoza.com/en/blog/using-pgnotify-to-automatically-refresh-layers-in-qgis/

*/

CREATE OR REPLACE FUNCTION public.notify_qgis() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN NOTIFY qgis;
        RETURN NULL;
        END;
    $$;

DROP TRIGGER IF EXISTS notify_qgis_edit ON havering_operations."HaveringMapFrames";

CREATE TRIGGER notify_qgis_edit
  AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE ON havering_operations."HaveringMapFrames"
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

DROP TRIGGER IF EXISTS notify_qgis_edit ON havering_operations."HaveringCorners";

CREATE TRIGGER notify_qgis_edit
  AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE ON havering_operations."HaveringCorners"
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

DROP TRIGGER IF EXISTS notify_qgis_edit ON havering_operations."HaveringCorners_Output";

CREATE TRIGGER notify_qgis_edit
  AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE ON havering_operations."HaveringCorners_Output"
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();