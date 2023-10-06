
-- Create new table

DROP TABLE IF EXISTS local_authority."SiteArea_Single" CASCADE;
DROP SEQUENCE IF EXISTS local_authority."SiteArea_Single_id_seq";

CREATE SEQUENCE IF NOT EXISTS local_authority."SiteArea_Single_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE local_authority."SiteArea_Single_id_seq"
    OWNER TO postgres;
	
CREATE TABLE IF NOT EXISTS local_authority."SiteArea_Single"
(
    id integer NOT NULL DEFAULT nextval('local_authority."SiteArea_Single_id_seq"'::regclass),
    geom geometry(Polygon,27700),
    CONSTRAINT "SiteArea_Single_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS local_authority."SiteArea_Single"
    OWNER to postgres;
-- Index: sidx_SiteArea_geom

DROP INDEX IF EXISTS local_authority."sidx_SiteArea_Single_geom";

CREATE INDEX IF NOT EXISTS "sidx_SiteArea_Single_geom"
    ON local_authority."SiteArea_Single" USING gist
    (geom)
    TABLESPACE pg_default;

-- Populate

INSERT INTO local_authority."SiteArea_Single"(
	geom)
	SELECT (ST_DUMP(geom)).geom::geometry(Polygon,27700) AS geom FROM local_authority."SiteArea";

-- Rename

DROP TABLE local_authority."SiteArea" CASCADE;

ALTER TABLE local_authority."SiteArea_Single" RENAME TO "SiteArea";
ALTER SEQUENCE local_authority."SiteArea_Single_id_seq" RENAME TO "SiteArea_id_seq";
ALTER INDEX local_authority."sidx_SiteArea_Single_geom" RENAME TO "sidx_SiteArea_geom";



