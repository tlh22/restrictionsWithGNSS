-- Table: mhtc_operations.Site

-- DROP TABLE mhtc_operations."Site";

CREATE TABLE mhtc_operations."Site"
(
    id SERIAL,
    geom geometry(Polygon,27700),
    CONSTRAINT "Site_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."Site"
    OWNER to postgres;