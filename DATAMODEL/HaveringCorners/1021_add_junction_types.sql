/**
Add extra fields to table and form
**/

DROP TABLE IF EXISTS havering_operations."JunctionTypes" CASCADE;

-- Junction type
CREATE SEQUENCE havering_operations."JunctionType_Code_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE havering_operations."JunctionType_Code_seq"
    OWNER TO postgres;

CREATE TABLE havering_operations."JunctionTypes"
(
    "Code" integer NOT NULL DEFAULT nextval('havering_operations."JunctionType_Code_seq"'::regclass),
    "Description" character varying COLLATE pg_catalog."default",
    CONSTRAINT "JunctionType_pkey" PRIMARY KEY ("Code")
);

